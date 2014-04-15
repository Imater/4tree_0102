logJson = (title, data, compact)->
  time = new Date();
  hours = time.getHours();
  minutes = time.getMinutes();
  seconds = time.getSeconds();
  console.info '\x1b[35m['+hours+':'+minutes+':'+seconds+']\x1b[0m '+title+' = \x1b[32m'+ JSON.stringify(data, false, if !compact then '  ') + '\x1b[0m'

module.exports = logJson