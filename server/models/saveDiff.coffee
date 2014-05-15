mongoose = require("mongoose")

require '../../models/_js/model_diff.js'
Diff = mongoose.model('Diff');

JSON_stringify = require '../../scripts/_js/JSON_stringify.js'
$ = require('jquery')

jsondiffpatch = require('jsondiffpatch').create {
  objectHash: (obj) ->
    # try to find an id property, otherwise serialize it all
    return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);  
  textDiff: {
      minLength: 3
  }
}

cloneData = (data)->
  JSON.parse( JSON.stringify(data) )

exports.saveDiff = (db_name, new_data, old_data)->
  dfd = new $.Deferred()
  #console.info 'new', new_data, 'old', old_data, '_diff', new_data._diff
  new_data._sha1 = JSON_stringify.JSON_stringify(new_data)._sha1
  if new_data.toObject() and old_data
    patch = jsondiffpatch.diff( old_data, new_data.toObject() )
    delete patch._sha1 if patch?._sha1
    delete patch._tm if patch?._tm
    dif =
      db_id: new_data._id
      patch: patch
      old_body: old_data
      new_body: new_data
      machine: new_data._diff.machine
      user_id: new_data._diff.user_id
      _sha1: new_data._sha1
      del: 0
      _tm: new_data._tm
    
    new Diff(dif).save (err, doc)->
      console.info 'DIFF SAVED', err, doc if false
      dfd.resolve();
    #console.info "PATCH = ", patch, '!!!!!!!!', new_data._machine
  else
    dfd.resolve();
  dfd.promise()