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


angular.module("4treeApp").controller "seaController", ($scope, $rootScope, db_tree, settingsApi, $window, $timeout, $compile)->

  $scope.getEventForGant = (startDate, colCount, stepBy)->
    events = [];
    today = startDate;
    endDate = moment(startDate).add(stepBy, colCount);
    while (today < endDate)
      key = moment(today).format('YYYY-MM-DD');
      tasks = db_tree.getView('tasks', 'tasks_by_date').result[key]
      if tasks
        events = events.concat(tasks);
      today = moment(today).add(stepBy, 1);
    console.info 'events = ', JSON.stringify events
    events
  return



angular.module("4treeApp").directive "gantCalendar", ($compile, $timeout, $templateCache)->
  #templateUrl: 'views/subviews/time_line.html'
  #transclude: true
  restrict: "A"
  scope: {
    getEvent: '&'
    viewType: '=' #month, day
  }
  require: "?ngModel"
  link: ($scope, el, attrs, ngModel) ->

    timeline = {
      multiply: 2
      col_width: 25
      start_add_from: 100
      t1: new Date(2014,5,7).getTime()
      t2: new Date(2014,6,7).getTime()
      now: new Date().getTime()
      today_date: moment().format('YYYY-MM-D')
      main_width: el.width()
      addType: 'days'
      col_count: 10
      how_much_col_need: ()->
        @col_count = Math.round( (@main_width / @col_width) * @multiply );
      stepTimeByViewType: ()->
        step = switch
          when $scope.viewType == 'month' then 24*60*60*1000
          when $scope.viewType == 'day' then 60*60*1000
        console.info step, $scope.viewType
        return step
      init: ()->
        @how_much_col_need();
        @t1 = moment().subtract(@addType, @col_count/2);
        @t2 = @t1;
        console.info 't1 = '+@t1, 't2 = '+@t2
        @renderBackgroundCalendar();
        half = el.prop('scrollWidth')/4;
        el.scrollLeft(half);
        el.on 'scroll', ()->
          timeline.scrollThrottle()
      renderCols: (t1, amount)->
        today = t1
        t2 = moment(t1).add(@addType, amount);
        elements = {cols: ""};
        while (today < t2)
          #renderCol = $compile('<li>{{label}}</li>');
          year_name = moment(today).format('YYYY');
          month_name = moment(today).format('MMMM');
          date_num = moment(today).format('D');
          week_name = moment(today).format('dd');
          time_name = moment(today).format('H:mm');
          time_name = '' if @addType!='hours';

          if date_num == '1'
            class_insert = 'first_day';
          else
            class_insert = '';

          if new Date(today).getDay() == 6 || new Date(today).getDay() == 0
            class_insert += ' weekend';

          if new Date(today).getDay() == 1
            class_insert += ' week ';

          elements.cols += "<li class='"+class_insert+"' style='width:"+@col_width+"px'>";

          events = []

          spreadLevel = (events)->
            _.each events, (event)->
              event._level = Math.round(Math.random()*10);

          spreadLevel(events);

          if moment(today).format('YYYY-MM-D') == @today_date
            elements.cols += '<div class="events">';
            _.each events, (el)->
              margin_top = el._level * 25;
              elements.cols += '<div class="event" style="margin-left:'+el.left+'px;'+
                               'width:'+el.width+'px;background:'+el.color+';top:'+margin_top+'px;"></div>';
            elements.cols += '</div>';


          if date_num == '1'
            elements.cols += "<div class='month_year_name visible'><span class='month'>"+
                month_name+
              " </span>";
            elements.cols += "<span class='year'>"+
                year_name+
              " </span></div>";
          else
            elements.cols += "<div class='month_year_name'>&nbsp;</div>";

          elements.cols += " <div class='day'>"+
            date_num+
            " </div>";
          elements.cols += " <div class='day_week'>"+
            week_name+
            " </div>";

          elements.cols += " <div class='time'>"+
            time_name+
            " </div>";




          elements.cols += "</li>";




          today = moment(today).add(@addType, 1);
        elements.t2 = moment(today);
        return elements
    renderEvents: (t1, col_count)->
      console.info 'renderEvents = ', t1, col_count
      $scope.sea_events = $scope.getEvent({startDate: t1, colCount: col_count, stepBy: @addType});

      template = $templateCache.get('event.html');
      compiled = $compile(template)($scope);
      el.find('.events').append(compiled);


    renderBackgroundCalendar: (need_before)->
      if need_before
        width_before = el.prop('scrollWidth');
      if !need_before
        elements = @renderCols(@t2, @col_count);
        el.append elements.cols;
        @renderEvents(@t2, @col_count);
        @t2 = elements.t2
      else
        calc_t1 = moment(@t1).subtract(@addType, @col_count);
        elements = @renderCols(calc_t1, @col_count);
        el.prepend elements.cols
        @renderEvents(calc_t1, @col_count);
        @t1 = calc_t1


      if need_before
          width_after = el.prop('scrollWidth');
          console.info 'sl = ', width_after - width_before
          el.scrollLeft( width_after - width_before )


    scrollThrottle: _.throttle ()->
      scrollLeft = el.scrollLeft();
      diff = el.prop('scrollWidth') - (scrollLeft+el.width());
      if diff < @start_add_from
        console.info 'need_add'
        @renderBackgroundCalendar()
      else if scrollLeft < 101
        console.info 'scrLeft', scrollLeft
        @renderBackgroundCalendar('before')
    , 500
    }

    $scope.$watch 'viewType', ()->
      timeline.init();

###
    renderBackgroundTemplate = $compile('#seaview');

    $timeout ()->
      el.html 'tis = '+JSON.stringify $scope.getEvent({startDate: start_date, finishDate: finish_date})
      $scope.title = 'Fucking...'
      sc = $scope.$new();
      sc.title = 'tuc';
      el.html renderBackgroundTemplate(sc)
    , 1000

###

