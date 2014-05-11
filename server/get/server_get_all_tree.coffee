async = require('async');
mongoose = require('mongoose')
CryptoJS = require("crypto-js");
winston = require('winston')

require '../../models/_js/model_tree.js'
Tree = mongoose.model('Tree');

require '../../models/_js/model_diff.js'
Diff = mongoose.model('Diff');


exports.get = (req, res)->
  user_id = req.query.user_id
  async.waterfall [

    (callback)->
      result = {};
      async.each Object.keys(global._db_models), (db_name, callback2)->
        winston.info '!!DB_NAME', db_name
        db_model = global._db_models[db_name];
        winston.info "USER_ID = ", user_id
        data_to_send = {};
        db_model.find {'user_id':user_id, 'del':0}, (err, rows)->
          async.eachLimit rows, 50, (row, callback)->
            row._open = false;
            row._settings = false;
            if row._sync
              delete row._sync 
            data_to_send[row._id] = row if row;

            callback null;
          , (err)->
            result[db_name] = data_to_send;
            callback err, rows
            callback2 err
        , (err)->
          winston.info 'hi!!!';
      , (err)->
        res.send( JSON.stringify result )


  ], (err, rows)->
    #res.send('ok');

    
strip_tags = (input, allowed) ->
  # making sure the allowed arg is a string containing only tags in lowercase (<a><b><c>)
  allowed = (((allowed or "") + "").toLowerCase().match(/<[a-z][a-z0-9]*>/g) or []).join("") 
  tags = /<\/?([a-z][a-z0-9]*)\b[^>]*>/g
  commentsAndPhpTags = /<!--[\s\S]*?-->|<\?(?:php)?[\s\S]*?\?>/g
  s = input.replace(commentsAndPhpTags, "").replace tags, ($0, $1) ->
    (if allowed.indexOf("<" + $1.toLowerCase() + ">") > -1 then $0 else "")
  s.replace /nbsp;|&/ig, ' '