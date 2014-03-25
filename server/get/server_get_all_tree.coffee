async = require('async');

exports.get = (req, res)->
  user_id = parseInt(req.query.user_id)
  async.waterfall [

    (callback)->
      collection = db.collection("new_tree");
      collection.find({'user_id':user_id, 'del':{$exists: false}}).toArray (err, rows)->
        async.each rows, (row, callback)->
          row._open = false;
          row._settings = false;
          row.title = strip_tags(row.title) if row.title
          row._text = strip_tags(row.text).substr(0,200)
          callback null;
        , (err)->
          callback err, rows
          res.send(rows)
      , (err)->
        callback err


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