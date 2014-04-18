// Generated by CoffeeScript 1.6.3
(function() {
  var Schema, Tree, mongoose, treeSchema;

  mongoose = require("mongoose");

  Schema = mongoose.Schema;

  treeSchema = new Schema({
    'id': String,
    'title': String,
    'text': String,
    'folder': String,
    'parent_id': Schema.ObjectId,
    'parent': String,
    'pos': {
      type: Number,
      "default": 0
    },
    'user_id': Schema.ObjectId,
    'add_tm': Date,
    'icon': String,
    'color': String,
    'icon_color': String,
    'del': {
      type: Number,
      "default": 0
    },
    'did': {
      type: Date,
      "default": ''
    },
    'old_tag': String,
    'date1': Date,
    'date2': Date,
    'short_link_on': Boolean,
    'web_on': Boolean,
    'share_frends': Boolean,
    'tags': [],
    'counters': [
      {
        'cnt_today': Number,
        'title': String,
        'days': []
      }
    ],
    'hide_in_todo': Boolean,
    'importance': {
      type: Number,
      "default": 50
    },
    '_sync': [
      {
        key: String,
        diff: {
          'tm': String
        }
      }
    ],
    'tm': Date
  });

  Tree = module.exports = mongoose.model("Tree", treeSchema);

}).call(this);
