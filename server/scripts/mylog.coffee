winston = require('winston');
_ = require('underscore')
require('winston-logstash');

safeJsonStringify = (o)->
  cache = []
  JSON.stringify o, (key, value) ->
    if typeof value is "object" and value isnt null

      # Circular reference found, discard key
      return  if cache.indexOf(value) isnt -1

      # Store value in our collection
      cache.push value
    value


### Сервер для ведения логов
bin/logstash -e 'input { tcp { port => 28777 type=>"sample" } } output { elasticsearch { host => localhost } } filter { json { source => "message"} }'
###

winston.add(winston.transports.Logstash, {
  port: 28777,
  node_name: '4TREE',
  host: '127.0.0.1'
});

customLevels = {
  transports: [
  ]
  levels: {
    sync: 0
    info: 1
    debug: 2
    trace: 3
  }
  colors: {
    sync: 'red'
    info: 'yellow'
    debug: 'blue'
    trace: 'magenta'
  }
}

level = 'sync';

customLevels.transports.push new (winston.transports.Logstash)({
    port: 28777,
    node_name: 'my node name',
    host: '127.0.0.1'
    level: level
  })
customLevels.transports.push new (winston.transports.Console)({ level: level, colorize: 'true' })
customLevels.transports.push new (winston.transports.File)({filename: 'mylog.log', level: level})


winston.addColors(customLevels.colors)

mylog = new (winston.Logger)(customLevels)

mynewlog = (() ->
  cached_mylog = mylog.log
  return ()->
    arguments[2] = JSON.parse( safeJsonStringify( arguments[2] ) ) if arguments[2]
    cached_mylog.apply(this, arguments);
)();

mylog = new (winston.Logger)(customLevels)

mylog.log = mynewlog
mylog.info = mynewlog

exports.mylog = mylog



