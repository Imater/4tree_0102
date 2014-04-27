async = require('async');
mongoose = require('mongoose')
logJson = require('../../logJson/_js/logJson.js');
JSON_stringify = require '../../scripts/_js/JSON_stringify.js'

jsondiffpatch = require('jsondiffpatch').create {
  objectHash: (obj) ->
    # try to find an id property, otherwise serialize it all
    return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);  
}

require '../../models/_js/model_diff.js'

Diff = mongoose.model('Diff');

exports.get = (req, res)->
  diffs = req.body.diffs;

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
          diff.body = JSON.parse(JSON.stringify row); #бэкапим старое значение
          console.info 'rows found', row ;
          console.info 'PATCHED = ', diff.patch
          updated_element = jsondiffpatch.patch(row, diff.patch)
          console.info 'JSON.stringify(updated_element)', JSON.stringify(updated_element)
          sha1 = JSON_stringify.JSON_stringify(updated_element)._sha1
          updated_element._sha1 = sha1
          send_to_client[diff.db_name] = {confirm: {}} if !send_to_client[diff.db_name]
          send_to_client[diff.db_name].confirm[diff._id] = { _sha1: sha1 }
          logJson 'confirm', { send_to_client }
          logJson '!!!!!!!', updated_element, sha1

          diff.db_id = diff._id
          delete diff._id
          new_diff = new Diff(diff)
          async.parallel [
            (callback2)->
              new_diff.save (err, doc)->
                console.info 'save to diff', err, doc
                callback2()
            (callback2)->
              updated_element.save (err, doc)->
                console.info 'save to db', err, doc.length
                callback2()
          ], ()->
            callback();
        else
          console.info 'sha of '+diff._id+' not found. sha1 = '+diff._sha1;
          console.info 'try to find ', {'_sha1': diff._sha1, 'db_id': diff._id, 'tm': {$lte: diff.tm} }
          Diff.find {'_sha1': diff._sha1, 'db_id': diff._id, 'tm': {$lte: diff.tm} }, undefined, (err, rows)->
            async.each rows, (row, callback3)->
              console.info 'dif_one', row
              updated_element = jsondiffpatch.patch(row.body, diff.patch)
              updated_element = jsondiffpatch.patch(updated_element, row.patch)
              logJson 'updated_element', updated_element
              callback3();
            , ()->
              console.info 'Merged'
          callback()

    , ()->
      console.info 'did!'
      res.send(send_to_client)

