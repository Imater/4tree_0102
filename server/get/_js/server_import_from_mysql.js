// Generated by CoffeeScript 1.6.3
(function() {
  var CryptoJS, OAuthUsersModel, ObjectId, Text, Tree, async, frommysql, mongoose, removeCollection;

  async = require('async');

  mongoose = require('mongoose');

  CryptoJS = require("crypto-js");

  ObjectId = mongoose.Types.ObjectId();

  require('../../models/_js/model_tree.js');

  require('../../models/_js/model_text.js');

  Tree = mongoose.model('Tree');

  Text = mongoose.model('Text');

  OAuthUsersModel = mongoose.model('OAuthUsers');

  removeCollection = function(callback) {
    return async.parallel([
      function(callback2) {
        var collection;
        collection = db.collection("trees");
        return collection.remove({}, function(err, count) {
          return callback2(err);
        });
      }, function(callback2) {
        var collection;
        collection = db.collection("texts");
        return collection.remove({}, function(err, count) {
          return callback2(err);
        });
      }
    ], function(err) {
      return callback(err);
    });
  };

  frommysql = function(mysqldate, need_add_hours) {
    var d;
    d = new Date(Date.parse(mysqldate, 'Y-m-d H:i:s'));
    return new Date(d.getTime() - need_add_hours * 60 * 60 * 1000);
  };

  exports.get = function(req, res) {
    var objectId_to_id, user_id;
    user_id = req.query.user_id;
    console.info("start_import user = ", user_id);
    objectId_to_id = {};
    return async.waterfall([
      removeCollection, function(callback) {
        return pool.query('SELECT * FROM tree_users WHERE id=?', [user_id], function(err, user, fields) {
          return OAuthUsersModel.find({
            email: user[0].email
          }, function(err, user_mongo_found) {
            console.info("USER = ", user_mongo_found, user[0].email);
            return callback(err, user[0], user_mongo_found[0]);
          });
        });
      }, function(user, user_mongo_found, callback) {
        return pool.query('SELECT * FROM tree WHERE user_id=? and del!=1', [user_id], function(err, rows, fields) {
          return callback(err, rows, user, user_mongo_found);
        });
      }, function(rows, user, user_mongo_found, callback) {
        var current_timezone_offset, need_add_hours, now, one_note;
        console.info("user_mongo_found_id = ", user_mongo_found._id);
        now = new Date();
        current_timezone_offset = now.getTimezoneOffset() / 60;
        need_add_hours = current_timezone_offset - user.time_dif;
        console.info('time_zone', user.time_dif, current_timezone_offset, need_add_hours);
        one_note = new Tree;
        objectId_to_id["1"] = mongoose.Types.ObjectId().toString();
        objectId_to_id[1] = objectId_to_id["1"];
        one_note['_id'] = objectId_to_id["1"];
        one_note['title'] = '4tree';
        one_note['user_id'] = user_mongo_found._id;
        one_note['del'] = 0;
        one_note['folder'] = 'main';
        one_note.save(function(err, result) {
          return console.info('Main_tree = ', err, result);
        });
        return async.eachLimit(rows, 50, function(row, callback) {
          var new_date, one_text, sha3;
          one_note = new Tree;
          if (!objectId_to_id[row.parent_id]) {
            objectId_to_id[row.parent_id] = mongoose.Types.ObjectId();
          }
          if (!objectId_to_id[row.id]) {
            objectId_to_id[row.id] = mongoose.Types.ObjectId();
          }
          one_text = new Text;
          one_text['_id'] = objectId_to_id[row.id];
          one_text['user_id'] = user_mongo_found._id;
          one_text['text'] = row.text;
          one_text['db_name'] = 'trees';
          if (row.parent_id !== 0) {
            sha3 = CryptoJS.SHA3(JSON.stringify(one_note), {
              outputLength: 128
            }).toString();
            console.info('sha = ', sha3);
            one_text['_sha3'] = sha3;
            one_text.save();
          }
          one_note['_id'] = objectId_to_id[row.id];
          one_note['title'] = row.title;
          one_note['parent_id'] = objectId_to_id[row.parent_id];
          one_note['parent'] = row.parent_id;
          one_note['pos'] = row.position;
          one_note['user_id'] = user_mongo_found._id;
          if (row.node_icon) {
            one_note['icon'] = row.node_icon;
          }
          if (row.del !== 0) {
            one_note['del'] = 1;
          }
          if (row.smth) {
            one_note['old_tag'] = row.smth;
          }
          if (row.parent_id === 1 || row.parent_id === '1') {
            console.info("P = ", one_note.parent_id, one_note._id);
          }
          if (row.adddate !== '0000-00-00 00:00:00') {
            new_date = frommysql(row.adddate, need_add_hours);
            one_note['add_tm'] = new_date;
          }
          if (row.date1 !== '0000-00-00 00:00:00') {
            new_date = frommysql(row.date1, need_add_hours);
            one_note['date1'] = new_date;
          }
          if (row.date2 !== '0000-00-00 00:00:00') {
            new_date = frommysql(row.date2, need_add_hours);
            one_note['date2'] = new_date;
          }
          if (row.did !== '0000-00-00 00:00:00') {
            new_date = frommysql(row.did, need_add_hours);
            one_note['did'] = new_date;
          }
          if (row.parent_id !== 0) {
            sha3 = CryptoJS.SHA3(JSON.stringify(one_note), {
              outputLength: 128
            }).toString();
            one_note['_sha3'] = sha3;
            return one_note.save(function(err, result) {
              if (result) {
                objectId_to_id[row.id] = result._id;
              }
              return callback(err, rows);
            });
          } else {
            return callback();
          }
        }, function(err) {
          console.info("THE END = ", true);
          return callback(err);
        });
      }
    ], function(err, rows) {
      return res.send('ok');
    });
  };

}).call(this);
