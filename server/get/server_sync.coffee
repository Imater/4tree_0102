async = require('async');
mongoose = require('mongoose')
logJson = require('../../logJson/_js/logJson.js');
JSON_stringify = require '../../scripts/_js/JSON_stringify.js'
$ = require('jquery')
_ = require('underscore');

jsondiffpatch = require('jsondiffpatch').create {
  objectHash: (obj) ->
    # try to find an id property, otherwise serialize it all
    return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);  
  textDiff: {
      minLength: 3
  }
}

require '../../models/_js/model_diff.js'

Diff = mongoose.model('Diff');
Text = mongoose.model('Text');


sync = {
  apply_patch: (args, dont_save_to_db)->
    dfd = $.Deferred()
    mythis = @;
    console.info 'apply patch to '+args.diff.db_name, args.old_row if false
    args.old_row = jsondiffpatch.patch( args.old_row, args.diff.patch)
    args.old_row._sha1 = JSON_stringify.JSON_stringify( args.old_row )._sha1
    logJson 'new_row', args.new_row if false
    args.old_row._tm = new Date()
    args.old_row._diff = args.diff;
    #при этом сохранится бекап в базе diff
    args.old_row.save (err)-> 
      dfd.resolve(args);
    dfd.promise();
  combineDiffsByTime: (_id)->
    dfd = $.Deferred()
    Diff.find {'db_id':_id}, undefined, {sort: {tm:1}}, (err, rows)->
      if !rows[0]
        console.info 'NOT FOUND IN DIFFS - '+ _id
      answer = rows[0].body;
      async.eachSeries rows, (dif, callback)->
        logJson 'body was = ', answer
        answer = jsondiffpatch.patch(answer, dif.patch)
        logJson 'body now = ', answer
        logJson 'dif = ', dif.patch
        answer._sha1 = JSON_stringify.JSON_stringify( answer )._sha1
        callback()
      , ()->
        dfd.resolve(answer);
    dfd.promise()
  combineAllDiffs: (req, res)->
    mythis = @;
    _id = req.query._id
    mythis.combineDiffsByTime(_id).then (combined)->
      res.send(combined);
    answer = {};
  Merge: (diff)->
    dfd = new $.Deferred();
    logJson 'diff = ', diff
    delta1 = diff.patch
    #Находим старый текст с такой же контрольной суммой
    Diff.findOne {_sha1: diff._sha1, db_id: diff._id}, undefined, (err, doc0)->      
      logJson 'doc0new', doc0.new_body
      doc1 = jsondiffpatch.patch( doc0.new_body, delta1)
      logJson 'doc1', doc1
      global._db_models[diff.db_name].findOne { _id: diff._id }, undefined, (err, doc2)->
        logJson 'doc2', doc2
        delta2 = jsondiffpatch.diff( doc0.new_body, doc2.toObject() )
        delta2['_sha1'] = undefined if delta2['_sha1']
        delta2['_tm'] = undefined if delta2['_tm']
        logJson 'delta2', delta2
        doc3 = jsondiffpatch.patch( doc1, delta2 )
        doc3 = jsondiffpatch.patch( doc3, delta1 )
        main_diff = jsondiffpatch.diff(doc2.toObject(), doc3)
        logJson 'DOC3', doc3
        logJson 'MAIN_DIFF', main_diff
        doc2 = _.extend( doc2, doc3)
        console.info 'doc2', doc2
        doc2._diff = diff
        doc2._tm = new Date()
        doc2.save (err, doc)->
          console.info 'merged saved', err, doc
          dfd.resolve(doc);
    dfd.promise();

}

exports.get2 = (req, res)->
  #sync.combineAllDiffs(req, res)
  Text.findOne { _id: req.query._id }, undefined, (err, row)->
    row._tm = new Date();
    row.save();
    res.send(row)


exports.get = (req, res)->
  exports.fullSyncUniversal(req, res).then (data_to_client)->
    res.send(data_to_client);

exports.fullSyncUniversal = (req, res)->
  dfd = new $.Deferred();
  diffs = req.body.diffs;
  user_id = req.body.user_id;
  last_sync_time = req.query.last_sync_time;
  machine = req.query.machine;

  confirm_count = 0;

  sha1_sign = req.query.machine + JSON_stringify.JSON_stringify(diffs)._sha1
  if sha1_sign != req.body.sha1_sign
    console.info 'Error of signing sync http: '+req.body.sha1_sign+' != '+sha1_sign if false
    res.send();
  else
    send_to_client = {};
    if diffs
      async.eachLimit Object.keys(diffs), 50, (diff_id, callback)->
        diff = diffs[diff_id];
        logJson 'diff '+diff._id, diff if false

        global._db_models[diff.db_name].findOne {'_sha1':diff._sha1, '_id':diff._id}, undefined, (err, row)->
          if row
            console.info 'found in db ', row if false
            sync.apply_patch({ 
              old_row: row
              diff: diff
            }).then (args)->
              send_to_client[diff.db_name] = { confirm: {} } if !send_to_client[diff.db_name]
              send_to_client[diff.db_name]['confirm'][args.old_row._id] = { _sha1: args.old_row._sha1, _tm: args.old_row._tm }
              confirm_count++;
              callback()
          else
            #тут нужно разобраться
            console.info 'Error, dont found, need seek DIFF'
            sync.Merge(diff).then (doc)->
              if doc
                send_to_client[diff.db_name] = { confirm: {} } if !send_to_client[diff.db_name]
                send_to_client[diff.db_name]['confirm'][doc._id] = { _sha1: doc._sha1, _tm: doc._tm }              
                confirm_count++;
              callback() 

      , ()->
        async.each Object.keys(global._db_models), (db_name, callback)->
          tm = new Date( JSON.parse(last_sync_time) ).toISOString();
          console.info 'FIND', { _tm: { $gt: tm } } if false
          global._db_models[db_name].find { _tm: { $gt: tm } }, (err, docs)->
            async.filter docs, (doc, callback2)->
              if send_to_client?[db_name]?['confirm']?[ doc._id ]?._sha1 == doc._sha1
                need = false
              else
                need = true
              callback2(need);
            , (docs_filtered)->
              console.info { docs_filtered } if false
              if docs_filtered.length
                send_to_client[db_name] = {} if !send_to_client[db_name]
                send_to_client[db_name].new_data = docs_filtered
              callback();
        , ()->
          send_to_client.server_time = new Date()
          send_to_client.confirm_count = confirm_count;
          logJson 'send_to_client', send_to_client
          dfd.resolve(send_to_client);

          if confirm_count > 0
            clients = global.io.sockets.clients('user_id:'+user_id)
            if clients
              async.each Object.keys(clients), (client_i, callback3)->
                client = clients[client_i]
                client.get 'nickname', (err, nickname)->
                  nickname = JSON.parse(nickname)
                  if nickname and nickname.machine != machine
                    client.emit('need_sync_now')
                callback3()
              ,()->
                console.info 'info sended by socket'
          #logJson 'send_to_client', send_to_client
    else
      dfd.resolve()
  dfd.promise();

















