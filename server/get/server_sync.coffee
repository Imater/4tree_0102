async = require('async');
mongoose = require('mongoose')
logJson = require('../../logJson/_js/logJson.js');
JSON_stringify = require '../../scripts/_js/JSON_stringify.js'
$ = require('jquery')

jsondiffpatch = require('jsondiffpatch').create {
  objectHash: (obj) ->
    # try to find an id property, otherwise serialize it all
    return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);  
}

require '../../models/_js/model_diff.js'

Diff = mongoose.model('Diff');


sync = {
  apply_patch: (args, dont_save_to_db)->
    ###
    args = {
      old_row
      diff: {
        patch
        db_name
        _sha1
        user_id
        machine
        tm
      }
    }
    ###
    dfd = $.Deferred()
    mythis = @;
    console.info 'apply patch to '+args.diff.db_name, args.old_row
    args.new_row = jsondiffpatch.patch( JSON.parse( JSON.stringify(args.old_row) ), args.diff.patch)
    args.new_row._sha1 = JSON_stringify.JSON_stringify( args.new_row )._sha1
    logJson 'new_row', args.new_row 
    async.parallel [
      (callback)->
        mythis.save_diff(args).then ()->
          callback()
      (callback)->
        if !dont_save_to_db
          mythis.save_to_db(args).then ()->
            callback()
        else
          callback()
    ], ()->
      dfd.resolve(args);
    dfd.promise();
  save_diff: (args)->
    dfd = $.Deferred()
    console.info 'save_diff', args.old_row, args.new_row
    new_diff = new Diff()
    new_diff.db_id =  args.diff._id
    new_diff.patch = args.diff.patch
    new_diff._tm = args.diff._tm
    new_diff.body = args.old_row
    new_diff.new_body = args.new_row
    new_diff.new_sha1 = JSON_stringify.JSON_stringify( args.new_row )._sha1
    new_diff.user_id = args.diff.user_id
    new_diff.machine = args.diff.machine
    new_diff.db_name = args.diff.db_name
    new_diff._sha1 = args.diff._sha1
    new_diff.del = 0
    new_diff.save (err, doc)->
      dfd.resolve(doc);
    dfd.promise();
  save_to_db: (args)->
    dfd = $.Deferred()
    args.new_row._tm = new Date()
    global._db_models[args.diff.db_name].update {_id: args.diff._id}, args.new_row, {upsert: false}, (err, doc)->
      console.info 'db_saved', err, doc
      dfd.resolve(err)
    dfd.promise();
  combineDiffsByTime: (_id)->
    dfd = $.Deferred()
    Diff.find {'db_id':_id}, undefined, {sort: {tm:1}}, (err, rows)->
      answer = rows[0].body;
      async.eachSeries rows, (dif, callback)->
        answer = jsondiffpatch.patch(answer, dif.patch)
        answer._sha1 = JSON_stringify.JSON_stringify( answer )._sha1
        logJson 'dif = ', dif.patch
        logJson 'dif = ', dif._tm
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
}

exports.get2 = (req, res)->
  sync.combineAllDiffs(req, res)

exports.get = (req, res)->
  diffs = req.body.diffs;
  last_sync_time = req.query.last_sync_time;

  sha1_sign = req.query.machine + JSON_stringify.JSON_stringify(diffs)._sha1
  if sha1_sign != req.body.sha1_sign
    console.info 'Error of signing sync http: '+req.body.sha1_sign+' != '+sha1_sign
    res.send();
  else
    send_to_client = {};
    async.eachLimit diffs, 50, (diff, callback)->
      logJson 'diff '+diff._id, diff

      global._db_models[diff.db_name].findOne {'_sha1':diff._sha1, '_id':diff._id}, undefined, (err, row)->
        if row
          console.info 'found in db ', row
          sync.apply_patch({ 
            old_row: row
            diff: diff
          }).then (args)->
            send_to_client[diff.db_name] = { confirm: {} } if !send_to_client[args.new_row.db_name]
            send_to_client[diff.db_name]['confirm'][args.new_row._id] = { _sha1: args.new_row._sha1, _tm: args.new_row._tm }
            callback()
        else
          Diff.findOne {'_sha1':diff._sha1, 'db_id':diff._id}, undefined, (err, row)->
            logJson 'dont found in db, but found in diffs', row.body
            sync.apply_patch({ 
              old_row: row
              diff: diff
            }, 'dont_save_to_db').then (args)->
              sync.combineDiffsByTime(args.new_row.db_id).then (combined)->
                logJson 'combined = ', combined
                tm = new Date();
                send_to_client[diff.db_name] = { confirm: {}, merged: {}, _tm: 'sex' } if !send_to_client[args.new_row.db_name]
                send_to_client[diff.db_name]['merged'][combined._id] = { combined }
                send_to_client[diff.db_name]['confirm'][combined._id] = { _sha1: combined._sha1, _tm: combined._tm }
                global._db_models[args.diff.db_name].findOne {_id:args.diff._id}, undefined, (err, now_doc)->
                  empty_diff = JSON.parse( JSON.stringify(diff) )
                  empty_diff._sha1 = now_doc._sha1
                  empty_diff.machine = 'server'
                  empty_diff.patch = undefined
                  empty_diff._tm = empty_diff._tm+500
                  sync.apply_patch({ 
                    old_row: now_doc
                    diff: empty_diff
                  }, 'dont_save_to_db').then (args)->
                    console.info 'saved_original', args
                    combined._tm = new Date();
                    ##забекапить в дифах
                    global._db_models[args.diff.db_name].update {_id: args.diff._id}, combined, {upsert: false}, (err, doc)->
                      console.info 'saved from diff', err, doc
                      callback() 

    , ()->
      async.each Object.keys(global._db_models), (db_name, callback)->
        tm = new Date( JSON.parse(last_sync_time) ).toISOString();
        console.info 'FIND', { _tm: { $gt: tm } }
        global._db_models[db_name].find { _tm: { $gt: tm } }, (err, docs)->
          send_to_client[db_name] = {} if !send_to_client[db_name]
          send_to_client[db_name].new_data = docs
          callback();
      , ()->
        send_to_client.now_time = new Date()
        res.send(send_to_client)
        #logJson 'send_to_client', send_to_client

















