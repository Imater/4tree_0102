async = require('async')
mongoose = require('mongoose')

ObjectId = mongoose.Types.ObjectId();

require '../../models/_js/model_tree.js'

Tree = mongoose.model('Tree');
OAuthUsersModel = mongoose.model('OAuthUsers');


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
  objectId_to_id = {};
  async.waterfall [
    removeCollection
    (callback)->
      pool.query 'SELECT * FROM tree_users WHERE id=?', [user_id], (err, user, fields)->
        #console.info 'user = ', user
        OAuthUsersModel.find {email:user[0].email}, (err, user_mongo_found)->
          console.info "USER = ", user_mongo_found, user[0].email
          callback err, user[0], user_mongo_found[0]
    (user, user_mongo_found, callback)->
      pool.query 'SELECT * FROM tree WHERE user_id=? and del!=1', [user_id], (err, rows, fields)->
        callback err, rows, user, user_mongo_found
    (rows, user, user_mongo_found, callback)->
      
      console.info "user_mongo_found_id = ", user_mongo_found._id;
      now = new Date();
      current_timezone_offset = now.getTimezoneOffset()/60;

      need_add_hours = current_timezone_offset - user.time_dif

      console.info 'time_zone', user.time_dif, current_timezone_offset, need_add_hours;


      one_note = new Tree;
      objectId_to_id["1"] = mongoose.Types.ObjectId().toString()
      objectId_to_id[1] = objectId_to_id["1"] 
      one_note['_id'] = objectId_to_id["1"]
      one_note['title'] = '4tree'
      one_note['user_id'] = user_mongo_found._id
      one_note['del'] = 0
      one_note['folder'] = 'main'
      one_note.save (err, result)->
        console.info 'Main_tree = ',err,result


      async.eachLimit rows, 50, (row, callback)->
        #console.info "row = ", row

        one_note = new Tree;

        if !objectId_to_id[row.parent_id]           
          objectId_to_id[row.parent_id] = mongoose.Types.ObjectId();
      
        if !objectId_to_id[row.id]           
          objectId_to_id[row.id] = mongoose.Types.ObjectId();


        one_note['_id'] = objectId_to_id[row.id]
        one_note['title'] = row.title
        one_note['text'] = row.text
        one_note['parent_id'] = objectId_to_id[row.parent_id]
        one_note['parent'] = row.parent_id
        one_note['pos'] = row.position
        one_note['user_id'] = user_mongo_found._id
        one_note['icon'] = row.node_icon if row.node_icon
        one_note['del'] = 1 if row.del != 0
        one_note['old_tag'] = row.smth if row.smth

        console.info "P = ",one_note.parent_id, one_note._id if row.parent_id == 1 or row.parent_id == '1'

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

        if row.parent_id != 0
          one_note.save (err, result)->
            objectId_to_id[row.id] = result._id;
            callback err, rows
        else
          callback()
      , (err)->
        console.info "THE END = ", true
        callback err


  ], (err, rows)->
    res.send('ok');

    
