// Generated by CoffeeScript 1.6.3
(function() {
  var Diff, JSON_stringify, async, jsondiffpatch, logJson, mongoose;

  async = require('async');

  mongoose = require('mongoose');

  logJson = require('../../logJson/_js/logJson.js');

  JSON_stringify = require('../../scripts/_js/JSON_stringify.js');

  jsondiffpatch = require('jsondiffpatch').create({
    objectHash: function(obj) {
      return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);
    }
  });

  require('../../models/_js/model_diff.js');

  Diff = mongoose.model('Diff');

  exports.get = function(req, res) {
    var diffs, send_to_client, sha1_sign;
    diffs = req.body.diffs;
    sha1_sign = req.query.machine + JSON_stringify.JSON_stringify(diffs)._sha1;
    if (sha1_sign !== req.body.sha1_sign) {
      console.info('Error of signing sync http: ' + req.body.sha1_sign + ' != ' + sha1_sign);
      return res.send();
    } else {
      send_to_client = {};
      return async.eachLimit(diffs, 50, function(diff, callback) {
        logJson('diff ' + diff._id, diff);
        return global._db_models[diff.db_name].findOne({
          '_sha1': diff._sha1,
          '_id': diff._id
        }, void 0, function(err, row) {
          var new_diff, sha1, updated_element;
          if (row) {
            diff.body = JSON.parse(JSON.stringify(row));
            console.info('rows found', row);
            console.info('PATCHED = ', diff.patch);
            updated_element = jsondiffpatch.patch(row, diff.patch);
            console.info('JSON.stringify(updated_element)', JSON.stringify(updated_element));
            sha1 = JSON_stringify.JSON_stringify(updated_element)._sha1;
            updated_element._sha1 = sha1;
            if (!send_to_client[diff.db_name]) {
              send_to_client[diff.db_name] = {
                confirm: {}
              };
            }
            send_to_client[diff.db_name].confirm[diff._id] = {
              _sha1: sha1
            };
            logJson('confirm', {
              send_to_client: send_to_client
            });
            logJson('!!!!!!!', updated_element, sha1);
            diff.db_id = diff._id;
            delete diff._id;
            new_diff = new Diff(diff);
            return async.parallel([
              function(callback2) {
                return new_diff.save(function(err, doc) {
                  console.info('save to diff', err, doc);
                  return callback2();
                });
              }, function(callback2) {
                return updated_element.save(function(err, doc) {
                  console.info('save to db', err, doc.length);
                  return callback2();
                });
              }
            ], function() {
              return callback();
            });
          } else {
            console.info('sha of ' + diff._id + ' not found. sha1 = ' + diff._sha1);
            console.info('try to find ', {
              '_sha1': diff._sha1,
              'db_id': diff._id,
              'tm': {
                $lte: diff.tm
              }
            });
            Diff.find({
              '_sha1': diff._sha1,
              'db_id': diff._id,
              'tm': {
                $lte: diff.tm
              }
            }, void 0, function(err, rows) {
              return async.each(rows, function(row, callback3) {
                console.info('dif_one', row);
                updated_element = jsondiffpatch.patch(row.body, diff.patch);
                updated_element = jsondiffpatch.patch(updated_element, row.patch);
                logJson('updated_element', updated_element);
                return callback3();
              }, function() {
                return console.info('Merged');
              });
            });
            return callback();
          }
        });
      }, function() {
        console.info('did!');
        return res.send(send_to_client);
      });
    }
  };

}).call(this);