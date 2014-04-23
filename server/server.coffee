cluster = require('cluster')
http = require('http')
numCPUs = require('os').cpus().length
$ = require('jquery')

if cluster.isMaster
  server = require('http').createServer()
  io = require('socket.io').listen(server)
  RedisStore = require('socket.io/lib/stores/redis')
  redis = require('socket.io/node_modules/redis')
  publisher = redis.createClient
  subscriber = redis.createClient

  io = require('socket.io').listen(server, {
    log: false
  })

  io.set('store', new RedisStore({
    redisPub: redis.createClient()
    redisSub: redis.createClient()
    redisClient: redis.createClient()
  }))

  workers = {}
  allWorkers = {}

  numCPUs = 0;

  for i in [0..numCPUs]
    worker = cluster.fork();
    allWorkers[worker.process.pid] = worker;

  cluster.on 'exit', (worker, code, signal) -> 
    console.log('worker ' + worker.process.pid + ' died');
    worker = cluster.fork();
    delete workerAll[worker.process.pid];
    workerAll[worker.process.pid] = worker;

  cluster.on 'fork', (worker, address) ->
    console.info("FORK: ", worker.id);
  
else 
  # САМ ФОРК (их может быть столько, сколько процессоров)
  express = require("express")
  app = express()
  server = require("http").createServer(app)
  RedisStore = require("socket.io/lib/stores/redis")
  redis = require("socket.io/node_modules/redis")
  _ = require('underscore');
  mysql = require('mysql');
  md5 = require('MD5');
  Pool = require('mysql-simple-pool');
  async = require('async');
  fs = require('fs');

  app.use(express.json({limit: '50mb'}));
  app.use(express.urlencoded({limit: '50mb'}));

  MongoClient = require('mongodb').MongoClient

  Imap = require('imap');

  notifier = require('mail-notifier');

  imap = {
    username: "4tree@4tree.ru",
    user: "4tree@4tree.ru"
    password: "uuS4foos_VE",
    host: "mail.4tree.ru",
    port: 993, # imap port
    secure: true # use secure connection
    tls: true
    debug: (msg)->
      console.info "MAIL: ", msg
  }

  image_service = require('../scripts/_js/imagemagic.service.js')

  image_service.image_make_white('user_data/clipboard.PNG')
  
  #console.info image_service.image_make_white('../val.jpg')

  notifier_instance = notifier(imap).on 'mail', (mail)->
    mail_service.save_mail_to_tree(mail)

  notifier_instance.start() if false

  ###
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

  imap_connection = new Imap(imap);


  openInbox = (cb)->
    imap.openBox('INBOX', false, cb);

  imap_connection.once 'ready', ()->
    console.info 'Mail Ready!!!!!!!!!!!!!!!!!'

  imap_connection.on 'error', (err)->
    console.info 'Mail error', err

  imap_connection.connect();
  ###

  #Сервис обслуживающий электронную почту


  #OAUTH2

  mongoose = require("mongoose")
  mongoose.set("debug", false)
  uristring = "mongodb://127.0.0.1:27017/4tree"


  # Makes connection asynchronously. Mongoose will queue up database
  # operations and release them when the connection is complete.
  mongoose.connect uristring, (err, res) ->
    if err
      console.log "ERROR connecting to: " + uristring + ". " + err

  mongoose.connection.on 'connected', ()->
    console.log 'Mongoose default connection open to ' + uristring

  mongoose.connection.on 'error', (err)->
    console.log 'Mongoose Error: '+err

  mongoose.connection.on 'disconnected', ()->
    console.log 'Mongoose Disconnected'

  # МОДЕЛИ ########################################

  require '../models/_js/model_tree.js'
  require '../models/_js/model_task.js'

  Tree = mongoose.model('Tree');
  Task = mongoose.model('Task');

  elasticsearch = require 'elasticsearch'
  es_client = new elasticsearch.Client {
    host: localhost:9200
    log: '' #'trace'
  }

  if false
    es_client.ping({
      requestTimeout: 1000,
      #undocumented params are appended to the query string
      hello: "elasticsearch!"
    }).then ()->
      if true
        setTimeout ()->
          stream = Tree.synchronize();
          count = 0;

          stream.on 'data', (err, doc)->
            count++
          stream.on 'close', ()->
            console.log('indexed '+count)

          Task.synchronize();


          stream.on 'error', (err)->
            console.log err


  global._db_models = {
    tree: Tree
    tasks: Task
  }

  if false
    Task.remove {}, ()->
      task = new Task( {
        title: 'first_task'
        user_id: '5330ff92898a2b63c2f7095f'
        tree_id: '534020016b84290000acfbda'
        date1: new Date()
        date2: new Date()
        tm: new Date()
      } )
      task.save();
      task = new Task( {
        title: 'second_task'
        user_id: '5330ff92898a2b63c2f7095f'
        tree_id: '534020016b84290000acfbda'
        date1: new Date()
        date2: new Date()
        tm: new Date()
      } )
      task.save();

  ################################################

  oauthserver = require("node-oauth2-server")
  model = require("node-oauth2-server/examples/mongodb/model.js")
  app.configure ->
    app.oauth = oauthserver(
      model: model # See below for specification
      grants: ["password", "refresh_token"]
      debug: false
    )
    app.use express.bodyParser() # REQUIRED
    return

  app.all "/oauth/token", app.oauth.grant();
  
  app.use(app.oauth.errorHandler());
  ###app.get "/", app.oauth.authorise(), (req, res) ->
    res.send "Secret area"
    return
  ###
  app.use app.oauth.errorHandler()
  #OAUTH2 end


  OAuthUsersModel = mongoose.model('OAuthUsers');

  mail_service = {
    #сохраняем входящие письма по пользователям
    save_mail_to_tree: (mail)->
      @getUserId(mail).then (result)->
        console.info "FOUND CLIENTS = ", result;
      if(mail.attachments)
        async.each mail.attachments, (file, callback)->
          console.info "save_file", file
          fs.writeFile "user_data/"+file.contentId+file.fileName, file.content, (err)->
            console.info "error", err
            callback(err)
    #выленяем email из строки from и to
    getUserId: (mail)->
      mythis = @;
      dfd = $.Deferred()
      check_emails = [];
      mymails = mail['from'].concat(mail['to']) if mail['to']
      mymails = mymails.concat(mail['cc']) if mail['cc'];
      _.each mymails, (from)->
        console.info "ADRESS", from
        check_emails.push(from.address)
      check_emails = _.uniq check_emails, (item)->
        item
      found_clients = [];
      async.each check_emails, (item, callback)->
        mythis.findUserByEmail(item).then (result)->
          found_clients = found_clients.concat(result) if result;
          callback();
      , ()->
        dfd.resolve(found_clients);

      return dfd.promise();
    findUserByEmail: (email)->
      dfd = $.Deferred()
      OAuthUsersModel.find {email: email}, (err, result)->
        dfd.resolve(result)
      dfd.promise()
  }



  db = undefined;

  MongoClient.connect "mongodb://127.0.0.1:27017/4tree", (err, mydb)->
    db = mydb;
    global.db = db;

  global.pool = new Pool(100, {
    host: '127.0.0.1',
    user: 'root',
    password: 'See6thoh',
    database: 'h116'
  }); 

  redis_client = redis.createClient()
  subscriber = redis.createClient()
  publisher = redis.createClient()
  subscriber.on "error", (e) ->
    console.log "subscriber", e.stack

  publisher.on "error", (e) ->
    console.log "publisher", e.stack

  io = require('socket.io').listen(server, {
    log: false
  })


  io.set('store', new RedisStore({
    redisPub: redis.createClient()
    redisSub: redis.createClient()
    redisClient: redis.createClient()
  }))


  app.configure ->
    app.use express.compress()

    #var server_is = "dist";
    server_is = "app"
    app.use express.static(__dirname + "/../../" + server_is + "/images",
    maxAge: 86400000
    )
    app.use express.static(__dirname + "/../../" + server_is + "/images/do_type",
    maxAge: 86400000
    )
    app.use express.static(__dirname + "/../../" + server_is)

  subscriber.subscribe 'chanel_2'
  subscriber.subscribe 'chanel_1'

  diff = require('../changeset/_js/changeset.js');

  logJson = require('../logJson/_js/logJson.js');


  subscriber.on "message", (chanel, message)->
    try message = JSON.parse message catch 
    console.info chanel, message[0], message[1]

  exports.newMessage = (request, response)->
    console.info 'hi!'
    publisher.publish('chanel_1', JSON.stringify ['user_connected','John Wezel'])
    response.send('HELLO', 'IM BODY!!!')
    collection = db.collection("tree")
    collection.update {id:146}, {$push: {tags: {enter_time: new Date()}}}, {multi: false, upsert:true}, (err, result)->
      console.info result, err
  exports.sync = (req, res)->
    token = req.query.token
    notes = req.body.sync_data_to_send.notes
    async.eachLimit notes, 50, (note, callback)->
      _id = note._id
      delete note._id
      Tree.update2 { _id }, note, (err)->
        console.info err if err
        callback err
    , (callback)->
      res.send true

  users_connection = {}

  io.sockets.on "connection", (socket) ->
    user_id = undefined;
    token = undefined;
    console.info 'connection established'

    socket.on "disconnect", (socket) ->
      #users_connection[data]
      console.info 'user_disconected'

    socket.emit "who_are_you",
      hello: "world"

    socket.on 'sync_data', (data)->
      console.info 'syncing...', data
      exports.sync_db_universal(data).then (answer)->
        socket.emit 'sync_answer', answer;

    socket.on "i_am_user", (data) ->
      if data
        user_id = '5330ff92898a2b63c2f7095f';
        users_connection[data._id] = [] if !users_connection[data._id]
        users_connection[data._id].push( { user_instance: data.user_instance, socket: socket } );
        token = data;
        console.log 'token = ', data
      return

    return

  exports.sync_db = (req, res)->
    data = req.body;
    exports.sync_db_universal(data).then (answer)->
      res.send answer;


  exports.sync_db_universal = (data)->
    dfd = $.Deferred()
    user_instance = data.user_instance;
    user_id = data.user_id;
    console.info { user_id }
    databases = data.diff_journal
    new_elements = data.new_elements
    last_sync_time = data.last_sync_time
    start_sync_time = new Date();
    #массив для отметки тех данных, которые не записались, их нужно отправить клиенту для обновления
    send_to_client_becouse_of_not_saving = {}; 
    confirm_about_sync_success_for_client = {};
    saving_complete = false;

    async.eachLimit Object.keys(new_elements), 10, (db_name, callback)->
      new_elements_one_table = new_elements[db_name];
      #Обходим все новые элементы в таблице
      async.eachLimit Object.keys(new_elements_one_table), 10, (item_name, callback2)->
        one_new_element = new_elements[db_name][item_name]
        console.info 'need_to_create '+item_name, one_new_element
        model = new global._db_models[db_name](one_new_element)
        model.tm = new Date(start_sync_time)
        model.save ()->
          saving_complete = true;
          console.info 'Сохранил новый элемент '+item_name;
          confirm_about_sync_success_for_client[db_name] = [] if !confirm_about_sync_success_for_client[db_name]
          confirm_about_sync_success_for_client[db_name].push( {_id:one_new_element._id, tm: new Date(last_sync_time) } )
          callback2();
      , ()->
        callback();
    , ()->
      async.eachLimit Object.keys(databases), 10, (db_name, callback)->
        this_db = databases[db_name];
        #Обходим все изменившиеся элементы в таблице
        async.eachLimit Object.keys( this_db ), 10, (item_name, item_callback)->
          this_item = this_db[item_name];
          global._db_models[db_name].findOne {_id: item_name}, (err, doc)->
            if (doc)
              doc._sync = [] if !doc._sync
              #обхожу все diff и применяю те, которые изменились позже, чем в базе
              _.each Object.keys(this_item), (item_diff)->
                df = this_item[item_diff]
                found = _.find doc._sync, (el)->
                  el.key == item_diff
                if !found
                  doc._sync.push ({key: item_diff, diff: { 'tm': df.tm } })
                else
                  time_of_sever_change = found.diff.tm;
                  time_of_client_change = df.tm;
                  console.info 'tm_server', time_of_sever_change, 'tm_client', time_of_client_change
                  if time_of_sever_change > time_of_client_change
                    #данные обновлять нельзя, так как они изменены раньше, чем отправил кто-то другой
                    console.info 'Не сохраняю в базу (время не то)', doc.title
                    send_to_client_becouse_of_not_saving[db_name] = [] if !send_to_client_becouse_of_not_saving[db_name]
                    send_to_client_becouse_of_not_saving[db_name].push( {db_name: db_name, item_id: doc._id} )
                  else
                    #сохранение разрешено
                    saving_complete = true;
                    console.info 'Сохраняю в базу', doc.title
                    found.diff.tm = df.tm;
                    doc.tm = new Date(start_sync_time); #Сохраняю время изменения, для последующих отборов
                    diff.apply([df], doc, true);
                    confirm_about_sync_success_for_client[db_name] = [] if !confirm_about_sync_success_for_client[db_name]
                    confirm_about_sync_success_for_client[db_name].push( {_id:doc._id, tm: doc.tm } )
                #console.info '_sync=', doc._sync, 'dif=', item_diff, 'df=', df;
                
              #logJson "doc=", doc
              doc.save (err)->
                console.info 'item_saved!'
                item_callback(err);
            else 
              console.info 'Странно, не могу найти новый элемент в базе'

        , ()->
          callback();
      , (callback)->
        #Собираю все новые данные, чтобы отправить клиенту
        data_to_client = {};
        data_to_others = {};
        async.each Object.keys(global._db_models), (db_name, callback)->
          db_model = global._db_models[db_name];
          db_model.find {tm: {$gt: last_sync_time}}, (err, docs)->

            console.info 'По дате я отобрал '+docs.length+'шт. в '+db_name
            sync_confirm_id = _.uniq confirm_about_sync_success_for_client[db_name], (el)->
              el._id

            docs_without_new = _.reject docs, (doc)->
              found = _.find sync_confirm_id, (id_element)->
                doc._id.toString() == id_element._id.toString()
              return found

            console.info 'Отправлю на сервер ('+docs_without_new.length+' шт) за исключением: ', sync_confirm_id

            data_to_client[db_name] = {
              new_data: docs_without_new
              sync_confirm_id: sync_confirm_id
            }
            data_to_others[db_name] = {
              new_data: docs
              sync_confirm_id: []
            }
            callback(); #конец обработки одной из таблиц
        , (err)->
          if users_connection[user_id] and saving_complete
            user_instance = user_instance;
            connected_sockets = users_connection[user_id];
            logJson 'Emit to clients', data_to_others
            _.each connected_sockets, (one_socket)->
              if user_instance.toString() != one_socket.user_instance.toString()
                one_socket.socket.emit('need_sync', data_to_others) 
                console.info "Socket emit ", one_socket.user_instance.toString()
          dfd.resolve( data_to_client )

    dfd.promise();

  ###
  ###


  search = {
    searchString: (string, dont_need_highlight)->
      dfd = new $.Deferred()
      all_results = {}
      db_names = ['trees', 'tasks'];
      async.each db_names, (db_name, callback)->        
        all_results[db_name] = {};
        console.info '!!!', db_name
        query = { 
          index: db_name
          body: {
            query: { 
              "filtered": {
                "query": {
                  "fuzzy_like_this": { 
                    fields: ["title", "text"]
                    like_text: string 
                    fuzziness: 0.9
                  }                                        
                }
                "filter": {
                  "and": [
                    "term": {
                      user_id: "5330ff92898a2b63c2f7095f"
                    }                    
                  ]
                }
              }
            }
            size: 20
            highlight: {
              "number_of_fragments": 1
              #"encoder": "html"
              #escape_html: true
              fields: {
                title: { "type": "plain"}
                text:  { "type": "plain"}
              }
            }
            fields: ["_id", "highlight", "_score", "title", "user_id"]          
          }
        }
        if dont_need_highlight
          query.body.highlight.fields = {title:{type:'plain'}}

        es_client.search query, (err, results)->
          all_results[db_name] = results;
          callback(err);
      , (err)->
        console.info 'all', all_results
        dfd.resolve(all_results)

      dfd.promise()

  }

  exports.searchMe = (req, res)->
    searchString = req.query.search;
    dont_need_highlight = req.query.dont_need_highlight;
    if searchString
      search.searchString(searchString, dont_need_highlight).then (results)->
        res.send(results)
    else
      res.send([])

  exports.suggestMe = (req, res)->
    searchString = req.query.search;
    Tree.search {
        suggest: {
          text: searchString
        }
    }, (err, results)->
      res.send(results)

  exports.uploadImage = (req, res)->
    if req.files
      fs.readFile req.files.file.path, (err, data)->
        newPath = "user_data/sex.jpeg";
        fs.writeFile newPath, data, (err)->
          if !err
            answer = {
              'filelink': 'user_data/sex.jpeg'
            }
            res.send(answer)
          else
            res.send(false)
    if req.body.data
      fs.writeFile "user_data/clipboard.png", new Buffer(req.body.data, 'base64'), (err)->
        if !err
          answer = {
            'filelink': 'user_data/clipboard.png'
          }
          image_service.image_make_white('user_data/clipboard.png')
          res.send(answer)
        else
          res.send(false)



  app.post('/api/v1/sync', app.oauth.authorise(), exports.sync);

  app.post('/api/v1/sync_db', app.oauth.authorise(), exports.sync_db);

  app.post('/api/v1/uploadImage', exports.uploadImage);

  app.get('/api/v1/message', exports.newMessage);

  app.get('/api/v1/search', exports.searchMe);

  app.get('/api/v1/suggest', exports.suggestMe);

  app.get '/api/import_from_mysql', (req, res)->
    (require('../get/_js/server_import_from_mysql')).get(req, res)

  app.get '/api/v2/tree', app.oauth.authorise(), (req, res)->
    (require('../get/_js/server_get_all_tree')).get(req, res)

  app.get '/api/v2/fake_names', (req, res)->
    (require('../get/_js/server_fake_fpk_names')).get(req, res)


  server.listen( 8888 );