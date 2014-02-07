"use strict"
angular.module("4treeApp").controller "MainCtrl", [ '$translate', '$scope', 'calendarBox', ($translate, $scope, calendarBox) ->


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

  #параметры
  $scope.set = {
    header_panel_opened: false
    p_left_side_open: false
    p_right_side_open: true
    p_plan_of_day_open: false
    calendar_box_template: "views/subviews/calendar_box.html"
    plan_of_day_template: "views/subviews/plan_of_day.html"
    text_template: "views/subviews/text.html"
    refresh: 0
  }

  #общие функции
  $scope.fn = {
    changeLanguage: (lng)->
      $translate.uses(lng).then ()->
        $scope.db.calendar_boxes = [];
        $scope.fn.setCalendarBox();
    setCalendarBox: ()->
      _([-500..500]).each (el)->
        today = new Date( (new Date()).getTime() + (el * 24 * 60 * 60 * 1000) )
        $scope.db.calendar_boxes.push( calendarBox.getDateBox( today ) )
    calendar_box_click: ($index)->
      if $scope.db.box_active != $index 
        $scope.set.p_plan_of_day_open = true;
        $scope.db.box_active = $index 
      else
        $scope.db.box_active = null
        $scope.set.p_plan_of_day_open = false;

  }

  $scope.scrollModel = {};


  #база данных
  $scope.db = {
    calendar_boxes: []
    mystate: undefined
    today_do: [
      {title: "Записаться в бассейн", myclass: "done", time: "11:00"}
      {title: "Ехать за деньгами", myclass: "future", time: "12:30"}
      {title: "Мыть машину", myclass: "future", time: "16:20"}
      {title: "Ехать в театр", myclass: "future", time: "17:00"}
    ]
    nodate_do: [
      {title: "Найти интересную книжку", myclass: "done", time: ""}
      {title: "Навести порядок", myclass: "done", time: ""}
      {title: "Прогуляться на улице", myclass: "future", time: ""}
      {title: "Заехать к родителям", myclass: "future", time: ""}
    ]
    reward_do: [
      {title: "Помидорок: 6", myclass: "done", time: ""}
      {title: "Добавлено дел: 18", myclass: "done", time: ""}
      {title: "Дел лягушек: 4", myclass: "future", time: ""}
    ]
  }


  $scope.text_example1 += (num+"<br>" for num in [1000..1]);

  $scope.fn.setCalendarBox();

  $scope.myname = "Huper..."

  
]

angular.module("4treeApp").value "fooConfig",
  config1: true
  config2: "Default config2 but it can changes"
