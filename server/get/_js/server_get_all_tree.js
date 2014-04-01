// Generated by CoffeeScript 1.6.3
(function() {
  var Tree, async, mongoose, strip_tags;

  async = require('async');

  mongoose = require('mongoose');

  require('../../models/_js/model_tree.js');

  Tree = mongoose.model('Tree');

  exports.get = function(req, res) {
    var user_id;
    user_id = parseInt(req.query.user_id);
    return async.waterfall([
      function(callback) {
        return Tree.find({
          'user_id': user_id,
          'del': 0
        }, function(err, rows) {
          return async.eachLimit(rows, 50, function(row, callback) {
            row._open = false;
            row._settings = false;
            if (row.title) {
              row.title = strip_tags(row.title);
            }
            row._text = strip_tags(row.text).substr(0, 200);
            return callback(null);
          }, function(err) {
            callback(err, rows);
            return res.send(JSON.stringify(rows));
          });
        }, function(err) {
          return callback(err);
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