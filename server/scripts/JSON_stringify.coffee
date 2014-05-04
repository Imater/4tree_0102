CryptoJS = require("crypto-js");
_ = require('underscore');

isObject = (a) ->
  Object::toString.call(a) is "[object Object]"

isArray = (a) ->
  Object::toString.call(a) is "[object Array]"

copyObjectWithSortedKeys = (object) ->
  if isObject(object)
    newObj = {}
    keysSorted = Object.keys(object).sort()
    key = undefined
    for i of keysSorted
      key = keysSorted[i]
      if _.has(object, key)
        newObj[key] = copyObjectWithSortedKeys(object[key]) 
      #Object::hasOwnProperty.call(object, key)
    newObj
  else if isArray(object)
    object.map copyObjectWithSortedKeys
  else
    object

exports.JSON_stringify = (json)->
  delete_ = (key, value)->
    #console.info key
    if key[0] == '_'
      return undefined 
    else
      return value
  #console.info 'j1', json
  json2 = copyObjectWithSortedKeys( JSON.parse( JSON.stringify(json, delete_) ) )
  #console.info 'j2', json
  string = JSON.stringify json2, delete_, 0
  _id = json?._id
  _sha1 = CryptoJS.SHA1(JSON.stringify( string )).toString().substr(0,7)
  console.info {_id, _sha1, string}
  {_id, _sha1, string}
