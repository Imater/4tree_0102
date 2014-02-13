numCPUs = require('os').cpus().length
cluster = require('cluster')

if cluster.isMaster
	console.info('im master');
	numCPUs = 0;
	for i in [0..numCPUs]
    	worker = cluster.fork();

else
	express = require('express');
	console.info('im slave')

	app = express();
	app.get '/api', (request, response)->
		console.info 'UPS!'
	app.get '/hello.txt', (req, res)->
	  body = 'Hello World';
	  res.setHeader('Content-Type', 'text/plain');
	  res.setHeader('Content-Length', Buffer.byteLength(body));
	  res.end(body);
	app.listen(8888);
	console.log('Listening on port 8888');