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
    header_panel_opened: true
    p_left_side_open: true
    p_right_side_open: true
  }

  $scope.fn = {}
  
  $scope.db = {
    calendar_boxes: [
      {day: 26, month: "февр", week_day: "вт", box_class: "default", stat: "2 / 3"}
      {day: 27, month: "февр", week_day: "ср", box_class: "default", stat: "2 / 3"}
      {day: 28, month: "февр", week_day: "чт", box_class: "default", stat: "2 / 3"}
      {day: 1, month: "март", week_day: "пт", box_class: "default", stat: "2 / 3"}
      {day: 2, month: "март", week_day: "сб", box_class: "weekend"}
      {day: 3, month: "март", week_day: "вс", box_class: "weekend"}
      {day: 4, month: "март", week_day: "пн", box_class: "default", stat: "2 / 3"}
      {day: 5, month: "март", week_day: "вт", box_class: "default", stat: "2 / 3"}
      {day: 6, month: "март", week_day: "ср", box_class: "default", stat: "2 / 3"}
      {day: 7, month: "март", week_day: "чт", box_class: "default", stat: "2 / 3"}
      {day: 8, month: "март", week_day: "пт", box_class: "default", stat: "2 / 3"}
      {day: 9, month: "март", week_day: "сб", box_class: "weekend"}
      {day: 10, month: "март", week_day: "вс", box_class: "weekend"}
      {day: 11, month: "март", week_day: "пн", box_class: "default", stat: "2 / 3"}
      {day: 12, month: "март", week_day: "вт", box_class: "default", stat: "2 / 3"}
      {day: 13, month: "март", week_day: "ср", box_class: "default", stat: "2 / 3"}
      {day: 14, month: "март", week_day: "чт", box_class: "default", stat: "2 / 3"}
      {day: 15, month: "март", week_day: "пт", box_class: "default", stat: "2 / 3"}
      {day: 16, month: "март", week_day: "сб", box_class: "weekend"}
      {day: 17, month: "март", week_day: "вс", box_class: "weekend"}
      {day: 18, month: "март", week_day: "пн", box_class: "default", stat: "2 / 3"}
      {day: 19, month: "март", week_day: "вт", box_class: "default", stat: "2 / 3"}
      {day: 20, month: "март", week_day: "ср", box_class: "default", stat: "2 / 3"}
      {day: 21, month: "март", week_day: "чт", box_class: "default", stat: "2 / 3"}
      {day: 22, month: "март", week_day: "пт", box_class: "default", stat: "2 / 3"}
      {day: 23, month: "март", week_day: "сб", box_class: "weekend"}
    ]
  }

  $scope.text_example1 = "Тут будет дерево"

  $scope.myname = "Huper..."

  
]