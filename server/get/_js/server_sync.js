// Generated by CoffeeScript 1.6.3
(function() {
  var CryptoJS, Diff, async, jsondiffpatch, logJson, mongoose;

  async = require('async');

  mongoose = require('mongoose');

  logJson = require('../../logJson/_js/logJson.js');

  CryptoJS = require("crypto-js");

  jsondiffpatch = require('jsondiffpatch').create({
    objectHash: function(obj) {
      return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);
    }
  });

  require('../../models/_js/model_diff.js');

  Diff = mongoose.model('Diff');

  exports.get = function(req, res) {
    var diffs, send_to_client;
    diffs = req.body.diffs;
    send_to_client = {};
    return async.eachLimit(diffs, 50, function(diff, callback) {
      logJson('diff ' + diff._id, diff);
      return global._db_models[diff.db_name].findOne({
        '_sha3': diff._sha3,
        '_id': diff._id
      }, void 0, function(err, row) {
        var new_diff, sha3, updated_element;
        if (row) {
          console.info('rows found', row);
          console.info('PATCHED = ', diff.patch);
          updated_element = jsondiffpatch.patch(row, diff.patch);
          console.info('JSON.stringify(updated_element)', JSON.stringify(updated_element));
          sha3 = CryptoJS.SHA3(JSON.stringify(updated_element), {
            outputLength: 128
          }).toString();
          updated_element._sha3 = sha3;
          if (!send_to_client[diff.db_name]) {
            send_to_client[diff.db_name] = {
              confirm: {}
            };
          }
          send_to_client[diff.db_name].confirm[diff._id] = {
            _sha3: sha3
          };
          logJson('confirm', {
            send_to_client: send_to_client
          });
          logJson('!!!!!!!', updated_element, sha3);
          diff.db_id = diff._id;
          diff.body = row;
          delete diff._id;
          new_diff = new Diff(diff);
          return async.parallel([
            function(callback2) {
              return new_diff.save(function(err, doc) {
                console.info('save to backup', err, doc);
                return callback2();
              });
            }, function(callback2) {
              return updated_element.save(function(err, doc) {
                console.info('save to db', err, doc);
                return callback2();
              });
            }
          ], function() {
            return callback();
          });
        } else {
          console.info('sha of ' + diff._id + ' not found');
          return callback();
        }
      });
    }, function() {
      console.info('did!');
      return res.send(send_to_client);
    });
  };

}).call(this);
