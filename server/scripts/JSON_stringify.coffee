CryptoJS = require("crypto-js");

exports.JSON_stringify = (json)->
  delete_ = (key, value)->
    if key[0] == '_'
      return undefined 
    else
      return value
  string = JSON.stringify json, delete_, 0
  _id = json?._id
  _sha1 = CryptoJS.SHA1(JSON.stringify( string )).toString().substr(0,7)
  {_id, _sha1, string}
