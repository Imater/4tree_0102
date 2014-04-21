mongoose = require("mongoose")
Schema = mongoose.Schema
treeSchema = new Schema (
  'tree_id': String
  'user_id': { type: String, es_indexed: true } 
  'del': { type: Number, default: 0 }
  'title':  { type: String, es_indexed: true } 
  'date1': Date
  'date2': Date
  'parent_id': String
  '_sync': [ { key: String, diff: { 'tm': String } } ]
  'tm': Date
)

mongoosastic = require('mongoosastic')
treeSchema.plugin(mongoosastic);

Task = module.exports = mongoose.model("Task", treeSchema)