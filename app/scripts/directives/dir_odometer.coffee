###
  Should be used as <odometer ng-model="myModel"></odometer>
###

'use strict'

angular.module('4treeApp').directive 'odometer', ->
  restrict: 'E'
  require: 'ngModel'
  scope:
    model: '=ngModel'
  link: ($scope, el, attr, ngModel) ->
    o = new Odometer
      auto: false
      #animation: 'count'
      el: el[0]
      value: $scope.model
      format: ''
      duration: 100
    ngModel.$render = ->
      o.update ngModel.$viewValue