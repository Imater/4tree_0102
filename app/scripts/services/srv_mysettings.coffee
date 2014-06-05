angular.module("4treeApp").service 'settingsApi', [
  '$translate',
  '$http',
  '$q',
  '$rootScope',
  '$timeout',
  '$socket',
  '$location'
  'cryptApi'
  ($translate,
   $http,
   $q,
   $rootScope,
   $timeout,
   $socket,
   $location,
   cryptApi) ->

      tmp = {
        tick_today_date: new Date()
        tick_today_date_time: new Date().getTime()
        focus: 1
        focus_edit: 1
        tree_loaded: false
        tabs:[]
      }

      set = {
        v: 1
        user_info:
          client_id: '4tree_client'
          client_secret: '4tree_secret'
          username: ''
          password: ''
        user_id: '5330ff92898a2b63c2f7095f'
        machine: localStorage.getItem('mongoMachineId')
        autosync_on: true
        server: ""
        hide_task_in_tree: true
        today_date: new Date()
        today_date_time: new Date().getTime()
        tabs: [
        ]
        header_panel_opened: true
        p_left_side_open: false
        p_right_side_open: true
        p_plan_of_day_open: true
        top_parent_id: 'no parent'
        main_parent_id: []
        show_path_panel: false
        show_pomidor_timer: false
        show_right_menu: true
        new_title: 'Новая заметка'
        calendar_box_template: 'views/subviews/view_calendar_box.html'
        weight: {
          date: 1
          importance: 1
        }
        panel: [
          {active: 7} #0
          {active: 6} #1   0-дерево 1-карточки 2-mindmap 3-divider 4-календарь 5-редактор 6-none 7-week 8-sea
          {active: 8} #2
          {active: 0} #3
        ]
        from_today_index: 0
        side_views_menu: [
          {
            title: 'План дня'
            icon: 'icon-calendar'
            template: 'views/subviews/view_side/view_plan_of_day.html'
          }
          {
            title: 'To-do'
            icon: 'icon-check'
            template: 'views/subviews/view_side/view_side_todo.html'
          }
          {
            title: 'Новости'
            icon: 'icon-rss'
            template: 'views/subviews/view_side/view_side_news.html'
          }
          {
            title: 'Мой сайт'
            icon: 'glyphicon glyphicon-globe'
            template: 'views/subviews/view_side/view_side_myweb.html'
          }
          {
            title: 'Контакты'
            icon: 'glyphicon glyphicon-user'
            template: 'views/subviews/view_side/view_side_contacts.html'
          }
          {
            title: 'Теги'
            icon: 'glyphicon glyphicon-tag'
            template: 'views/subviews/view_side/view_side_tags.html'
          }
          {
            title: 'Обзор'
            icon: 'icon-eye'
            template: 'views/subviews/view_side/view_side_review.html'
          }
          {
            title: 'Поиск'
            icon: 'icon-search'
            template: 'views/subviews/view_side/view_side_search.html'
          }
        ]
        main_views_menu: [
          {
            title: 'Дерево'
            icon: 'icon-flow-cascade'
            template: 'views/subviews/view_main/view_tree.html'
          }
          {
            title: 'Карточки'
            icon: 'icon-th-1'
            template: 'views/subviews/view_main/view_cards.html'
          }
          {
            title: 'Mindmap'
            icon: 'glyphicon glyphicon-record'
            template: 'views/subviews/view_main/view_mindmap.html'
          }
          {
            title: 'divider'
          }
          {
            title: 'Календарь'
            icon: 'icon-calendar-2'
            template: 'views/subviews/view_main/view_calendar.html'
          }
          {
            title: 'Редактор'
            icon: 'icon-pencil-neg'
            template: 'views/subviews/view_main/view_text.html'
          }
          {
            title: '— — —'
            off: true
            icon: 'icon-cancel-circle'
            template: ''
          }
          {
            title: 'Неделя'
            icon: 'icon-calendar'
            template: 'views/subviews/view_main/view_week_calendar.html'
          }
          {
            title: 'Море времени'
            icon: 'glyphicon glyphicon-tint'
            template: 'views/subviews/view_main/view_sea_time.html'
          }
        ]
        refresh: 0
        ms_show_icon_limit: 36
        mini_settings_btn_active: 0
        mini_settings_show: false
        mini_tasks_hide: false
        mini_settings_btn: [
          {id:0, title: 'Оформление', icon: 'icon-brush'}
          {id:1, title: 'Проект', icon: 'icon-target'}
          {id:2, title: 'Обзор', icon: 'icon-eye'}
          {id:3, title: 'Счётчики', icon: 'icon-chart-area'}
          {id:4, title: 'Поделиться', icon: 'icon-export-1'}
        ]
      }

      save = ()->
        encrypted = cryptApi.encrypt JSON.stringify(set), 4
        localStorage.setItem 'settings', encrypted
        console.info 'SAVED';
      #параметры

      load_settings = ()->
        encrypted = localStorage.getItem 'settings'
        if encrypted
          decrypted = cryptApi.decrypt(encrypted).text
          if decrypted
            parsed = JSON.parse(decrypted)
            if parsed.v == set.v
              set = parsed
              console.info 'loaded', set
            else
              console.info 'version changed'

      load_settings();

      $rootScope.$watch ()->
        set
      , (new_val, old_val)->
        if !_.isEqual(new_val,old_val)
          save();
      , true


      return { set, tmp, save }
]