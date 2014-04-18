mongoose = require("mongoose")
Schema = mongoose.Schema
treeSchema = new Schema (
  'tree_id': String
  'user_id': String
  'del': { type: Number, default: 0 }
  'title': String
  'date1': Date
  'date2': Date
  '_sync': [ { key: String, diff: { 'tm': String } } ]
  'tm': Date
)
Task = module.exports = mongoose.model("Task", treeSchema)