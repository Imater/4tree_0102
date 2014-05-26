angular.module("4treeApp").controller "save_tree_db_editor", ($scope, syncApi, db_tree, $rootScope)->
  ###
  $scope.$watch "db.main_node[set.focus_edit]", ()->
    __log.info 8888
    if !_.isEqual( new_value, old_value )
      $rootScope.$emit("jsFindAndSaveDiff",'tree', new_value, old_value);
  , true
  ###

  $scope.$watch "db.main_node[set.focus_edit]", (new_value, old_value)->
    if !_.isEqual( new_value, old_value ) and new_value and old_value and (new_value._id == old_value._id)
      $rootScope.$emit("jsFindAndSaveDiff",'tree', new_value, old_value);
  , true


angular.module("4treeApp").controller "save_tree_db", ($scope, syncApi, db_tree, $rootScope)->
  el = $scope.db.main_node[$scope.set.focus_edit]
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



angular.module("4treeApp").controller "top_tabs_ctrl", ($scope, $rootScope, db_tree, settingsApi)->
  $scope.params = { menu_open_index: undefined }

  $scope.getTab = (tab)->
    db_tree.jsFind(tab.tab_id);

  $scope.clickTab = (tab)->
    $scope.params.menu_open_index = undefined;
    found = db_tree._db.tree[tab.tab_id];
    if found and settingsApi.set.focus
      $rootScope.$$childTail.db.main_node[ settingsApi.set.focus ] = found
      $rootScope.$$childTail.db.main_node[ settingsApi.set.focus_edit ] = found

  $scope.closeTab = (tab)->
    #alert 'close ' + JSON.stringify tab
    $scope.params.menu_open_index = undefined;
    settingsApi.set.tabs = _.filter settingsApi.set.tabs, (el, key)->
      el.tab_id != tab.tab_id

