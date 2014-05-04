// Generated by CoffeeScript 1.6.3
(function() {
  var $, Diff, JSON_stringify, cloneData, jsondiffpatch, mongoose;

  mongoose = require("mongoose");

  require('../../models/_js/model_diff.js');

  Diff = mongoose.model('Diff');

  JSON_stringify = require('../../scripts/_js/JSON_stringify.js');

  $ = require('jquery');

  jsondiffpatch = require('jsondiffpatch').create({
    objectHash: function(obj) {
      return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);
    },
    textDiff: {
      minLength: 3
    }
  });

  cloneData = function(data) {
    return JSON.parse(JSON.stringify(data));
  };

  exports.saveDiff = function(db_name, new_data, old_data) {
    var dfd, dif, patch;
    dfd = new $.Deferred();
    new_data._sha1 = JSON_stringify.JSON_stringify(new_data)._sha1;
    if (new_data.toObject() && old_data) {
      patch = jsondiffpatch.diff(old_data, new_data.toObject());
      if (patch != null ? patch._sha1 : void 0) {
        delete patch._sha1;
      }
      if (patch != null ? patch._tm : void 0) {
        delete patch._tm;
      }
      dif = {
        db_id: new_data._id,
        patch: patch,
        old_body: old_data,
        new_body: new_data,
        machine: new_data._diff.machine,
        user_id: new_data._diff.user_id,
        _sha1: new_data._sha1,
        del: 0,
        _tm: new_data._tm
      };
      new Diff(dif).save(function(err, doc) {
        if (false) {
          return console.info('DIFF SAVED', err, doc);
        }
      });
      dfd.resolve();
    } else {
      dfd.resolve();
    }
    return dfd.promise();
  };

}).call(this);