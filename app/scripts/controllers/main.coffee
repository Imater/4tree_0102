"use strict"
angular.module("4treeApp").controller "MainCtrl", [ '$translate', '$scope', ( $translate, $scope) ->

  $scope.awesomeThings = [
    "HTML5 Boilerplate"
    "AngularJS"
    "Karma"
    "SEXS"
    "LEXUS"
    "LEXUS2"
    "LEXUS333"
    "VALENTINA"
    "SAAA"
  ]

  $scope.set = {
    header_panel_opened: false
    p_left_side_open: true
    p_right_side_open: true
  }

  $scope.myname = "Huper..."

  $scope.fn = {}

]