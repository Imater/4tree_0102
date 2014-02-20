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
  
  #  discuss at: http://phpjs.org/functions/strip_tags/
  # original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  # improved by: Luke Godfrey
  # improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  #    input by: Pul
  #    input by: Alex
  #    input by: Marc Palau
  #    input by: Brett Zamir (http://brett-zamir.me)
  #    input by: Bobby Drake
  #    input by: Evertjan Garretsen
  # bugfixed by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  # bugfixed by: Onno Marsman
  # bugfixed by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  # bugfixed by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  # bugfixed by: Eric Nagel
  # bugfixed by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  # bugfixed by: Tomasz Wesolowski
  #  revised by: Rafał Kukawski (http://blog.kukawski.pl/)
  #   example 1: strip_tags('<p>Kevin</p> <br /><b>van</b> <i>Zonneveld</i>', '<i><b>');
  #   returns 1: 'Kevin <b>van</b> <i>Zonneveld</i>'
  #   example 2: strip_tags('<p>Kevin <img src="someimage.png" onmouseover="someFunction()">van <i>Zonneveld</i></p>', '<p>');
  #   returns 2: '<p>Kevin van Zonneveld</p>'
  #   example 3: strip_tags("<a href='http://kevin.vanzonneveld.net'>Kevin van Zonneveld</a>", "<a>");
  #   returns 3: "<a href='http://kevin.vanzonneveld.net'>Kevin van Zonneveld</a>"
  #   example 4: strip_tags('1 < 5 5 > 1');
  #   returns 4: '1 < 5 5 > 1'
  #   example 5: strip_tags('1 <br/> 1');
  #   returns 5: '1  1'
  #   example 6: strip_tags('1 <br/> 1', '<br>');
  #   returns 6: '1 <br/> 1'
  #   example 7: strip_tags('1 <br/> 1', '<br><br/>');
  #   returns 7: '1 <br/> 1'
  allowed = (((allowed or "") + "").toLowerCase().match(/<[a-z][a-z0-9]*>/g) or []).join("") # making sure the allowed arg is a string containing only tags in lowercase (<a><b><c>)
  tags = /<\/?([a-z][a-z0-9]*)\b[^>]*>/g
  commentsAndPhpTags = /<!--[\s\S]*?-->|<\?(?:php)?[\s\S]*?\?>/g
  s = input.replace(commentsAndPhpTags, "").replace tags, ($0, $1) ->
    (if allowed.indexOf("<" + $1.toLowerCase() + ">") > -1 then $0 else "")
  s.replace /nbsp;|&/ig, ' '