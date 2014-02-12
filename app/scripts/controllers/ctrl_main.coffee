"use strict"
angular.module("4treeApp").controller "MainCtrl", [ '$translate', '$scope', 'calendarBox', 'db_tree', '$interval', 'syncApi', ($translate, $scope, calendarBox, db_tree, $interval, syncApi) ->

  syncApi.constructor();

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
    main_parent_id: 0
    show_pomidor_timer: true
    calendar_box_template: "views/subviews/view_calendar_box.html"
    plan_of_day_template: "views/subviews/view_plan_of_day.html"
    text_template: "views/subviews/view_text.html"
    tree_template: "views/subviews/view_tree.html"
    pomidor_template: "views/subviews/view_pomidor_timer.html"
    tree_header_template: "views/subviews/view_tree_header.html"
    tree_one_line_template: "views/subviews/view_one_line.html"
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
    addNote: (title)->
      $scope.db.db_tree.push({id:0, title: "Hi!!!!!!!!!!!"})
    jsFindByParent: (args)->
      db_tree.jsFindByParent(args)
    jsTreeFocus: (id)->
      $scope.set.main_parent_id = id
      $scope.db.tree_path = db_tree.jsGetPath(id);
    jsClosePomidor: ()->
      $scope.set.show_pomidor_timer=false if $scope.set.show_pomidor_timer
      console.info 'close'
    jsGetTimeRest: (dif)->
      minutes = parseInt( dif / (60 * 1000) );
      seconds = parseInt( dif/1000 - minutes*60 );
      ('0'+minutes).slice(-2) + ":" + ('0'+seconds).slice(-2)
    jsStartPomidorInterval: ()->
      $scope.db.pomidors.timer = $interval ()->
        dif = $scope.db.pomidors.finish_time - (new Date()).getTime();
        $scope.db.pomidors.procent = 3 + (1 - dif / ($scope.db.pomidors.how_long*60*1000) ) * 100;
        $scope.db.pomidors.btn_text = $scope.fn.jsGetTimeRest( dif );
        if $scope.db.pomidors.procent >= 100 
          $scope.db.pomidors.finish_time = 0;
          $interval.cancel($scope.db.pomidors.timer);
          if [2,4,6].indexOf($scope.db.pomidors.now) != -1
            timerNotification2 = new Notification("Таймер Pomodorro", {
              tag : "notify-pomidor" + $scope.db.pomidors.now + new Date(),
              body : "Отдохнули? Чтобы начать следующую помидорку на 25 минут, нажмите сюда.",
              icon : "images/pomidor.png"
            });
            timerNotification2.onclick = ()->
                $scope.fn.jsStartPomidor({id: 1});
                this.cancel();

          if [1,3,5,7].indexOf($scope.db.pomidors.now) != -1
            $scope.fn.jsStartPomidor({id: 1});
            how_long = '5 минут...';
            how_long = '15 минут...' if $scope.db.pomidors.now == 7;
            timerNotification = new Notification("Таймер Pomodorro", {
              tag : "notify-pomidor" + $scope.db.pomidors.now + new Date(),
              body : "Отлично поработали, теперь отдохните "+how_long,
              icon : "images/pomidor.png"
            });
            setTimeout ()->
              timerNotification.cancel();
            , 10000;
            timerNotification.onclick = ()->
                window.focus();
                this.cancel();
      , 1000

    jsStartPomidor: (pomidor)->
      _.each $scope.db.pomidors.list, (el)->
        if(el.id==pomidor.id)
          el.active = true
        else
          el.active = false

      $scope.db.pomidors.procent = 0;
      if($scope.db.pomidors.now<8) 
        $scope.db.pomidors.now+=1;
      else
        $scope.db.pomidors.now=0;
        $interval.cancel($scope.db.pomidors.timer);
        $scope.db.pomidors.btn_text = "25:00";
        localStorage.clear('set_pomidors');
        return


      $scope.db.pomidors.how_long = 25 if [1,3,5,7].indexOf($scope.db.pomidors.now) != -1
      $scope.db.pomidors.how_long = 5 if [2,4,6].indexOf($scope.db.pomidors.now) != -1
      $scope.db.pomidors.how_long = 15 if [8].indexOf($scope.db.pomidors.now) != -1

      $scope.db.pomidors.finish_time = (new Date()).getTime() + $scope.db.pomidors.how_long * 60 * 1000;

      localStorage.setItem( 'set_pomidors', JSON.stringify($scope.db.pomidors) );

      #функция проверки статуса каждую секунду
      $interval.cancel($scope.db.pomidors.timer);
      $scope.fn.jsStartPomidorInterval();
  }

  $scope.scrollModel = {};


  #база данных
  $scope.db = {
    calendar_boxes: []
    mystate: undefined
    tree_path: []
    pomidors: {
      active: false,
      procent: 100,
      finish_time: 0,
      how_long: 25,
      btn_text: "25:00",
      now: 0,
      timer: 0,
      list: [
        {id: 1, active: true, did: 2}
        {id: 3, active: false, did: 2}
        {id: 5, active: false, did: 2}
        {id: 7, active: false, did: 1}
      ]
    }
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

  db_tree.constructor();
  $scope.db.db_tree = db_tree.getTree();


  $scope.db.tree_path = db_tree.jsGetPath(1);

  $scope.fn.setCalendarBox();

  $scope.myname = "Huper..."

  #инициализируем помидорку
  if ( set_pomidors = localStorage.getItem( 'set_pomidors' ) )
    $scope.db.pomidors = JSON.parse( set_pomidors );
  if( $scope.db.pomidors.now != 0 )
    $scope.fn.jsStartPomidorInterval();
  

  
]

angular.module("4treeApp").controller "save_tree_db", ($scope, syncApi)->
  $scope.$watch "tree", (new_value, old_value)->
    if new_value != old_value
      console.info 'changes = ', new_value, old_value
      console.info syncApi.jsAddToSyncJournal(new_value, old_value)
    #syncApi.getTry();
  , true





angular.module("4treeApp").value "fooConfig",
  config1: true
  config2: "Default config2 but it can changes"






















