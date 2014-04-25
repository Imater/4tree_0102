// Generated by CoffeeScript 1.6.3
/*
# CoffeeDoc example documentation #

This is a module-level docstring, and will be displayed at the top of the module documentation.
Documentation generated by [CoffeeDoc](http://github.com/omarkhan/coffeedoc)
*/


(function() {
  var $, Imap, MongoClient, OAuthUsersModel, Pool, RedisStore, Task, Tree, allWorkers, app, async, cluster, db, debug, diff, elasticsearch, es_client, express, fs, http, i, image_service, imap, io, jobs, kue, kue_cleanup, logJson, mail_service, md5, model, mongoose, mysql, notifier, notifier_instance, numCPUs, oauthserver, publisher, redis, redis_client, search, server, subscriber, uristring, users_connection, worker, workers, _, _i;

  cluster = require('cluster');

  http = require('http');

  numCPUs = require('os').cpus().length;

  $ = require('jquery');

  kue = require('kue');

  jobs = kue.createQueue();

  ({
    sex: function(sex) {
      return console.info(sex);
    }
  });

  if (cluster.isMaster) {
    server = require('http').createServer();
    io = require('socket.io').listen(server);
    RedisStore = require('socket.io/lib/stores/redis');
    redis = require('socket.io/node_modules/redis');
    publisher = redis.createClient;
    subscriber = redis.createClient;
    kue.app.listen(3000);
    io = require('socket.io').listen(server, {
      log: false
    });
    io.set('store', new RedisStore({
      redisPub: redis.createClient(),
      redisSub: redis.createClient(),
      redisClient: redis.createClient()
    }));
    workers = {};
    allWorkers = {};
    numCPUs = 1;
    debug = process.execArgv[0].indexOf('--debug') !== -1;
    console.info('debug', debug, process.execArgv, process.execArgv.indexOf('--debug'));
    cluster.setupMaster({
      execArgv: process.execArgv.filter(function(s) {
        return s !== "--debug";
      })
    });
    for (i = _i = 0; 0 <= numCPUs ? _i <= numCPUs : _i >= numCPUs; i = 0 <= numCPUs ? ++_i : --_i) {
      if (debug) {
        cluster.settings.execArgv.push('--debug=' + (5859 + i));
      }
      worker = cluster.fork();
      if (debug) {
        cluster.settings.execArgv.pop();
      }
      allWorkers[worker.process.pid] = worker;
    }
    cluster.on('exit', function(worker, code, signal) {
      console.log('worker ' + worker.process.pid + ' died');
      worker = cluster.fork();
      delete workerAll[worker.process.pid];
      return workerAll[worker.process.pid] = worker;
    });
    cluster.on('fork', function(worker, address) {
      return console.info("FORK: ", worker.id);
    });
  } else {
    express = require("express");
    app = express();
    server = require("http").createServer(app);
    RedisStore = require("socket.io/lib/stores/redis");
    redis = require("socket.io/node_modules/redis");
    _ = require('underscore');
    mysql = require('mysql');
    md5 = require('MD5');
    Pool = require('mysql-simple-pool');
    async = require('async');
    fs = require('fs');
    kue_cleanup = require('../scripts/kue_cleanup.js');
    jobs.process("test", 5, function(job, done) {
      setTimeout(function() {
        return done();
      }, 5000 + Math.round(Math.random() * 10000));
    });
    jobs.process("recognizeImage", 1, function(job, done) {
      console.info('start recognize ' + job.data.imageUrl + " from process " + job.data.process + ' on ' + process.pid);
      image_service.image_make_white(job.data.imageUrl).then(function(text) {
        console.info('TEXT = ', text, 'on process ' + process.pid);
        return done();
      });
    });
    app.use(express.json({
      limit: '50mb'
    }));
    app.use(express.urlencoded({
      limit: '50mb'
    }));
    MongoClient = require('mongodb').MongoClient;
    Imap = require('imap');
    notifier = require('mail-notifier');
    imap = {
      username: "4tree@4tree.ru",
      user: "4tree@4tree.ru",
      password: "uuS4foos_VE",
      host: "mail.4tree.ru",
      port: 993,
      secure: true,
      tls: true,
      debug: function(msg) {
        return console.info("MAIL: ", msg);
      }
    };
    image_service = require('../scripts/_js/imagemagic.service.js');
    notifier_instance = notifier(imap).on('mail', function(mail) {
      return mail_service.save_mail_to_tree(mail);
    });
    if (false) {
      notifier_instance.start();
    }
    /*
    process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";
    
    imap_connection = new Imap(imap);
    
    
    openInbox = (cb)->
      imap.openBox('INBOX', false, cb);
    
    imap_connection.once 'ready', ()->
      console.info 'Mail Ready!!!!!!!!!!!!!!!!!'
    
    imap_connection.on 'error', (err)->
      console.info 'Mail error', err
    
    imap_connection.connect();
    */

    mongoose = require("mongoose");
    mongoose.set("debug", false);
    uristring = "mongodb://127.0.0.1:27017/4tree";
    mongoose.connect(uristring, function(err, res) {
      if (err) {
        return console.log("ERROR connecting to: " + uristring + ". " + err);
      }
    });
    mongoose.connection.on('connected', function() {
      return console.log('Mongoose default connection open to ' + uristring);
    });
    mongoose.connection.on('error', function(err) {
      return console.log('Mongoose Error: ' + err);
    });
    mongoose.connection.on('disconnected', function() {
      return console.log('Mongoose Disconnected');
    });
    require('../models/_js/model_tree.js');
    require('../models/_js/model_task.js');
    Tree = mongoose.model('Tree');
    Task = mongoose.model('Task');
    elasticsearch = require('elasticsearch');
    es_client = new elasticsearch.Client({
      host: {
        localhost: 9200
      },
      log: ''
    });
    if (false) {
      es_client.ping({
        requestTimeout: 1000,
        hello: "elasticsearch!"
      }).then(function() {
        if (true) {
          return setTimeout(function() {
            var count, stream;
            stream = Tree.synchronize();
            count = 0;
            stream.on('data', function(err, doc) {
              return count++;
            });
            stream.on('close', function() {
              return console.log('indexed ' + count);
            });
            Task.synchronize();
            return stream.on('error', function(err) {
              return console.log(err);
            });
          });
        }
      });
    }
    global._db_models = {
      tree: Tree,
      tasks: Task
    };
    if (false) {
      Task.remove({}, function() {
        var task;
        task = new Task({
          title: 'first_task',
          user_id: '5330ff92898a2b63c2f7095f',
          tree_id: '534020016b84290000acfbda',
          date1: new Date(),
          date2: new Date(),
          tm: new Date()
        });
        task.save();
        task = new Task({
          title: 'second_task',
          user_id: '5330ff92898a2b63c2f7095f',
          tree_id: '534020016b84290000acfbda',
          date1: new Date(),
          date2: new Date(),
          tm: new Date()
        });
        return task.save();
      });
    }
    oauthserver = require("node-oauth2-server");
    model = require("node-oauth2-server/examples/mongodb/model.js");
    app.configure(function() {
      app.oauth = oauthserver({
        model: model,
        grants: ["password", "refresh_token"],
        debug: false
      });
      app.use(express.bodyParser());
    });
    app.all("/oauth/token", app.oauth.grant());
    app.use(app.oauth.errorHandler());
    /*
      app.get "/", app.oauth.authorise(), (req, res) ->
      res.send "Secret area"
      return
    */

    app.use(app.oauth.errorHandler());
    OAuthUsersModel = mongoose.model('OAuthUsers');
    mail_service = {
      save_mail_to_tree: function(mail) {
        this.getUserId(mail).then(function(result) {
          return console.info("FOUND CLIENTS = ", result);
        });
        if (mail.attachments) {
          return async.each(mail.attachments, function(file, callback) {
            console.info("save_file", file);
            return fs.writeFile("user_data/" + file.contentId + file.fileName, file.content, function(err) {
              console.info("error", err);
              return callback(err);
            });
          });
        }
      },
      getUserId: function(mail) {
        /* Пишу тут*/

        var check_emails, dfd, found_clients, mymails, mythis;
        mythis = this;
        dfd = $.Deferred();
        check_emails = [];
        if (mail['to']) {
          mymails = mail['from'].concat(mail['to']);
        }
        if (mail['cc']) {
          mymails = mymails.concat(mail['cc']);
        }
        _.each(mymails, function(from) {
          console.info("ADRESS", from);
          return check_emails.push(from.address);
        });
        check_emails = _.uniq(check_emails, function(item) {
          return item;
        });
        found_clients = [];
        async.each(check_emails, function(item, callback) {
          return mythis.findUserByEmail(item).then(function(result) {
            if (result) {
              found_clients = found_clients.concat(result);
            }
            return callback();
          });
        }, function() {
          return dfd.resolve(found_clients);
        });
        return dfd.promise();
      },
      findUserByEmail: function(email) {
        var dfd;
        dfd = $.Deferred();
        OAuthUsersModel.find({
          email: email
        }, function(err, result) {
          return dfd.resolve(result);
        });
        return dfd.promise();
      }
    };
    db = void 0;
    MongoClient.connect("mongodb://127.0.0.1:27017/4tree", function(err, mydb) {
      db = mydb;
      return global.db = db;
    });
    global.pool = new Pool(100, {
      host: '127.0.0.1',
      user: 'root',
      password: 'See6thoh',
      database: 'h116'
    });
    redis_client = redis.createClient();
    subscriber = redis.createClient();
    publisher = redis.createClient();
    subscriber.on("error", function(e) {
      return console.log("subscriber", e.stack);
    });
    publisher.on("error", function(e) {
      return console.log("publisher", e.stack);
    });
    io = require('socket.io').listen(server, {
      log: false
    });
    io.set('store', new RedisStore({
      redisPub: redis.createClient(),
      redisSub: redis.createClient(),
      redisClient: redis.createClient()
    }));
    app.configure(function() {
      var server_is;
      app.use(express.compress());
      server_is = "app";
      app.use(express["static"](__dirname + "/../../" + server_is + "/images", {
        maxAge: 86400000
      }));
      app.use(express["static"](__dirname + "/../../" + server_is + "/images/do_type", {
        maxAge: 86400000
      }));
      return app.use(express["static"](__dirname + "/../../" + server_is));
    });
    subscriber.subscribe('chanel_2');
    subscriber.subscribe('chanel_1');
    diff = require('../changeset/_js/changeset.js');
    logJson = require('../logJson/_js/logJson.js');
    subscriber.on("message", function(chanel, message) {
      try {
        message = JSON.parse(message);
      } catch (_error) {

      }
      return console.info(chanel, message[0], message[1]);
    });
    exports.newMessage = function(request, response) {
      var collection;
      console.info('hi!');
      publisher.publish('chanel_1', JSON.stringify(['user_connected', 'John Wezel']));
      response.send('HELLO', 'IM BODY!!!');
      collection = db.collection("tree");
      return collection.update({
        id: 146
      }, {
        $push: {
          tags: {
            enter_time: new Date()
          }
        }
      }, {
        multi: false,
        upsert: true
      }, function(err, result) {
        return console.info(result, err);
      });
    };
    exports.sync = function(req, res) {
      var notes, token;
      token = req.query.token;
      notes = req.body.sync_data_to_send.notes;
      return async.eachLimit(notes, 50, function(note, callback) {
        var _id;
        _id = note._id;
        delete note._id;
        return Tree.update2({
          _id: _id
        }, note, function(err) {
          if (err) {
            console.info(err);
          }
          return callback(err);
        });
      }, function(callback) {
        return res.send(true);
      });
    };
    exports.sync_db = function(req, res) {
      var data;
      data = req.body;
      return exports.sync_db_universal(data).then(function(answer) {
        return res.send(answer);
      });
    };
    exports.sync_db_universal = function(data, socket) {
      var confirm_about_sync_success_for_client, databases, dfd, last_sync_time, new_elements, saving_complete, send_to_client_becouse_of_not_saving, start_sync_time, user_id, user_instance;
      dfd = $.Deferred();
      user_instance = data.user_instance;
      user_id = data.user_id;
      console.info({
        user_id: user_id
      });
      databases = data.diff_journal;
      new_elements = data.new_elements;
      last_sync_time = data.last_sync_time;
      start_sync_time = new Date();
      send_to_client_becouse_of_not_saving = {};
      confirm_about_sync_success_for_client = {};
      saving_complete = false;
      async.eachLimit(Object.keys(new_elements), 10, function(db_name, callback) {
        var new_elements_one_table;
        new_elements_one_table = new_elements[db_name];
        return async.eachLimit(Object.keys(new_elements_one_table), 10, function(item_name, callback2) {
          var one_new_element;
          one_new_element = new_elements[db_name][item_name];
          console.info('need_to_create ' + item_name, one_new_element);
          model = new global._db_models[db_name](one_new_element);
          model.tm = new Date(start_sync_time);
          return model.save(function() {
            saving_complete = true;
            console.info('Сохранил новый элемент ' + item_name);
            if (!confirm_about_sync_success_for_client[db_name]) {
              confirm_about_sync_success_for_client[db_name] = [];
            }
            confirm_about_sync_success_for_client[db_name].push({
              _id: one_new_element._id,
              tm: new Date(last_sync_time)
            });
            return callback2();
          });
        }, function() {
          return callback();
        });
      }, function() {
        return async.eachLimit(Object.keys(databases), 10, function(db_name, callback) {
          var this_db;
          this_db = databases[db_name];
          return async.eachLimit(Object.keys(this_db), 10, function(item_name, item_callback) {
            var this_item;
            this_item = this_db[item_name];
            return global._db_models[db_name].findOne({
              _id: item_name
            }, function(err, doc) {
              if (doc) {
                if (!doc._sync) {
                  doc._sync = [];
                }
                _.each(Object.keys(this_item), function(item_diff) {
                  var df, found, time_of_client_change, time_of_sever_change;
                  df = this_item[item_diff];
                  found = _.find(doc._sync, function(el) {
                    return el.key === item_diff;
                  });
                  if (!found) {
                    return doc._sync.push({
                      key: item_diff,
                      diff: {
                        'tm': df.tm
                      }
                    });
                  } else {
                    time_of_sever_change = found.diff.tm;
                    time_of_client_change = df.tm;
                    console.info('tm_server', time_of_sever_change, 'tm_client', time_of_client_change);
                    if (time_of_sever_change > time_of_client_change) {
                      console.info('Не сохраняю в базу (время не то)', doc.title);
                      if (!send_to_client_becouse_of_not_saving[db_name]) {
                        send_to_client_becouse_of_not_saving[db_name] = [];
                      }
                      return send_to_client_becouse_of_not_saving[db_name].push({
                        db_name: db_name,
                        item_id: doc._id
                      });
                    } else {
                      saving_complete = true;
                      console.info('Сохраняю в базу', doc.title);
                      found.diff.tm = df.tm;
                      doc.tm = new Date(start_sync_time);
                      diff.apply([df], doc, true);
                      if (!confirm_about_sync_success_for_client[db_name]) {
                        confirm_about_sync_success_for_client[db_name] = [];
                      }
                      return confirm_about_sync_success_for_client[db_name].push({
                        _id: doc._id,
                        tm: doc.tm
                      });
                    }
                  }
                });
                return doc.save(function(err) {
                  console.info('item_saved!');
                  return item_callback(err);
                });
              } else {
                return console.info('Странно, не могу найти новый элемент в базе');
              }
            });
          }, function() {
            return callback();
          });
        }, function(callback) {
          var data_to_client, data_to_others;
          data_to_client = {};
          data_to_others = {};
          return async.each(Object.keys(global._db_models), function(db_name, callback) {
            var db_model;
            db_model = global._db_models[db_name];
            return db_model.find({
              tm: {
                $gt: last_sync_time
              }
            }, function(err, docs) {
              var docs_without_new, sync_confirm_id;
              console.info('По дате я отобрал ' + docs.length + 'шт. в ' + db_name);
              sync_confirm_id = _.uniq(confirm_about_sync_success_for_client[db_name], function(el) {
                return el._id;
              });
              docs_without_new = _.reject(docs, function(doc) {
                var found;
                found = _.find(sync_confirm_id, function(id_element) {
                  return doc._id.toString() === id_element._id.toString();
                });
                return found;
              });
              console.info('Отправлю на сервер (' + docs_without_new.length + ' шт) за исключением: ', sync_confirm_id);
              data_to_client[db_name] = {
                new_data: docs_without_new,
                sync_confirm_id: sync_confirm_id
              };
              data_to_others[db_name] = {
                new_data: docs,
                sync_confirm_id: []
              };
              return callback();
            });
          }, function(err) {
            var connected_sockets;
            if (users_connection[user_id] && saving_complete) {
              user_instance = user_instance;
              connected_sockets = users_connection[user_id];
              logJson('Emit to clients', data_to_others);
              console.info('user:' + user_id);
              socket.broadcast.to('user_id:' + user_id).emit('need_sync', data_to_others, function(err, answer) {
                return console.info('user - ', err, answer);
              });
            }
            return dfd.resolve(data_to_client);
          });
        });
      });
      return dfd.promise();
    };
    /*
    */

    search = {
      searchString: function(string, dont_need_highlight) {
        var all_results, db_names, dfd;
        dfd = new $.Deferred();
        all_results = {};
        db_names = ['trees', 'tasks'];
        async.each(db_names, function(db_name, callback) {
          var query;
          all_results[db_name] = {};
          console.info('!!!', db_name);
          query = {
            index: db_name,
            body: {
              query: {
                "filtered": {
                  "query": {
                    "fuzzy_like_this": {
                      fields: ["title", "text"],
                      like_text: string,
                      fuzziness: 0.9
                    }
                  },
                  "filter": {
                    "and": [
                      {
                        "term": {
                          user_id: "5330ff92898a2b63c2f7095f"
                        }
                      }
                    ]
                  }
                }
              },
              size: 20,
              highlight: {
                "number_of_fragments": 1,
                fields: {
                  title: {
                    "type": "plain"
                  },
                  text: {
                    "type": "plain"
                  }
                }
              },
              fields: ["_id", "highlight", "_score", "title", "user_id"]
            }
          };
          if (dont_need_highlight) {
            query.body.highlight.fields = {
              title: {
                type: 'plain'
              }
            };
          }
          return es_client.search(query, function(err, results) {
            all_results[db_name] = results;
            return callback(err);
          });
        }, function(err) {
          console.info('all', all_results);
          return dfd.resolve(all_results);
        });
        return dfd.promise();
      }
    };
    exports.searchMe = function(req, res) {
      var dont_need_highlight, searchString;
      if (false) {
        _.each([0, 1, 2, 3, 4, 5], function(el) {
          jobs.create('recognizeImage', {
            imageUrl: './user_data/clipboard.png',
            process: process.pid
          }).save();
          return jobs.create('test', {}).save();
        });
        res.send(true);
        return;
      }
      searchString = req.query.search;
      dont_need_highlight = req.query.dont_need_highlight;
      if (searchString) {
        return search.searchString(searchString, dont_need_highlight).then(function(results) {
          return res.send(results);
        });
      } else {
        return res.send([]);
      }
    };
    exports.suggestMe = function(req, res) {
      var searchString;
      searchString = req.query.search;
      return Tree.search({
        suggest: {
          text: searchString
        }
      }, function(err, results) {
        return res.send(results);
      });
    };
    exports.uploadImage = function(req, res) {
      /*
      Given a module's source code and an AST parser, returns module information
      in the form:
      
          {
              "docstring": "Module docstring",
              "deps": {"dep1": "foo", "dep2": "bar/baz", ...},
              "classes": [class1, class1...],
              "functions": [func1, func2...],
              "privateFunctions": [func1, func2...]
          }
      
      AST parsers are defined in the `parsers.coffee` module
      */

      var user_id;
      user_id = req.query.id;
      if (req.files) {
        fs.readFile(req.files.file.path, function(err, data) {
          var newPath;
          newPath = "user_data/sex.jpeg";
          return fs.writeFile(newPath, data, function(err) {
            var answer;
            if (!err) {
              answer = {
                'filelink': 'user_data/sex.jpeg'
              };
              return res.send(answer);
            } else {
              return res.send(false);
            }
          });
        });
      }
      if (req.body.data) {
        return fs.writeFile("user_data/clipboard.png", new Buffer(req.body.data, 'base64'), function(err) {
          var answer;
          if (!err) {
            answer = {
              'filelink': 'user_data/clipboard.png'
            };
            image_service.image_make_white('user_data/clipboard.png', io.sockets["in"]('user_id:' + user_id));
            return res.send(answer);
          } else {
            return res.send(false);
          }
        });
      }
    };
    users_connection = {};
    io.sockets.on("connection", function(socket) {
      var token, user_id;
      user_id = void 0;
      token = void 0;
      console.info('connection established socket.id = ' + socket.id);
      console.info('socket user_list = ', io.sockets.clients().length);
      socket.on("disconnect", function(socket) {
        return console.info('user_disconected');
      });
      socket.emit("who_are_you", {
        hello: "world"
      });
      socket.on('sync_data', function(data, fn) {
        socket.get('nickname', function(err, name) {
          return logJson('syncing user with name: ', name);
        });
        console.info('syncing...', data);
        return exports.sync_db_universal(data, socket).then(function(answer) {
          socket.volatile.emit('sync_answer', answer);
          return fn('JOOOOOOOOOOPA!!!!!!-!!!!!!!');
        });
      });
      socket.on("i_am_user", function(data) {
        socket.set('nickname', JSON.stringify(data), function() {
          socket.emit('ready');
          return socket.join("user_id:" + data._id);
        });
        if (data) {
          user_id = '5330ff92898a2b63c2f7095f';
          if (!users_connection[data._id]) {
            users_connection[data._id] = [];
          }
          users_connection[data._id].push({
            user_instance: data.user_instance,
            socket: socket
          });
          token = data;
          console.log('token = ', data);
        }
      });
    });
    app.get('/api/v1/socket', function(req, res) {
      var rooms;
      rooms = io.sockets.manager.rooms;
      logJson('rooms', rooms);
      return res.send(rooms);
    });
    app.post('/api/v1/sync', app.oauth.authorise(), exports.sync);
    app.post('/api/v1/sync_db', app.oauth.authorise(), exports.sync_db);
    app.post('/api/v1/uploadImage', exports.uploadImage);
    app.get('/api/v1/message', exports.newMessage);
    app.get('/api/v1/search', exports.searchMe);
    app.get('/api/v1/suggest', exports.suggestMe);
    app.get('/api/import_from_mysql', function(req, res) {
      return (require('../get/_js/server_import_from_mysql')).get(req, res);
    });
    app.get('/api/v2/tree', app.oauth.authorise(), function(req, res) {
      return (require('../get/_js/server_get_all_tree')).get(req, res);
    });
    app.get('/api/v2/fake_names', function(req, res) {
      return (require('../get/_js/server_fake_fpk_names')).get(req, res);
    });
    server.listen(8888);
  }

}).call(this);
