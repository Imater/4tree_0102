async = require('async');
mongoose = require('mongoose')
logJson = require('../../logJson/_js/logJson.js');
CryptoJS = require("crypto-js");

jsondiffpatch = require('jsondiffpatch').create {
  objectHash: (obj) ->
    # try to find an id property, otherwise serialize it all
    return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);  
}

require '../../models/_js/model_diff.js'

Diff = mongoose.model('Diff');

exports.get = (req, res)->
  diffs = req.body.diffs;
  send_to_client = {};
  async.eachLimit diffs, 50, (diff, callback)->
    logJson 'diff '+diff._id, diff

    global._db_models[diff.db_name].findOne {'_sha3':diff._sha3, '_id':diff._id}, undefined, (err, row)->
      if row
        console.info 'rows found', row ;
        console.info 'PATCHED = ', diff.patch
        updated_element = jsondiffpatch.patch(row, diff.patch)
        console.info 'JSON.stringify(updated_element)', JSON.stringify(updated_element)
        sha3 = CryptoJS.SHA3(JSON.stringify(updated_element), { outputLength: 128 }).toString()
        updated_element._sha3 = sha3
        send_to_client[diff.db_name] = {confirm: {}} if !send_to_client[diff.db_name]
        send_to_client[diff.db_name].confirm[diff._id] = { _sha3: sha3 }
        logJson 'confirm', { send_to_client }
        logJson '!!!!!!!', updated_element, sha3

        diff.db_id = diff._id
        diff.body = row;
        delete diff._id
        new_diff = new Diff(diff)
        async.parallel [
          (callback2)->
            new_diff.save (err, doc)->
              console.info 'save to backup', err, doc
              callback2()
          (callback2)->
            updated_element.save (err, doc)->
              console.info 'save to db', err, doc
              callback2()
        ], ()->
          callback();
      else
        console.info 'sha of '+diff._id+' not found';
        callback()

  , ()->
    console.info 'did!'
    res.send(send_to_client)

