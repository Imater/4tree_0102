mongoose = require("mongoose")
saveDiff = require('../../models/_js/saveDiff.js');

Schema = mongoose.Schema

analyzer = {
  type: 'custom'
  tokenizer: 'standard'
  filter: ['lowercase', 'nGram']
}

treeSchema = new Schema (
  'id': String
  'title': { type: String, es_indexed: true } 
  'text': { type: String, es_indexed: true }
  'text_id': { type: String, es_indexed: true }
  'folder': String
  'parent_id': String #Schema.ObjectId
  'parent': String
  'pos': { type: Number, default: 0 }
  'user_id': { type: String, es_indexed: true } 
  'add_tm': Date
  'icon': String
  'color': String
  'icon_color': String
  'del': { type: Number, default: 0 }
  'did': { type: Date, default: '' }
  'old_tag': String
  'date1': Date
  'date2': Date
  'diary': Date
  'short_link_on': Boolean
  'web_on': Boolean
  'share_frends': Boolean
  #'dates': { startDate: Date, endDate: Date }
  'tags': []
  'counters': [ { 'cnt_today': Number, 'title': String, 'days': [] } ]
  'hide_in_todo': Boolean
  'importance': { type: Number, default: 50 }
  '_sync': [ { key: String, diff: { '_tm': String } } ]
  '_sha1': String
  '_tm': Date
)

#treeSchema.index({user_id: 1, title: 1}, {unique: false});

treeSchema.post 'init', ()->
  this._original = this.toObject();




mongoosastic = require('mongoosastic')
treeSchema.plugin(mongoosastic, {index: 'trees', type:'tree'});

Tree = module.exports = mongoose.model("Tree", treeSchema)

Tree.createMapping (err, mapping)->
  console.info 'mapping', mapping if false

treeSchema.pre 'save', (next)->
  #console.info 'post saving... doc... ', @, 'was: ',this._original
  saveDiff.saveDiff(Tree, @, this._original).then ()->
    next()
