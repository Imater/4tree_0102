mongoose = require("mongoose")
treeSchema = new mongoose.Schema(
  'id': String
  'title': String
  'text': String
  'parent_id': String
  'parent': String
  'pos': { type: Number, default: 0 }
  'user_id': Number
  'add_tm': Date
  'icon': String
  'del': { type: Number, default: 0 }
  'did': { type: Date, default: '' }
  'old_tag': String
  'date1': Date
  'date2': Date
  'dates': { startDate: Date, endDate: Date }
  'tags': []
  'counters': []
  'hide_in_todo': Boolean
  'importance': { type: Number, default: 50 }
)
Tree = module.exports = mongoose.model("Tree", treeSchema)