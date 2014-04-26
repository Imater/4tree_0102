mongoose = require("mongoose")

Schema = mongoose.Schema

textSchema = new Schema (
  'text': { type: String, es_indexed: true }
  'user_id': { type: String, es_indexed: true } 
  'db_name': { type: String, es_indexed: true } 
  'sha3': { type: String }
  'del': { type: Number, default: 0 }
  'tm': Date
)

mongoosastic = require('mongoosastic')
textSchema.plugin(mongoosastic, {index: 'texts', type:'text'});

Text = module.exports = mongoose.model("Text", textSchema)

Text.createMapping (err, mapping)->
  console.info 'mapping', mapping if false