"use strict"
angular.module("4treeApp").controller "MainCtrl", [ '$translate', '$scope', 'calendarBox', 'db_tree', '$interval', 'syncApi', 'db_tasks', ($translate, $scope, calendarBox, db_tree, $interval, syncApi, db_tasks) ->


  #параметры
  $scope.set = {
    header_panel_opened: false
    p_left_side_open: false
    p_right_side_open: true
    p_plan_of_day_open: false
    main_parent_id: 1
    show_pomidor_timer: false
    calendar_box_template: "views/subviews/view_calendar_box.html"
    plan_of_day_template: "views/subviews/view_plan_of_day.html"
    text_template: "views/subviews/view_text.html"
    tree_template: "views/subviews/view_tree.html"
    pomidor_template: "views/subviews/view_pomidor_timer.html"
    tree_header_template: "views/subviews/view_tree_header.html"
    tree_one_line_template: "views/subviews/view_one_line.html"
    mini_settings: "views/subviews/view_mini_settings.html"
    refresh: 0
    ms_show_icon_limit: 36
    mini_settings_btn_active: 0
    mini_settings_show: false
    mini_tasks_show: true
    mini_settings_btn: [
      {id:0, title: 'Оформление', icon: 'icon-brush'}
      {id:1, title: 'Проект', icon: 'icon-target'}
      {id:2, title: 'Обзор', icon: 'icon-eye'}
      {id:3, title: 'Счётчики', icon: 'icon-chart-area'}
      {id:4, title: 'Поделиться', icon: 'icon-export-1'}
    ]
  }


  #общие функции
  $scope.fn = {
    service: {
      db_tasks: db_tasks
      db_tree: db_tree
      calendarBox: calendarBox
    }
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
    main_text: "Текст"
    calendar_boxes: []
    mystate: undefined
    tree_path: []
    main_node: {
      id: 1034
    }
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
    icons_collection: [
      'icon-progress-0'      
      'icon-progress-1'      
      'icon-progress-2'      
      'icon-progress-3'     
      'icon-dot' 
      'icon-dot-2' 
      'icon-dot-3' 
      'icon-thumbs-up-1'
      'icon-thumbs-down'
      'icon-minus'
      'icon-plus'
      'icon-star-empty'
      'icon-star'
      'icon-heart-empty'
      'icon-heart'
      'icon-lock-open'
      'icon-lock'
      'glyphicon glyphicon-eye-close'
      'glyphicon glyphicon-eye-open'
      'icon-phone'
      'glyphicon glyphicon-phone-alt'
      'icon-home-2'
      'icon-stop'
      'icon-cloud'
      'glyphicon glyphicon-unchecked'
      'icon-ok-1'
      'icon-check'
      'glyphicon glyphicon-ok-sign'
      'icon-flash'
      'icon-flight'
      'icon-pencil-alt'
      'icon-help-circle'
      'icon-help'
      'icon-wallet'
      'icon-mail-2'
      'icon-tree'
      'icon-comment-inv'
      'icon-chat-2'
      'icon-article-alt'
      'icon-rss'
      'icon-volume'
      'icon-aperture-alt'
      'icon-layers'
      'icon-emo-happy'
      'icon-emo-wink'
      'icon-emo-laugh'
      'icon-emo-sunglasses'
      'icon-emo-sleep'
      'icon-emo-unhappy'
      'icon-skiing'
      'icon-twitter-bird'
      'icon-gift'
      'icon-basket'
      'icon-dollar'
      'icon-floppy'
      'icon-doc-text'
      'icon-calendar-2'
      'icon-book-open'
      'icon-camera'
      'icon-search-1'
      'icon-wrench-1'
      'icon-umbrella'
      'icon-music'
      'icon-record'
      'icon-feather'
      'icon-calculator'
      'icon-address'
      'icon-pin'
      'icon-basket-1'
      'icon-steering-wheel'
      'icon-bicycle'
      'icon-swimming'
      'icon-leaf'
      'icon-mic'
      'icon-target-1'
      'icon-user'
      'icon-monitor'
      'icon-cd'
      'icon-download'
      'icon-link'
      'icon-wrench'
      'icon-clock'
      'icon-at'
      'icon-pause'
      'icon-moon'
      'icon-flag'
      'icon-key'
      'icon-users-1'
      'icon-adjust'
      'icon-eye'
      'icon-print'
      'icon-inbox'
      'icon-flow-cascade'
      'icon-college'
      'icon-fast-food'
      'icon-coffee'
      'icon-palette'
      'icon-top-list'
      'icon-bag'
      'icon-attach-1'
      'icon-info'
      'icon-home-1'
      'icon-hourglass'
      'icon-attention'
      'icon-scissors'
      'icon-pencil-neg'
      'icon-tint'
      'icon-chart-area'
      'glyphicon glyphicon-stats'
      'icon-chart-pie'
      'icon-guidedog'
      'icon-tag'
      'icon-archive'
      'icon-flow-line'
      'icon-terminal'
      'icon-eyedropper'
      'icon-glass'
      'icon-lamp'
      'icon-folder-1'
      'icon-doc-1'
      'icon-doc-2'
      'icon-book'
      'icon-signal'
      'icon-bookmark'
      'glyphicon glyphicon-asterisk'
      'glyphicon glyphicon-film'
      'glyphicon glyphicon-remove'
      'glyphicon glyphicon-off'
      'glyphicon glyphicon-road'
      'glyphicon glyphicon-headphones'
      'glyphicon glyphicon-facetime-video'
      'glyphicon glyphicon-map-marker'
      'glyphicon glyphicon-play'
      'glyphicon glyphicon-pause'
      'glyphicon glyphicon-stop'
      'glyphicon glyphicon-exclamation-sign'
      'glyphicon glyphicon-gift'
      'glyphicon glyphicon-fire'
      'glyphicon glyphicon-magnet'
      'glyphicon glyphicon-bullhorn'
      'glyphicon glyphicon-certificate'
      'glyphicon glyphicon-globe'
      'glyphicon glyphicon-tasks'
      'glyphicon glyphicon-filter'
      'glyphicon glyphicon-dashboard'
      'glyphicon glyphicon-phone'
      'glyphicon glyphicon-usd'
      'glyphicon glyphicon-euro'
      'glyphicon glyphicon-gbp'
      'glyphicon glyphicon-record'
      'glyphicon glyphicon-send'
      'glyphicon glyphicon-cutlery'
      'glyphicon glyphicon-compressed'
      'glyphicon glyphicon-tower'
      'glyphicon glyphicon-tree-conifer'
    ]
    icons_collection_colors: [
      '#265e12'
      '#198603'

      '#ffaf10'
      '#f0cb09'

      '#993333'
      '#e0292b'

      '#CC6699'
      '#ff0080'

      '#008AB8'
      '#3F5D7D'

      '#6f6f6f'
      '#000'
    ]
  }

  #$scope.db.db_tree = db_tree.getTree();
  db_tree.constructor();
  db_tasks.constructor();
  $scope.db.tasks = db_tasks.getTasks();
  db_tree.getTreeFromNet().then ()->
    $scope.set.main_parent = db_tree.jsFindByParent(1);

  #$scope.set.main_parent = [{id:1, title: {v:"4tree"}, _childs:100, _open: true}];
  

  $scope.db.tree_path = db_tree.jsGetPath(1);

  $scope.fn.setCalendarBox();
  syncApi.constructor();
  $scope.db.sync_journal = syncApi.sync_journal
  $scope.db.sync_to_send = syncApi.jsDryObjectBySyncJournal();

  $scope.myname = "Huper..."

  #инициализируем помидорку
  if ( set_pomidors = localStorage.getItem( 'set_pomidors' ) )
    $scope.db.pomidors = JSON.parse( set_pomidors );
  if( $scope.db.pomidors.now != 0 )
    $scope.fn.jsStartPomidorInterval();

  

  
]

angular.module("4treeApp").controller "save_tree_db", ($scope, syncApi)->

  $scope.$watch "tree", (new_value, old_value)->
    last_sync_time = new Date(2012,11,11);
    if new_value != old_value
      syncApi.setChangeTimes(new_value, old_value);
      $scope.db.sync_to_send = syncApi.getChangedSinceTime(last_sync_time);
  , true





angular.module("4treeApp").value "fooConfig",
  config1: true
  config2: "Default config2 but it can changes"






















