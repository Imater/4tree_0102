// Generated by CoffeeScript 1.6.3
(function() {
  var Diff, Schema, diffSchema, mongoose;

  mongoose = require("mongoose");

  Schema = mongoose.Schema;

  diffSchema = new Schema({
    'db_id': {
      type: String
    },
    'patch': {
      type: Object
    },
    'body': {
      type: Object
    },
    'user_id': {
      type: String
    },
    'machine': {
      type: String
    },
    'db_name': {
      type: String
    },
    '_sha3': {
      type: String
    },
    'del': {
      type: Number,
      "default": 0
    },
    'tm': Date
  });

  Diff = module.exports = mongoose.model("Diff", diffSchema);

}).call(this);
