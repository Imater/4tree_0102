angular.module("4treeApp").controller "save_tree_db_editor", ($scope, syncApi, db_tree, $rootScope)->
  ###
  $scope.$watch "db.main_node[tmp.focus_edit]", ()->
    __log.info 8888
    if !_.isEqual( new_value, old_value )
      $rootScope.$emit("jsFindAndSaveDiff",'tree', new_value, old_value);
  , true
  ###

  $scope.$watch "db.main_node[tmp.focus_edit]", (new_value, old_value)->
    if !_.isEqual( new_value, old_value ) and new_value and old_value and (new_value._id == old_value._id)
      $rootScope.$emit("jsFindAndSaveDiff",'tree', new_value, old_value);
  , true


angular.module("4treeApp").controller "save_tree_db", ($scope, syncApi, db_tree, $rootScope)->
  el = $scope.db.main_node[$scope.tmp.focus_edit]
  $scope.save_scroll = ()->
    console.info($scope.scrollValues)

  $scope.$watch "tree", (new_value, old_value)->
    if !_.isEqual( new_value, old_value ) and (new_value._id == old_value._id)
      $rootScope.$emit("jsFindAndSaveDiff",'tree', new_value, old_value);
  , true


angular.module("4treeApp").controller "save_task_db", ($scope, syncApi, db_tree, $rootScope)->

  $scope.$watch "task.date_on", (new_value, old_value)->
    #Если включили
    if !old_value and new_value == true
      if !$scope.task.date1
        $scope.task.date1 = new Date();
      if !$scope.task.date2
        $scope.task.date2 = new Date();


  $scope.$watchCollection "set.set_task", (new_value, old_value)->
    if !_.isEqual( new_value, old_value )
      $rootScope.$emit("jsFindAndSaveDiff",'tasks', new_value, old_value);

angular.module("4treeApp").controller "save_task_db_simple", ($scope, syncApi, db_tree, $rootScope)->

  $scope.$watchCollection "task", (new_value, old_value)->
    if !_.isEqual( new_value, old_value )
      $rootScope.$emit("jsFindAndSaveDiff",'tasks', new_value, old_value);

angular.module("4treeApp").controller "editor_tasks", ($scope, db_tree, $rootScope)->

  $scope.$watch 'task.importance', (new_value, old_value)->
    if new_value != old_value
      db_tree.clearCache();

  $scope.getTasks = ()->
    if !$scope.set.mini_tasks_hide
      return $scope.tasks_by_id.tasks
    else
      return $scope.tasks_by_id.next_action


