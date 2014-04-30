mongoose = require("mongoose")

require '../../models/_js/model_diff.js'
Diff = mongoose.model('Diff');

JSON_stringify = require '../../scripts/_js/JSON_stringify.js'
$ = require('jquery')

jsondiffpatch = require('jsondiffpatch').create {
  objectHash: (obj) ->
    # try to find an id property, otherwise serialize it all
    return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);  
}

cloneData = (data)->
  JSON.parse( JSON.stringify(data) )

exports.saveDiff = (db_name, new_data, old_data)->
  dfd = new $.Deferred()
  console.info 'new', new_data, 'old', old_data
  new_data._sha1 = JSON_stringify.JSON_stringify(new_data)._sha1
  console.info "PATCH", jsondiffpatch.diff( new_data.toObject(), old_data )
  dfd.resolve();
  dfd.promise()