mongoose = require("mongoose")

Schema = mongoose.Schema

diffSchema = new Schema (
  'db_id': { type: String } 
  'patch': { type: Object }
  'body': { type: Object }
  'user_id': { type: String } 
  'machine': { type: String } 
  'db_name': { type: String } 
  '_sha3': { type: String }
  'del': { type: Number, default: 0 }
  'tm': Date
)

#mongoosastic = require('mongoosastic')
#diffSchema.plugin(mongoosastic, {index: 'texts', type:'text'});

Diff = module.exports = mongoose.model("Diff", diffSchema)