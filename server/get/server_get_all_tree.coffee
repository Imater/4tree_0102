async = require('async');
mongoose = require('mongoose')

require '../../models/_js/model_tree.js'

Tree = mongoose.model('Tree');

exports.get = (req, res)->
  user_id = req.query.user_id
  async.waterfall [

    (callback)->
      console.info "USER_ID = ", user_id
      Tree.find {'user_id':user_id, 'del':0}, (err, rows)->
        async.eachLimit rows, 50, (row, callback)->
          row._open = false;
          row._settings = false;
          row.title = strip_tags(row.title) if row.title
          callback null;
        , (err)->
          callback err, rows
          res.send( JSON.stringify rows )
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