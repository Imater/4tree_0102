// Generated by CoffeeScript 1.6.3
(function() {
  var CryptoJS, Diff, Tree, async, mongoose, strip_tags;

  async = require('async');

  mongoose = require('mongoose');

  CryptoJS = require("crypto-js");

  require('../../models/_js/model_tree.js');

  Tree = mongoose.model('Tree');

  require('../../models/_js/model_diff.js');

  Diff = mongoose.model('Diff');

  exports.get = function(req, res) {
    var user_id;
    user_id = req.query.user_id;
    return async.waterfall([
      function(callback) {
        var result;
        result = {};
        return async.each(Object.keys(global._db_models), function(db_name, callback2) {
          var data_to_send, db_model;
          console.info('!!DB_NAME', db_name);
          db_model = global._db_models[db_name];
          console.info("USER_ID = ", user_id);
          data_to_send = {};
          return db_model.find({
            'user_id': user_id,
            'del': 0
          }, function(err, rows) {
            return async.eachLimit(rows, 50, function(row, callback) {
              row._open = false;
              row._settings = false;
              if (row._sync) {
                delete row._sync;
              }
              if (row) {
                data_to_send[row._id] = row;
              }
              return callback(null);
            }, function(err) {
              result[db_name] = data_to_send;
              callback(err, rows);
              return callback2(err);
            });
          }, function(err) {
            return console.info('hi!!!');
          });
        }, function(err) {
          return res.send(JSON.stringify(result));
        });
      }
    ], function(err, rows) {});
  };

  strip_tags = function(input, allowed) {
    var commentsAndPhpTags, s, tags;
    allowed = (((allowed || "") + "").toLowerCase().match(/<[a-z][a-z0-9]*>/g) || []).join("");
    tags = /<\/?([a-z][a-z0-9]*)\b[^>]*>/g;
    commentsAndPhpTags = /<!--[\s\S]*?-->|<\?(?:php)?[\s\S]*?\?>/g;
    s = input.replace(commentsAndPhpTags, "").replace(tags, function($0, $1) {
      if (allowed.indexOf("<" + $1.toLowerCase() + ">") > -1) {
        return $0;
      } else {
        return "";
      }
    });
    return s.replace(/nbsp;|&/ig, ' ');
  };

}).call(this);
