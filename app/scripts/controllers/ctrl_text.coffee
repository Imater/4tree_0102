###
  Класс для работы с текстами основан на diff
###
class TextController
  @$inject: [ '$timeout', '$scope', '$q' ]
  constructor: (@timeout, @scope, @q)->
    mythis = @;
    _.each @textToLoad, (txt)->
      key=mythis.sha(txt)
      console.info 'sha of txt = ', key
      mythis.textDB[key] = txt
    @scope.txt = 'Пусто';

    @scope.$watch 'tree', (old_val, new_val)->
      if old_val!=new_val
        console.info 'watch', new_val
        if mythis.scope.tree?.text_id
          mythis.getTextByShaId(mythis.scope.tree.text_id).then (txt)->
            mythis.scope.txt = txt
      
    console.info 'DB = ', @textDB;
  textToLoad: {
    '': 'Мама мыла раму'
  }
  textDB: {}
  getTextByShaId: (sha_id)->
    console.info "!!!", @q
    dfd = @q.defer()
    mythis = @;
    if @textDB
      @timeout ()->
        dfd.resolve(mythis.textDB[sha_id])
      ,3000
    else
      dfd.resolve()
    return dfd.promise

  #получаем sha от текста
  sha: (txt)->
    CryptoJS.SHA3(txt, { outputLength: 256 }).toString()

angular.module("4treeApp").controller 'textController', TextController
