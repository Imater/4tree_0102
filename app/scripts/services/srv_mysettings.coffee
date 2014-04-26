###
  Класс для сохранения настроек
  Центр полётов, куда стекаются все данные
###
class MySettingsClass
  @$inject: ['$timeout']
  constructor: ($timeout)->
    $timeout ()->
      console.info 'constructor MySettingsClass did'
    , 3000
  # Одно из полей настроек
  # @mixin
  # @author Вецель Евгений
  # @example Move an animal
  #   new Lion('Simba').move('south', 12)  
  set: {
    #новый параметр
    hello: 'hello!!!'
  }

angular.module("4treeApp").service 'mySettings', MySettingsClass
