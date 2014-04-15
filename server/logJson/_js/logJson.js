// Generated by CoffeeScript 1.6.3
(function() {
  var logJson;

  logJson = function(title, data, compact) {
    var hours, minutes, seconds, time;
    time = new Date();
    hours = time.getHours();
    minutes = time.getMinutes();
    seconds = time.getSeconds();
    return console.info('\x1b[35m[' + hours + ':' + minutes + ':' + seconds + ']\x1b[0m ' + title + ' = \x1b[32m' + JSON.stringify(data, false, !compact ? '  ' : void 0) + '\x1b[0m');
  };

  module.exports = logJson;

}).call(this);