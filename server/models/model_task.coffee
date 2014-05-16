mongoose = require("mongoose")
saveDiff = require('../../models/_js/saveDiff.js');

Schema = mongoose.Schema
treeSchema = new Schema (
  'tree_id': String
  'user_id': { type: String, es_indexed: true } 
  'del': { type: Number, default: 0 }
  'title':  { type: String, es_indexed: true }
  'date_on': { type: Boolean }
  'date1': Date
  'date2': Date
  'hide_in_todo': Boolean
  'parent_id': String
  '_sha1': String
  'did': Boolean
  'color': String
  '_sync': [ { key: String, diff: { '_tm': String } } ]
  'created': Date
  'importance': { type: Number, default: 50 }
  '_tm': Date
)

mongoosastic = require('mongoosastic')
treeSchema.plugin(mongoosastic);

Task = module.exports = mongoose.model("Task", treeSchema)



treeSchema.post 'init', ()->
  this._original = this.toObject();


treeSchema.pre 'save', (next)->
  #console.info 'post saving... doc... ', @, 'was: ',this._original
  saveDiff.saveDiff(Task, @, this._original).then ()->

    next()