angular.module("4treeApp").controller "searchController", ($scope, syncApi, db_tree, $rootScope, $sce, $timeout)->
  $scope.search_notes_result = {};
  $scope.calc_history = ['2*2 = 4']
  $scope.show_calc = false;


  $scope.init = (params)->
    $scope.dont_need_highlight = params.dont_need_highlight;


  $scope.trust = (text)->
    text = strip_tags(text, "<em>", " ") if text
    if text
      $sce.trustAsHtml(text)

  ###
  This service ....
  ###
  show_search_result = _.debounce (search_text, dont_need_highlight)->
    $scope.fn.service.db_tree.searchString(search_text, dont_need_highlight).then (results)->
      _.each Object.keys(results), (db_name)->
        $scope.search_notes_result[db_name] = []
        $scope.search_notes_result[db_name] = results[db_name]?.hits?.hits;
  , 600

  mythis = @;
  $rootScope.$on 'sync_ended', (event)->
    __log.info 'hello, im change'
    if !$scope.dont_need_highlight
      $timeout ()->
        show_search_result($scope.search_box, $scope.dont_need_highlight);
      , 500

  $scope.$watch "search_box", (new_value, old_value)->
    if new_value != old_value
      if new_value and $scope.dont_need_highlight
        $(".header_search_form .btn-group").addClass("open");
      if !new_value.length
        $scope.search_notes_result = {};
        $scope.show_calc = false;

      three_digits = (str)->
        spl = (""+str).split('.')
        answer = (""+spl[0]).replace(/\B(?=(\d{3})+(?!\d))/g, " ")
        answer += '.' + spl[1] if spl[1]
        answer

      if ['-','=','+','/','*', ' '].indexOf(new_value[new_value.length-1])!=-1
        new_value = new_value.substr(0,new_value.length-1);
        __log.info 's', { new_value };

      try
        if (new_value.indexOf('+')==-1 and new_value.indexOf('-')==-1 and new_value.indexOf('/')==-1 and new_value.indexOf('*')==-1)
          __log.info 'error!!!'
          throw "dont calculate!"
        calc_answer = Parser.evaluate( new_value.replace(/,/ig, '.').replace(/\s/ig, '') )
        calc_answer = Math.round( calc_answer * 100000)/100000
        new_value_shy = new_value.replace(/\+/ig, ' + ').replace(/\-/ig, ' - ').replace(/\*/ig, ' * ').replace(/\//ig, ' / ');
        $scope.calc_history[0] = $sce.trustAsHtml(new_value_shy + " = <b>" + three_digits(calc_answer) + "</b>");
        $scope.show_calc = true;
      catch error
        __log.info { error }
        show_search_result(new_value, $scope.dont_need_highlight);
        $scope.show_calc = false;




angular.module("4treeApp").controller "top_tabs_ctrl", ($scope, $rootScope, db_tree, settingsApi, $window, $timeout)->
  $scope.window_width = $window.innerWidth;

  $scope.params = { menu_open_index: undefined }

  $scope.getTabs = ()->
    get = db_tree.settingsGet('top_tabs')
    settingsApi.tmp.tabs = get if get

  $scope.$watch 'fn.service.settingsApi.tmp.tabs', (new_val, old_val)->
    if new_val != old_val and !!new_val and !!old_val
      new_val2 = _.filter new_val, (el)->
        !el.tmp
      old_val2 = _.filter old_val, (el)->
        !el.tmp
      dif = db_tree.diff.diff new_val2, old_val2
      if dif
        console.info 'saving...'
        db_tree.settingsSet('top_tabs', new_val) if db_tree
  , true

  get_mini_tab_width = _.throttle ()->
    round = (val)-> Math.round(val*100)/100;
    mini_tabs = _.filter settingsApi.tmp.tabs, (tab) ->
      tab.show_only_icon
    mini_one_tab_width = round( (27/$window.innerWidth) * 100 );
    mini_all_tabs_width = round( (mini_tabs.length) * mini_one_tab_width );
    count = mini_tabs.length;
    big_tabs_count = settingsApi.tmp.tabs.length - mini_tabs.length;
    one_big_tab_width = (100 - mini_all_tabs_width) / big_tabs_count;
    return one_big_tab_width
  , 3000

  $scope.getTabWidth = ()->
    width = get_mini_tab_width();
    width = 20 if width > 20
    'width:'+width+'%'

  $scope.$on 'my-tab-sorted', (e, data)->

    Array.prototype.move = (old_index, new_index) ->
      if new_index >= @length
        k = new_index - @length
        @push `undefined`  while (k--) + 1
      @splice new_index, 0, @splice(old_index, 1)[0]
      this

    if data and data.from>=0 and data.to>=0 and data.from != (data.to-1) and data.from_id
      $timeout ()->
        console.info 'before moved', JSON.stringify settingsApi.tmp.tabs
        settingsApi.tmp.tabs = _.cloneDeep(settingsApi.tmp.tabs).move(data.from, data.to-1);
        console.info 'moved', JSON.stringify settingsApi.tmp.tabs


  $scope.getTab = (tab)->
    db_tree.jsFind(tab.tab_id);

  $scope.clickTab = (tab)->
    $scope.params.menu_open_index = undefined;
    found = db_tree._db.tree[tab.tab_id];
    if found and settingsApi.tmp.focus
      if found._path
        cnt = found._path.length-1;
        _.each found._path, (el_id, i)->
          if i<cnt
            el = db_tree.jsFind(el_id)
            el._panel[settingsApi.tmp.focus_edit]._open = true if el && settingsApi.tmp.focus_edit && !el._panel[settingsApi.tmp.focus_edit]._open
      $rootScope.$$childTail.db.main_node[ settingsApi.tmp.focus ] = found
      $rootScope.$$childTail.db.main_node[ settingsApi.tmp.focus_edit ] = found

  $scope.fixTab = (tab)->
    db_tree.fixTab(tab.tab_id);

  $scope.closeTab = (tab, close_type)->
    #alert 'close ' + JSON.stringify tab
    $scope.params.menu_open_index = undefined;
    tmp = undefined;
    settingsApi.tmp.tabs = _.filter settingsApi.tmp.tabs, (el, key)->
      if !close_type
        return el.tab_id != tab.tab_id
      else if close_type == 'other'
        return el.tab_id == tab.tab_id
      else if close_type == 'left'
        console.info { tmp, key }
        if el.tab_id == tab.tab_id
          tmp = key
        return tmp and tmp <= key
      else if close_type == 'right'
        console.info { tmp, key }
        if el.tab_id == tab.tab_id
          tmp = key
        return !tmp or tmp == key


angular.module("4treeApp").controller "menuController", ($scope, $rootScope, db_tree, settingsApi, $window, $timeout)->
  $scope.showSettings = ()->
    $scope.tmp.settings_show = !$scope.tmp.settings_show;

angular.module("4treeApp").controller "settingsController", ($scope, $rootScope, db_tree, settingsApi, $window, $timeout)->
  $scope.params = { set_index: 0 };
  $scope.settings_titles = [
    {title: 'Настройки'}
    {title: 'Пользователь'}
    {title: 'Справка'}
  ]

  i = 0;
  $scope.closeSettings = ()->
    console.info 'close settings';
    if (i++)
      $scope.tmp.settings_show=false;


angular.module("4treeApp").controller "seaController", ($scope, $rootScope, db_tree, settingsApi, $window, $timeout)->


  $scope.boats = [
    {d1: new Date(2014,5,3,12,30).getTime(), d2: new Date(2014,5,5,19,30).getTime(), title: 'Дело идёт уже два дня, осталось чуть-чуть'},
    {d1: new Date(2014,5,2,9,30).getTime(), d2: new Date(2014,5,3,9,30).getTime(), title: 'Дело прошло 2 дня назад'},
    {d1: new Date(2014,5,1,9,30).getTime(), d2: new Date(2014,5,2,9,30).getTime(), title: 'Дело прошло 3 дня назад'},
    {d1: new Date(2014,5,3,9,30).getTime(), d2: new Date(2014,5,9,9,30).getTime(), title: 'Дело идёт 2 дня, осталось 4 дня и через день наступят выходные'},
    {d1: new Date(2014,5,5,6,30).getTime(), d2: new Date(2014,5,5,10,30).getTime(), title: 'Дело пора делать'},
    {d1: new Date(2014,5,5,9,30).getTime(), d2: new Date(2014,5,9,13,30).getTime(), title: 'Дело пора делать, дата окончания через 4 дня'},
    {d1: new Date(2014,5,15,9,30).getTime(), d2: new Date(2014,5,20,9,30).getTime(), title: 'До начала дела ещё пара недель'},
    {d1: new Date(2014,5,3,9,30).getTime(), d2: new Date(2014,5,15,9,30).getTime(), title: 'Дело идёт 2 дня, осталось 10 дней'},
  ]

  $scope.zoom = 30;

  $scope.updateBoats = ()->
    round = (val)->
      Math.round(val*10000)/10000
    today = new Date().getTime();
    width_days = 100/$scope.zoom;
    _.each $scope.boats, (boat)->
      one_day_width = (width_days);
      d1_days = (parseFloat(boat.d1))/(24*60*60*1000);
      d2_days = (parseFloat(boat.d2))/(24*60*60*1000);
      d1_days_ago = (parseFloat(boat.d1) - today)/(24*60*60*1000);
      d2_days_ago = (parseFloat(boat.d2) - today)/(24*60*60*1000);
      left_procent = d1_days_ago * one_day_width;
      days = parseInt(d2_days_ago - d1_days_ago);
      days = 1 if days <= 0.5
      console.info 'days = '+days;
      width_procent = (d2_days - d1_days) * one_day_width;
      boat.left = 50+round(left_procent) + '%';
      boat.width = round(width_procent) + '%';
      height = round(width_procent);
      height = 7 if height< 7
      height = 50 if height> 50
      boat.height = height + 'px';
      boat.containers = [];
      boat.days = days;
      day = days;
      left_date = parseFloat(boat.d1);
      while day--
        this_date = left_date + (days-day)*24*60*60*1000;
        week_day = new Date(this_date).getDay();
        if week_day==0 or week_day==6
          week_end = true
        else
          week_end = false
        this_width = if days == 1 then boat.width else one_day_width+'%';
        boat.containers.push({num:day, width: (this_width), height: '5px', week_end: week_end});

  $scope.updateBoats();
  $scope.$watch 'zoom', (new_val, old_val)->
    $scope.updateBoats() if new_val != old_val
