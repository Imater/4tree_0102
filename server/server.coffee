cluster = require('cluster')
http = require('http')
numCPUs = require('os').cpus().length
$ = require('jquery')

if cluster.isMaster
	server = require('http').createServer()
	io = require('socket.io').listen(server)
	fs = require('fs')
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
    	allWorkers[worker.process.pid] =  worker;

	cluster.on 'exit', (worker, code, signal) -> 
	  	console.log('worker ' + worker.process.pid + ' died');
	  	worker = cluster.fork();
	  	delete workerAll[worker.process.pid];
	  	workerAll[worker.process.pid] = worker;

  	cluster.on 'fork', (worker, address) ->
    	console.info("FORK:", worker.id);
  
else 
	express = require("express")
	app = express()
	fs = require("fs")
	server = require("http").createServer(app)
	qs = require("querystring")
	RedisStore = require("socket.io/lib/stores/redis")
	redis = require("socket.io/node_modules/redis")
	_ = require('underscore');
	mysql = require('mysql');
	md5 = require('MD5');
	Pool = require('mysql-simple-pool');

	global.pool = new Pool(100, {
		host: '127.0.0.1',
		user: 'root',
		password: 'See6thoh',
		database: 'h116'
	});	

	redis_client = redis.createClient();
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
	  app.use (req, res, next) ->
	    res.setHeader "Access-Control-Allow-Origin", "*"
	    if /\.(png|jpg|jpeg|woff|gif)/g.test(req.url)
	      res.setHeader "Cache-Control", "public, max-age=17280000"
	    else if /bower_components/g.test(req.url) and not (/localhost/.test(req.headers.host))
	      res.setHeader "Cache-Control", "public, max-age=280000"
	    else if /\.(js|css|html|json)/.test(req.url) and not (/localhost/.test(req.headers.host))
	      res.setHeader "Cache-Control", "public, max-age=0"
	    else
	      res.setHeader "Cache-Control", "public, max-age=0"
	    res.setHeader "PROCESSOR", cluster.worker.id
	    next()

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

	server.listen( 8888 );