mongoose = require("mongoose")
saveDiff = require('../../models/_js/saveDiff.js');

Schema = mongoose.Schema

textSchema = new Schema (
  'text': { type: String, es_indexed: true }
  'user_id': { type: String, es_indexed: true } 
  'db_name': { type: String, es_indexed: true } 
  '_sha1': { type: String }
  'del': { type: Number, default: 0 }
  '_tm': Date
)

textSchema.post 'save', (doc)->
  console.info 'saving... doc... ', doc if false



textSchema.post 'init', ()->
  this._original = this.toObject();



mongoosastic = require('mongoosastic')
textSchema.plugin(mongoosastic, {index: 'texts', type:'text'});

Text = module.exports = mongoose.model("Text", textSchema)

Text.createMapping (err, mapping)->
  console.info 'mapping', mapping if false

textSchema.pre 'save', (next)->
  #console.info 'post saving... doc... ', @, 'was: ',this._original
  saveDiff.saveDiff(Text, @, this._original).then ()->
    next()
