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

  notifier_instance = notifier(imap).on 'mail', (mail)->
    mail_service.save_mail_to_tree(mail)

  notifier_instance.start()

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
  mongoose.set("debug", true)
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

  require '../models/_js/model_tree.js'

  Tree = mongoose.model('Tree');

  test_tmp = ()->
    require '../models/_js/model_tree.js'

    Tree = mongoose.model('Tree');

    if true
      t = Tree.create {
        Country: "England"
        GroupName: "D"
        CreatedOn: Date.now()
        Tags: { title: "Hi!!!" }
      } 

    query = {Country: "England"}

    tm = new Date().getTime();
    Tree.find {}, (err, docs)->
      async.eachLimit docs, 50, (doc, callback)->
        doc.GroupName = "MY COUNTRY-999"+ new Date().getTime()
        doc.save(callback)
      , ()->
        console.info "SPEED", new Date().getTime() - tm


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
      Tree.update { _id }, note, (err)->
        console.info err if err
        callback err
    , (callback)->
      res.send true

  app.post('/api/v1/sync', app.oauth.authorise(), exports.sync);

  app.get('/api/v1/message', exports.newMessage);
  app.get '/api/import_from_mysql', (req, res)->
    (require('../get/_js/server_import_from_mysql')).get(req, res)

  app.get '/api/v2/tree', app.oauth.authorise(), (req, res)->
    (require('../get/_js/server_get_all_tree')).get(req, res)

  app.get '/api/v2/fake_names', (req, res)->
    (require('../get/_js/server_fake_fpk_names')).get(req, res)


  server.listen( 8888 );