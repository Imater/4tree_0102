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

	numCPUs = 1;

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

	MongoClient = require('mongodb').MongoClient

	db = undefined;

	MongoClient.connect "mongodb://127.0.0.1:27017/4tree", (err, mydb)->
		db = mydb;
			#console.dir result

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
		app.use express.static(__dirname + "/../" + server_is + "/images",
		maxAge: 86400000
		)
		app.use express.static(__dirname + "/../" + server_is + "/images/do_type",
		maxAge: 86400000
		)
		app.use express.static(__dirname + "/../" + server_is)

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

	app.get('/api/v1/message', exports.newMessage);



	server.listen( 8888 );