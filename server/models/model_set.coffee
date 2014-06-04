mongoose = require("mongoose")
saveDiff = require('../../models/_js/saveDiff.js');

Schema = mongoose.Schema

settingsSchema = new Schema (
  'key': { type: String }
  'value': { type: Object }
  'user_id': { type: String }
  '_sha1': { type: String }
  'del': { type: Number, default: 0 }
  '_tm': Date
)

settingsSchema.post 'save', (doc)->
  console.info 'saving... settings... ', doc if true



settingsSchema.post 'init', ()->
  this._original = this.toObject();



mongoosastic = require('mongoosastic')
settingsSchema.plugin(mongoosastic, {index: 'texts', type:'text'});

Settings = module.exports = mongoose.model("Settings", settingsSchema)

Settings.createMapping (err, mapping)->
  console.info 'mapping', mapping if false

settingsSchema.pre 'save', (next)->
  #console.info 'post saving... doc... ', @, 'was: ',this._original
  saveDiff.saveDiff(Settings, @, this._original).then ()->
    next()
