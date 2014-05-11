winston = require('winston');
require('winston-logstash');

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
    new (winston.transports.Logstash)({
      port: 28777,
      node_name: 'my node name',
      host: '127.0.0.1'
      level: 'sync'
    })
    new (winston.transports.Console)({ level: 'sync', colorize: 'true' })
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

winston.addColors(customLevels.colors)

exports.mylog = new (winston.Logger)(customLevels)

