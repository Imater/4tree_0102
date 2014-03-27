async = require('async')
mongoose = require('mongoose')

require '../../models/_js/model_tree.js'

Tree = mongoose.model('Tree');


removeCollection = (callback)->
  collection = db.collection("trees");
  collection.remove {}, (err, count)->
    callback err

frommysql = (mysqldate, need_add_hours)->
  d = new Date( Date.parse(mysqldate,'Y-m-d H:i:s') )
  new Date (d.getTime() - need_add_hours*60*60*1000)


exports.get = (req, res)->
  user_id = req.query.user_id
  console.info "start_import user = ", user_id
  async.waterfall [
    removeCollection
    (callback)->
      pool.query 'SELECT * FROM tree_users WHERE id=?', [user_id], (err, user, fields)->
        console.info 'user = ', user
        callback err, user[0]
    (user, callback)->
      pool.query 'SELECT * FROM tree WHERE user_id=?', [user_id], (err, rows, fields)->
        console.info 'mysql = ', err
        callback err, rows, user
    (rows, user, callback)->

      collection = db.collection("new_tree");

      now = new Date();
      current_timezone_offset = now.getTimezoneOffset()/60;

      need_add_hours = current_timezone_offset - user.time_dif

      console.info 'time_zone', user.time_dif, current_timezone_offset, need_add_hours;

      async.eachLimit rows, 50, (row, callback)->
        #console.info "row = ", row

        one_note = new Tree;
        
        one_note['id'] = row.id
        one_note['title'] = row.title
        one_note['text'] = row.text
        one_note['parent_id'] = row.parent_id
        one_note['parent'] = row.parent_id
        one_note['pos'] = row.position
        one_note['user_id'] = row.user_id
        one_note['icon'] = row.node_icon if row.node_icon
        one_note['del'] = 1 if row.del != 0
        one_note['old_tag'] = row.smth if row.smth

        if row.adddate != '0000-00-00 00:00:00'
          new_date = frommysql(row.adddate, need_add_hours);
          one_note['add_tm'] = new_date 

        if row.date1 != '0000-00-00 00:00:00'
          new_date = frommysql(row.date1, need_add_hours);
          one_note['date1'] = new_date 

        if row.date2 != '0000-00-00 00:00:00'
          new_date = frommysql(row.date2, need_add_hours);
          one_note['date2'] = new_date

        if row.did != '0000-00-00 00:00:00'
          new_date = frommysql(row.did, need_add_hours);
          one_note['did'] = new_date 

        one_note.save (err, result)->
          console.info 'saved', err;
          callback err, rows
      , (err)->
        callback err


  ], (err, rows)->
    res.send('ok');

    
