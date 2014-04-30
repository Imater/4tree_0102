mongoose = require("mongoose")

Schema = mongoose.Schema

diffSchema = new Schema (
  'db_id': { type: String } 
  'patch': { type: Object }
  'body': { type: Object }
  'new_body': { type: Object }
  'user_id': { type: String } 
  'machine': { type: String } 
  'db_name': { type: String } 
  '_sha1': { type: String }
  'del': { type: Number, default: 0 }
  '_tm': { type: Date }
  'EMPTY_BAD': { type: String } 
)

#mongoosastic = require('mongoosastic')
#diffSchema.plugin(mongoosastic, {index: 'texts', type:'text'});

Diff = module.exports = mongoose.model("Diff", diffSchema)