angular.module("4treeApp").factory 'datasourceTree', ['$timeout', 'db_tree', '$rootScope',
  ($timeout, db_tree, $rootScope)->
    watchList: []
    get: (index, count, success)->
      __log.info index
      success([]) if index > db_tree._db.tree.length
      result = []
      for i in [index..index + count - 1]
        result.push db_tree._db.tree[i] if db_tree._db.tree[i]
      success(result)
]

angular.module("4treeApp").factory 'datasource', ['$timeout', '$rootScope', ($timeout, $rootScope)->
  get: (index, count, success)->
    result = []
    for i in [index..index + count - 1]
      result.push "{i}"
    success(result)
  scope2: $rootScope
]

angular.module("4treeApp").service 'db_tree', ['$translate', '$http', '$q', '$rootScope', 'oAuth2Api', '$timeout',
                                               '$socket', '$location', 'settingsApi',
  ($translate, $http, $q, $rootScope, oAuth2Api, $timeout, $socket, $location, settingsApi) ->
    _db:
      texts: {}
    _tmp:
      _diffs: {}
    _cache: {}
    salt: ()->
      'Salt is a mineral substance composed'
    pepper: ()->
      ' primarily of sodium chloride (NaCl)'
    constructor: () ->
      mythis = @;
      $rootScope.$on 'jsFindAndSaveDiff', (event, db_name, new_value, old_value)->
        mythis.saveDiff(db_name, new_value._id) if new_value and new_value._id

      $rootScope.$on 'my-sorted', (event, data)->
        $timeout ()->
          __log.info "SORTED", data
          element = mythis.jsFind(data.from_id);
          old_value = _.clone(element); #clone
          element.parent_id = data.to_id;
          new_value = element;
          $rootScope.$emit("jsFindAndSaveDiff", 'tree', new_value, old_value);

          mythis.refreshParentsIndex();
          $timeout ()->
            $("ul > .tree_tmpl").remove()


      $rootScope.$on 'my-created', (event, data)->
        __log.info "CREATED", data
      @loadTasks();
      if(!@_cache)
        @_cache = {}
      if(!@_db.tree)
        @_db.tree = {
        }
        @refreshParentsIndex();
    clearCache: ()->
      _.each @, (fn)->
        fn.cache = {} if fn
      _.each $rootScope.$$childTail.fn.service.calendarBox, (fn)->
        fn.cache = {} if fn
    getTreeFromeWebOrLocal: ()->
      mythis = @;
      @dbInit();
      dfd = $.Deferred();
      @ydnLoadFromLocalStorage(mythis).then (records)->
        if !records.tree or Object.keys(records.tree).length == 0
          __log.info 'NEED DATA FROM NET';
          mythis.getTreeFromWeb().then (data)->
            result = {};
            async.each Object.keys(data), (db_name, callback)->
              records = data[db_name]
              result[db_name] = records;
              mythis.ydnSaveToLocal(db_name, records).then ()->
                callback()
            , ()->
              dfd.resolve(result);

        else
          __log.info 'ALL DATA FROM LOCAL'
          dfd.resolve(records);
      dfd.promise();
    #Устанавливает главный выбранный элемент и hash в адресную строку
    setMainTimeout: null
    setMain: (el)->
      $rootScope.$$childTail.db.main_node[ settingsApi.tmp.focus ] = el;
      @setTab(el)
      hash = ''+ el._id.substr(el._id.length-5,el._id.length) if el?._id
      $timeout.cancel @setMainTimeout if @setMainTimeout
      @setMainTimeout = $timeout ()->
        $location.hash( hash )
      , 5000
    #Функции работы с верхними Tabs
    setTab: (el)->
      found = _.find settingsApi.set.tabs, (doc)->
        el._id == doc.tab_id
      if !found
        settingsApi.set.tabs.push({ tab_id: el._id, tm: new Date(), show_only_icon:false });
    getTreeFromNet: ()->
      mythis = @;
      dfd = $q.defer();
      console.time 'ALL DATA LOADED'
      @getTreeFromeWebOrLocal().then (records)->
        _.each records, (data, db_name)->
          canStoreInThisDB = mythis.dont_store_to_memory.indexOf(db_name) == -1
          if canStoreInThisDB
            mythis._db[db_name] = data;
        mythis.refreshParentsIndex();
        settingsApi.tmp.tree_loaded = new Date();
        $rootScope.$$childTail.db.main_node = []
        $rootScope.$broadcast('tree_loaded');
        mythis.TestJson() if false
        if !$rootScope.$$childTail.db.main_node[ settingsApi.tmp.focus ]
          found = _.find mythis._db['tree'], (el)->
            el.title == '_НОВОЕ'
          mythis.setMain(found)
        mythis.clearCache();
        console.timeEnd 'ALL DATA LOADED!'
        dfd.resolve();
      dfd.promise;
    getTreeFromWeb: ()->
      dfd = $q.defer();
      mythis = @;
      #@loadAllTreeFromLocal();
      #return true;

      oAuth2Api.jsGetToken().then (access_token)->
        $http({
          url: settingsApi.set.server + '/api/v2/tree',
          method: "GET",
          params:
            user_id: '5330ff92898a2b63c2f7095f'
            access_token: access_token
            machine: settingsApi.set.machine
        }).then (result)->
          dfd.resolve(result.data);
      dfd.promise;
    db: undefined
    jsSaveManyElementsToLocal: (db_name, elements)->
      dfd = $.Deferred();
      console.info 'saved many to '+db_name+' for '+elements.length
      console.time 'saved many to '+db_name+' for '+elements.length
      _.each elements, (el)->
        delete el.$$hashKey if el and el.$$hashKey
      @db.put(db_name, elements).done ()->
        console.timeEnd 'saved many to '+db_name+' for '+elements.length
        dfd.resolve();
      dfd.promise();
    jsSaveElementToLocal: (db_name, el)->
      dfd = $.Deferred();
      delete el.$$hashKey if el and el.$$hashKey
      @db.put(db_name, el).done ()->
        dfd.resolve();
      dfd.promise();

    store_schema: [
      {
        name: 'tree',
        keyPath: '_id',
        autoIncrement: false
      }
      {
        name: 'tasks',
        keyPath: '_id',
        autoIncrement: false
      }
      {
        name: 'texts',
        keyPath: '_id',
        autoIncrement: false
      }
      {
        name: '_diffs'
        keyPath: '_id',
        autoIncrement: false
      }
    ]
    dont_store_to_memory: ['texts']
    dbInit: ()->
      schema = {
        stores: @store_schema
      };
      options = {
      #mechanisms: ['indexeddb', 'websql', 'localstorage', 'sessionstorage', 'userdata', 'memory']
      #size: 50 * 1024 * 1024
      }
      @db = new ydn.db.Storage('_db.tree', schema, options);
      if false
        @db.search('name', 'Рабочие').done (x)->
          __log.info 'found', x


    ydnSaveToLocal: (db_name, records)->
      dfd = $.Deferred();
      @dbInit();
      console.time 'saveTo-'+db_name;
      mythis = @;
      mythis._tmp._diffs = {}
      @db.clear('_diffs').done ()->

        mythis.db.clear(db_name).done ()->
          i = 0
          chunks = _.groupBy records, (el, index)->
            #console.info el, index
            return Math.floor( (i++)/300 );
          chunks = _.toArray(chunks);
          async.eachLimit Object.keys(chunks), 300, (chunk, callback)->
            elements = chunks[chunk];
            mythis.jsSaveManyElementsToLocal(db_name, elements).then ()->
              callback();

          , (err)->
            console.timeEnd 'saveTo-'+db_name;
            dfd.resolve();
      dfd.promise();
    ydnLoadFromLocalStorage: (mythis)->
      @dbInit();
      dfd = $.Deferred();
      console.time 'load_local' if __log.show_time_long
      result = {};
      mythis.db.values('_diffs', null, 999999999).done (diffs)->
        _.each diffs, (diff)->
          mythis._tmp._diffs[diff._id] = diff
        async.each mythis.store_schema, (table_schema, callback)->
          db_name = table_schema.name;
          if mythis.dont_store_to_memory.indexOf(db_name) == -1
            mythis.db.values(db_name, null, 999999999).done (records)->
              #Если есть патчи, применяем их (патчи будут удалены после удачной синхронизации
              if diffs
                _.each diffs, (diff)->
                  found = _.find records, (record)->
                    record._id == diff._id
                  if found and db_name == diff.db_name
                    found = mythis.diff.patch(found, diff.patch);
              data_to_load = {};
              _.each records, (record)->
                data_to_load[record._id] = record if record?._id
              result[db_name] = data_to_load;
              callback();
          else
            callback();
        , ()->
          console.timeEnd 'load_local' if __log.show_time_long
          dfd.resolve(result);
          result = undefined;
      dfd.promise();

    refreshParentsIndex: (parent_id)->
      focus = settingsApi.tmp.focus
      mythis = @;
      if !parent_id
        mythis.db_parents = {}
      else
        mythis.db_parents['n' + parent_id] = []

      found = _.find @_db.tree, (el)->
        el.folder == 'main'
      if found
        if settingsApi.set.main_parent_id.length == 0
          settingsApi.set.main_parent_id[0] = found._id
          settingsApi.set.main_parent_id[1] = found._id
          settingsApi.set.main_parent_id[2] = found._id
          settingsApi.set.main_parent_id[3] = found._id
        settingsApi.set.top_parent_id = found._id


      _.each @_db.tree, (el)->
        if parent_id and el.parent_id != parent_id
          return true
        cnt = [
          {title: 'шагов', cnt_today: 20, days: [
            {d: '2013-03-01', cnt: 12}
            {d: '2013-03-02', cnt: 10}
            {d: '2013-03-03', cnt: 8}
            {d: '2013-03-05', cnt: 15}
            {d: '2013-03-12', cnt: 21}
          ]}
          {title: 'прошёл км.', cnt_today: 30, days: [
            {d: '2013-03-01', cnt: 12}
            {d: '2013-03-02', cnt: 10}
            {d: '2013-03-03', cnt: 8}
            {d: '2013-03-05', cnt: 15}
            {d: '2013-03-12', cnt: 21}
          ]}
          {title: 'отжиманий', cnt_today: 19, days: [
            {d: '2013-03-01', cnt: 12}
            {d: '2013-03-02', cnt: 10}
            {d: '2013-03-03', cnt: 8}
            {d: '2013-03-05', cnt: 15}
            {d: '2013-03-12', cnt: 21}
          ]}
        ]
        el._path = mythis.jsGetPath(el._id) if el._id and el._id != 1
        el.importance = if el.importance then el.importance else 50;
        el.tags = if el.tags then el.tags else [];
        el.counters = cnt if !el.counters
        el._panel = [
          {_open: false},
          {_open: false},
          {_open: false},
          {_open: false}
        ] if !el._panel
        #el._open = false if el.parent_id != '1';
        if false
          el.dates = {
            startDate: if el.dates then moment(el.dates.startDate) else ""
            endDate: if el.dates then moment(el.dates.endDate) else ""
          }
        parent = 'n' + el.parent_id

        mythis.db_parents[parent] = [] if !mythis.db_parents[parent]
        mythis.db_parents[parent].push(el);
        return true

      _.each mythis._db.tree, (el, key)->
        parent = 'n' + el._id
        if mythis.db_parents[parent]
          el._childs = mythis.db_parents[parent].length
        else
          el._childs = 0;
          el._open = false;
        true
      mythis.clearCache();
      true


      mymap = (doc, emit)->
        emit(doc.date, doc.title, doc) if doc.text and doc.text.indexOf('жопа') != -1

      #@newView('tree', 'by_date', mymap);

      mymap_calendar = (doc, emit)->
        if (doc?.date2 or doc?.date1) and doc?.date_on and !doc?.hide_in_todo
          emit(doc.date1, doc, doc)

      myreduce_calendar = (memo, values)->
        key = values.key;
        key = moment(values.key);
        key = key.format("YYYY-MM-DD")
        day1 = new Date(values.value.date1).getTime();
        day2 = new Date(values.value.date2).getTime()
        days = (day2 - day1)/(24*60*60*1000);
        if days > 0
          while (days--)>0
            day = day1 + days*24*60*60*1000;
            key = moment( new Date(day) );
            key = key.format("YYYY-MM-DD");
            memo[key] = [] if !memo[key]
            memo[key].push(values.value) if values.value

      @newView('tasks', 'tasks_by_date', mymap_calendar, myreduce_calendar)

      mymap_calendar = (doc, emit)->
        if (doc?.tree_id)
          emit(doc.tree_id, doc, doc)

      myreduce_calendar = (memo, values)->
        key = values.key;
        memo[key] = {tasks: [], next_action: [], cnt: 0} if !memo[key]
        memo[key].tasks.push(values.value) if values.value
        memo[key].cnt = memo[key].tasks.length if memo[key].tasks
        if memo[key].cnt > 0
          sorted = mythis.sortTasks(memo[key].tasks)
        memo[key].tasks = sorted;
        memo[key].next_action = mythis.getNextAction(sorted);

      mythis.newView('tasks', 'tasks_by_tree_id', mymap_calendar, myreduce_calendar)

      return


    getTree: (args) ->
      @_db.tree
    jsFindByParent: _.memoize (args) ->
      elements = _.sortBy @db_parents['n' + args], (value, key)->
        value.pos
      elements = _.filter elements, (value)->
        value.del != 1
    , (args)->
      args+' '+settingsApi.tmp.tree_loaded


    'web_tags': [
      {id: 1, parent: 0, title: "Кулинария", cnt: 1}
      {id: 5, parent: 1, title: "Супы", cnt: 6}
      {id: 7, parent: 5, title: "Диетические", cnt: 1}
      {id: 8, parent: 5, title: "Фруктовые", cnt: 3}
      {id: 6, parent: 1, title: "Каши", cnt: 3}
      {id: 2, parent: 0, title: "Рукоделие", cnt: 1}
      {id: 9, parent: 2, title: "Холодный фарфор", cnt: 2}
      {id: 10, parent: 2, title: "Тильда", cnt: 0}
      {id: 10, parent: 2, title: "Скрапбукинг", cnt: 1}
      {id: 10, parent: 2, title: "Канзаши", cnt: 3}
      {id: 10, parent: 2, title: "Бисероплетение", cnt: 211}
      {id: 10, parent: 2, title: "Вязание", cnt: 1}
      {id: 3, parent: 0, title: "Мои новости", cnt: 8}
      {id: 4, parent: 0, title: "Я в лицах", cnt: 11}
    ]
    tree_tags: [
      {id: 1, parent: 0, title: "GTD", cnt: 0}
      {id: 4, parent: 1, title: "Входящие", cnt: 12}
      {id: 2, parent: 1, title: "Следующие действия", cnt: 4}
      {id: 3, parent: 1, title: "Когда-нибудь", cnt: 24}
      {id: 5, parent: 1, title: "Календарь", cnt: 120}
      {id: 6, parent: 1, title: "Ожидание", cnt: 8}
      {id: 7, parent: 1, title: "Проект", cnt: 3}
      {id: 8, parent: 0, title: "Рабочие дела", cnt: 4}
      {id: 9, parent: 0, title: "Домашние дела", cnt: 8}
      {id: 10, parent: 0, title: "Мой сайт", cnt: 18}
      {id: 11, parent: 0, title: "Чтение", cnt: 0}
      {id: 12, parent: 11, title: "Почитать", cnt: 2}
      {id: 13, parent: 11, title: "Прочитано", cnt: 243}

    ]
    jsFindByParentWeb: (args) ->
      _.filter @web_tags, (el)->
        el.parent_id == args
    jsFindByParentTags: (args) ->
      _.filter @tree_tags, (el)->
        el.parent_id == args
    'first_element':
      title: '4tree'
      parent_id: '0'
      _path: ['2']
    'jsFind': (id)->
      if id == 1
        return @first_element
      found = @_db['tree'][id] if @_db?['tree']?[id]
      return undefined if id == undefined
      found


    'jsGetPath': _.memoize (id) ->
      return ['100'] if id == 1 or id == 0
      path = [];
      prevent_recursive = 1000;
      while (el = @jsFind(id)) and (prevent_recursive--)
        id = el.parent_id
        path.push(el._id) if el.parent_id
      path.push(settingsApi.set.top_parent_id);
      path.reverse();
    jsView: ()->
      @_cache


    newView: (db_name, view_name, mymap, myreduce)->
      mythis = @;
      mythis._cache[db_name] = {} if !mythis._cache[db_name]
      # if !mythis._cache[db_name]
      mythis._cache[db_name]['views'] = {} if !mythis._cache[db_name]['views']

      if !mythis._cache[db_name]['views'][view_name]
        mythis._cache[db_name]['views'][view_name] = {
          rows: []
          invalid: []
          'map': mymap
          'reduce': myreduce
        }
    getView: (db_name, view_name)->
      view = @_cache[db_name]['views'][view_name];
      if view and view.rows
        if( view.rows.length && view.invalid.length == 0 )
          return view;
        else if (view.invalid.length > 0 and view.rows.length > 0)
          @generateView(db_name, view_name, view.invalid);
          return view;
        else
          @generateView(db_name, view_name);
          return view;
      else
        console.info 'NOT FOUND VIEW', db_name, view_name
        return


    generateView: (db_name, view_name, view_invalid)->
      view = @_cache[db_name]['views'][view_name];

      if view_invalid?[0] == 0
        view_invalid = false;

      if view_invalid
        myrows = [ _.find @_db[db_name], (el)->
          view_invalid.indexOf(el._id) != -1
        ]
        view.rows = _.filter view.rows, (el)->
          view_invalid.indexOf(el._id) == -1
      else
        myrows = @_db[db_name]

      memo = {};

      emit = (key, value, doc)->
        view.rows = [] if !view.rows
        view.rows.push({_id: doc._id, key, value})
        view['reduce'](memo, {key, value}) if !view_invalid and view['reduce']

      _.each myrows, (doc, key)->
        result = view['map'](doc, emit);

      if view_invalid and view['reduce']
        _.each view.rows, (doc)->
          view['reduce'](memo, {key: doc.key, value: doc.value})

      view.rows = _.sortBy view.rows, (el)->
        el.key

      view.invalid = [];

      view.result = memo;

    refreshView: (db_name, ids, new_value, old_value)->
      mythis = @;
      _.each ids, (id)->
        _.each mythis._cache[db_name]?.views, (view)->
          view.invalid.push(id)
      @clearCache();

########################## T A S K S ########################
    loadTasks: ()->
      true
    clearCache2: ()->
      _.each @, (fn)->
        fn.cache = {} if fn and fn.cache
    getTasks: ()->
      @_db.tasks;
    calcWeight: (el)->
      mythis = @;
      round = (value)->
        Math.round( parseInt(value*100) )/100
      weight_date = settingsApi.set.weight.date;
      weight_importance = settingsApi.set.weight.importance;
      w = {};
      w['tree_id'] = mythis._db?.tree?[el.tree_id]?.importance;
      w['did'] = 0;
      w['created'] = (new Date(el.created).getTime()-settingsApi.set.today_date_time)/(24*60*60*1000*10)
      if !!el.did
        w['did'] = -50000;
      if el.date2
        w['date1'] = (new Date(el.date2).getTime() -  settingsApi.set.today_date_time )/(24*60*60*1000);
      else
        w['date1'] = -500
        w['importance'] = (if el.importance then el.importance else 50) * weight_importance;
      weight = _.reduce w, (memo, el)->
        memo + el
      { weights: w, weight }

    pad: (str, max)->
      str = str.toString();
      return if str.length < max then pad("0" + str, max) else str;
    sortTasks: (answer, order_type = 'by_priority_and_date')->
      mythis = @;
      if order_type == 'by_priority_and_date'
        answer = _.sortBy answer, (el)->
          w = mythis.calcWeight(el);
          return -(w.weight)
      answer
    getNextAction: (answer)->
      today = new Date();
      na = [];
      na2 = [];
      na3 = [];
      _.each answer, (el)->
        if !el.did
          if (!na2.length and !el.date1)
            na2 = [el];
          na = [el] if !na.length
          el_date = new Date(el.date1);
          na_date = new Date(na?[0]?.date1);
          if ( el.date1 and (el_date < na_date ) and (el_date <= today) )
            na = [el];
          if ( el.date1 and (el_date < na_date ) and (el_date > today ) )
            na3 = [el];
      na_date = new Date(na?[0]?.date1);
      if (!na.length or (na.length and na_date>today) ) and na2.length
        na = na2
      if !na.length and !na2.length and na3.length and false
        na = na3




      na

    jsExpand: (id, make_open)->
      console.time 'expand' if __log.show_time_long
      focus = settingsApi.tmp.focus
      _.each @_db.tree, (el)->
        if el._path and el._path.indexOf(id) != -1
          if !(make_open == true and el._childs > 50)
            el._panel[focus]._open = make_open if el._childs > 0
          else
            el._open = undefined
        return
      console.timeEnd 'expand' if __log.show_time_long
    tree_template: ()->
      return {
      title: ''
      parent_id: ''
      _id: ''
      }
    task_template: ()->
      return {
      title: ''
      parent_id: ''
      _id: ''
      }
    getIcon: (tree)->
      if (!tree.icon)
        return 'icon-heart-empty'
      else
        return tree.icon
    diffForSort: (tree)->
      parents = @db_parents['n' + tree.parent_id];
      parents = _.sortBy parents, (value)->
        value.pos
      found = _.find parents, (value)->
        value.pos > tree.pos
      if found and found.pos
        __log.info "POS = ", found.pos, tree.pos
        sortPrice = (parseInt(1000000000000 * (found.pos - tree.pos) / 1.1)) / 1000000000000
        return sortPrice
      else
        return 1
    jsAddNote: (tree, make_child)->
      focus = settingsApi.tmp.focus
      __log.info "AddNote", tree
      new_note = new @tree_template;
      new_note.title = settingsApi.set.new_title;
      new_note._id = new ObjectId().toString();
      new_note['_new'] = true
      new_note._focus_me = true;
      new_note.user_id = settingsApi.set.user_id;
      new_note.pos = tree.pos + @diffForSort(tree);
      @_db.tree[new_note._id] = new_note
      if !make_child
        new_note.parent_id = tree.parent_id;
        @refreshParentsIndex(tree.parent_id);
      else
        new_note.parent_id = tree._id;
        @refreshParentsIndex();
        tree._open = true;
      @main_node new_note
      @clearCache();
    jsAddTask: (event, scope, tree)->
      event.stopPropagation();
      event.preventDefault();
      mythis = $rootScope.$$childTail.fn.service.db_tree;
      __log.info 'add_task', event, scope, tree;
      tree_id = scope.db.main_node[scope.tmp.focus_edit]._id
      if tree_id
        new_task = new mythis.task_template;
        new_task._id = new ObjectId().toString();
        new_task.tree_id = tree_id;
        new_task.parent_id = tree_id;
        new_task._new = true;
        new_task.created = new Date();
        new_task.importance = 50;
        new_task.user_id = settingsApi.set.user_id;
        old_value = _.clone(new_task); #clone
        new_task.title = scope.new_task_title;
        mythis._db.tasks[new_task._id] = new_task if !mythis._db.tasks[new_task._id]
        __log.info 'pushed new task', new_task;
        scope.new_task_title = "";
        mythis.clearCache();
        new_value = new_task;
        $rootScope.$emit("jsFindAndSaveDiff", 'tasks', new_value, old_value);



    jsEnterPress: (event, scope, tree)->
      event.target.blur()
    jsBlur: (event, scope, tree)->
      tree['_new'] = false if false;
    jsFindPreviusParent: (tree)->
      parents = $rootScope.$$childTail.fn.service.db_tree.db_parents['n' + tree.parent_id];
      parents = _.sortBy parents, (value)->
        value.pos
      found = _.filter parents, (value)->
        value.pos < tree.pos
      found = found[found.length - 1];

    jsEscPress: (event, scope)->
      focus = settingsApi.tmp.focus
      prev_note = $rootScope.$$childTail.fn.service.db_tree.jsFindPreviusParent(scope.tree);
      scope.tree.del = 1 if scope.tree['_new']
      @setMain prev_note if prev_note
      event.target.blur()
    findMaxPos: (prev_note_id)->
      parents = $rootScope.$$childTail.fn.service.db_tree.db_parents['n' + prev_note_id];
      parents = _.sortBy parents, (value)->
        value.pos
      if parents.length
        return parents[parents.length - 1].pos + 1
      else
        return 1
    jsTabPress: (event, scope, tree)->
      focus = settingsApi.tmp.focus
      db_tree = $rootScope.$$childTail.fn.service.db_tree;
      if (db_tree.jsIsTree())
        event.stopPropagation();
        event.preventDefault();
        main_node = $rootScope.$$childTail.db.main_node[focus];
        __log.info main_node;

        shift = event.shiftKey;
        if !shift
          prev_note = db_tree.jsFindPreviusParent(main_node);
          if prev_note
            prev_note._panel[focus]._open = true;
            main_node.parent_id = prev_note._id;
            main_node.pos = db_tree.findMaxPos(prev_note._id);
            main_node._focus_me = true;
            db_tree.refreshParentsIndex();
        else
          parent_note = db_tree.jsFind(main_node.parent_id);
          __log.info { parent_note }
          if parent_note and parent_note.folder != 'main'
            main_node.parent_id = parent_note.parent_id;
            main_node.pos = parent_note.pos + db_tree.diffForSort(parent_note);
            main_node._focus_me = true;
            db_tree.refreshParentsIndex();
    jsFindNext: (tree, ignore_open)->
      focus = settingsApi.tmp.focus
      db_tree = $rootScope.$$childTail.fn.service.db_tree;
      if tree and tree._panel[focus]._open and !ignore_open
        found = db_tree.db_parents['n' + tree._id][0] if db_tree.db_parents['n' + tree._id]
        return found
      parents = db_tree.db_parents['n' + tree.parent_id];
      parents = _.sortBy parents, (value)->
        value.pos
      found_key = 0;
      found = _.find parents, (value, key)->
        found_key = key if (value._id == tree._id)
        value._id == tree._id
      found = parents[found_key + 1];
      if !found
        __log.info 'need_to_parent'
        next = db_tree.jsFind(tree.parent_id);
        found = db_tree.jsFindNext(next, 'ignore_open') if next
      found
    jsFindPrev: (tree, ignore_open, last_and_deep)->
      focus = settingsApi.tmp.focus
      db_tree = $rootScope.$$childTail.fn.service.db_tree;
      if (tree and tree._open2 and !ignore_open) or (last_and_deep)
        parents = db_tree.db_parents['n' + tree._id];
        found = parents[parents.length - 1];
        if last_and_deep and found._open
          return db_tree.jsFindPrev(found, 'true', 'last_and_deep')
        else
          return found
      parents = db_tree.db_parents['n' + tree.parent_id];
      parents = _.sortBy parents, (value)->
        value.pos
      found_key = 0;
      found = _.find parents, (value, key)->
        found_key = key if (value._id == tree._id)
        value._id == tree._id
      found = parents[found_key - 1];
      if found and found._panel[focus]._open
        found = db_tree.jsFindPrev(db_tree.jsFind(found._id), 'ignore_open', 'last_and_deep');
      if !found and !ignore_open and !last_and_deep
        found = db_tree.jsFind(tree.parent_id) if tree.parent_id != settingsApi.set.main_parent_id[focus]
      found
    jsIsTree: ()->
      focus = settingsApi.tmp.focus
      widget_index = settingsApi.set._panel[focus].active
      if ([0].indexOf(widget_index) != -1)
        return true
      else
        return false
    jsUpPress: (event, scope)->
      focus = settingsApi.tmp.focus
      db_tree = $rootScope.$$childTail.fn.service.db_tree;
      if (db_tree.jsIsTree())
        event.stopPropagation();
        event.preventDefault();
        found = db_tree.jsFindPrev($rootScope.$$childTail.db.main_node[focus]);
        if found
          @setMain found
    jsDownPress: (event, scope)->
      focus = settingsApi.tmp.focus
      db_tree = $rootScope.$$childTail.fn.service.db_tree;
      if (db_tree.jsIsTree())
        event.stopPropagation();
        event.preventDefault();
        found = db_tree.jsFindNext($rootScope.$$childTail.db.main_node[focus]);
        if found
          @setMain found
    jsLeftPress: (event, scope)->
      focus = settingsApi.tmp.focus
      db_tree = $rootScope.$$childTail.fn.service.db_tree;
      if (db_tree.jsIsTree())
        event.stopPropagation();
        event.preventDefault();
        if $rootScope.$$childTail.db.main_node[focus]._panel[focus]._open
          $rootScope.$$childTail.db.main_node[focus]._panel[focus]._open = false;
        else
          true
    jsRightPress: (event, scope)->
      focus = settingsApi.tmp.focus
      db_tree = $rootScope.$$childTail.fn.service.db_tree;
      if (db_tree.jsIsTree())
        event.stopPropagation();
        event.preventDefault();
        if !$rootScope.$$childTail.db.main_node[focus]._panel[focus]._open
          $rootScope.$$childTail.db.main_node[focus]._panel[focus]._open = true;
        else
          true
    jsFocus1: ()->
      settingsApi.tmp.focus = 0
    jsFocus2: ()->
      settingsApi.tmp.focus = 1
    jsFocus3: ()->
      settingsApi.tmp.focus = 2
    jsFocus4: ()->
      settingsApi.tmp.focus = 3
    searchString: (searchString, dont_need_highlight)->
      dfd = new $.Deferred();
      __log.info 'search', searchString
      oAuth2Api.jsGetToken().then (access_token)->
        $http({
          url: settingsApi.set.server + '/api/v1/search',
          method: "GET",
          params:
            user_id: '5330ff92898a2b63c2f7095f'
            access_token: access_token
            search: searchString
            machine: settingsApi.set.machine
            dont_need_highlight: dont_need_highlight
        }).then (result)->
          dfd.resolve(result.data);
      dfd.promise();
    jsTreeToDiary: (tree_el)->
      tree_el.diary = new Date();
    diaryFind: _.memoize (date)->
      mythis = @;
      mymap_diary = (doc, emit)->
        emit(doc.diary, doc, doc) if doc?.diary

      myreduce_diary = (memo, values)->
        key = values.key;
        key = moment(values.key);
        key = key.format("YYYY-MM-DD")
        memo[key] = [] if !memo[key]
        memo[key].push(values.value) if values.value

      @newView('tree', 'diary_by_date', mymap_diary, myreduce_diary)

      key = moment(date).format('YYYY-MM-DD');
      answer = mythis.getView('tree', 'diary_by_date').result[key]
      __log.info answer, date, answer.text if answer
      answer
    diff: jsondiffpatch.create {
      objectHash: (obj) ->
        # try to find an id property, otherwise serialize it all
        return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);
      textDiff:
        minLength: 3
    }
    dfdTextLater: $q.defer()
    getTextLater: _.throttle (text_id)->
      mythis = @;
      $timeout ()->
        mythis.getText(text_id).then (text_element)->
          if text_element
            mythis.dfdTextLater.resolve(text_element)
          else
            __log.info 'text_not_found';
            mythis.dfdTextLater.resolve()
      , 1000
      mythis.dfdTextLater.promise
    , 3000
    getTextFromDB: (text_id)->
      mythis = @;
      dfd = $q.defer();
      patch_found = mythis._tmp._diffs[text_id]
      mythis.db.get('texts', text_id).done (found)->
        if found
          new_text = mythis.diff.patch({ txt: found.text}, patch_found.patch) if patch_found
          found.text = new_text.txt.toString() if new_text
          dfd.resolve(found)
        else
          #Запрошу текст из LocalDB чуть позже (видимо ещё не сохранился)
          mythis.getTextLater(text_id).then (text_element)->
            dfd.resolve(text_element);
        return
      return
      return dfd.promise;
    getText: (text_id)->
      mythis = @;
      dfd = $q.defer();
      @getElement('texts', text_id).then (text_element)->
        dfd.resolve(text_element);
      dfd.promise;
    setText: (text_id, new_text)->
      mythis = @;
      found = @_db['texts'][text_id]
      if (found)
        found.text = new_text
        mythis.saveDiff('texts', text_id)
      else
        if text_id and new_text.length
          doc = {
            _id: text_id
            _tm: new Date()
            db_name: 'trees'
            text: new_text
            user_id: settingsApi.set.user_id
            del: 0
            _new: true
          }
          doc._sha1 = mythis.JSON_stringify(doc)._sha1
          @_db['texts'][text_id] = doc
          mythis.db.put('texts', doc).done ()->
            __log.info 'text ' + text_id + ' saved', doc


    'jsStartSyncInWhile': _.debounce ()->
      @syncDiff() if false or settingsApi.set.autosync_on
    , 1000
    'jsStartSyncRightNow': _.debounce ()->
      @syncDiff() if false or settingsApi.set.autosync_on
    , 10
    saveDiff: _.throttle (db_name, _id)->
      mythis = @;
      #__log.info 'save_diff starting.....' + _id;
      dfd = $q.defer();
      @getElement(db_name, _id).then (new_element)->
        mythis.getElementFromLocal(db_name, _id).then (old_element)->
          if new_element and old_element
            patch = mythis.diff.diff(old_element, new_element);
            delete patch._sha1 if patch and patch._sha1
            delete patch._tm if patch and patch._tm
            if patch
              _.each Object.keys(patch), (key)->
                delete patch[key] if patch[key] and (key[0] == '_' or key[0] == '$')
            #__log.info 'DIFF SAVED = ', JSON.stringify(patch), (JSON.stringify patch)?.length;
            el = {
              _id: _id
              patch: patch
              db_name: db_name
              _sha1: old_element._sha1
              user_id: settingsApi.set.user_id
              machine: settingsApi.set.machine
              _tm: new Date().getTime()
            }
            if patch and !_.isEmpty(patch)
              #если синхронизация уже идёт, то изменения пока не сохраняем
              mythis._tmp._diffs[el._id] = el
              mythis.db.put('_diffs', el).done ()->
                #__log.info 'diff_saved'
                dfd.resolve()
                mythis.jsStartSyncInWhile()
                $('.sync').addClass('need_sync');
                mythis.refreshView db_name, [new_element._id] #обновляем все View с этим элементом
          else
            if new_element and new_element._new == true
              dfd.resolve()
              mythis.jsStartSyncInWhile()
              $('.sync').addClass('need_sync');
              mythis.refreshView db_name, [new_element._id] #обновляем все View с этим элементом
        return
        return
      dfd.promise
    , 50

    getElementFromLocalPlusDiffs: (db_name, _id)->
      dfd = $q.defer();
      mythis = @;
      @getElementFromLocal(db_name, _id).then (result)->
        diff = mythis._tmp._diffs[ _id ]

        if diff and diff._id and diff.db_name == db_name
          result = mythis.diff.patch(result, diff.patch)
          dfd.resolve(result);
        else
          dfd.resolve(result);
        return
      dfd.promise

    getElementFromLocal: (db_name, _id)->
      mythis = @;
      dfd = $q.defer()
      @db.get(db_name, _id).done (result)->
        dfd.resolve(result);
      return dfd.promise

    getElement: (db_name, _id)->
      mythis = @;
      dfd = $q.defer()
      if !_id
        dfd.resolve();
        return dfd.promise
      found = @_db?[db_name]?[_id];
      if !found and _id
        mythis.getElementFromLocalPlusDiffs(db_name, _id).then (found)->
          if found
            mythis._db[db_name][found._id] = found
          dfd.resolve(found);
      else
        dfd.resolve(found)
      return dfd.promise

    tmp_set: (_id)->
      mythis = @;
      dfd = $q.defer()
      mythis.getElement('texts', _id).then (result)->
        mythis._db['texts'][_id].text = result.text + '<p>' + Math.round(Math.random() * 100) + '</p>'
        __log.info 'ADDED ', mythis._db['texts'][_id].text
        mythis.saveDiff('texts', _id).then ()->
          dfd.resolve()
      dfd.promise

    copyObject: (source, obj)->
      newObj = source;
      for key of obj
        newObj[key] = obj[key];
      return newObj;

    #Применяем результат синхронизации
    syncApplyResults: (results)->
      dfd = $q.defer();
      mythis = @;
      __log.debug 'syncApply', 'Начинаю применять результаты синхронизации', {};
      if  mythis.before_sync and mythis.before_sync.length
        __log.debug 'syncApply', 'Есть сохранённые бекапы элементов', { before_sync: mythis.before_sync}
      mythis.clearCache();
      _.each Object.keys(results), (db_name)->
        db_data = results[db_name];
        if db_data and _.isObject(db_data.not_found)
          _.each Object.keys(db_data.not_found), (not_found)->
            sha1_of_not_found = db_data.not_found[not_found]
            console.error 'NEED RESEND ALL ELEMENT NEXT TIME', not_found, sha1_of_not_found
            mythis._tmp._send_doc_next_time = {} if !mythis._tmp._send_doc_next_time
            mythis._tmp._send_doc_next_time[db_name] = {} if !mythis._tmp._send_doc_next_time[db_name]
            mythis._tmp._send_doc_next_time[db_name][not_found] = sha1_of_not_found

        if db_data and _.isObject(db_data.confirm)
          _.each Object.keys(db_data.confirm), (confirm_id)->
            #mythis.tmp_set(confirm_id).then ()->
            confirm_element = db_data.confirm[confirm_id]
            __log.debug 'syncApply', 'Применяю первое подтверждение для ' + confirm_id, { confirm_element };
            __log.debug 'syncApply', 'Мне прислали _sha1 = ' + confirm_element._sha1, {};
            # тут нужно учесть, вдруг во время синхронизации элемент изменился
            # TODO Нужно учесть, вдруг элемент изменился
            mythis.getElement(db_name, confirm_id).then (doc)->
              if doc
                __log.debug 'syncApply', 'В своей базе (+patch) я нашёл _sha1 = ' + doc._sha1, { doc };
                if doc._new
                  doc._new = false
                  __log.debug 'syncApply', 'Элемент в базе был новым, я его отметил старым', {}
                sha1 = mythis.JSON_stringify(doc)._sha1
                __log.debug 'syncApply', 'Вычислил актуальный _sha1 = ' + sha1, { doc }
                #Если контрольные суммы сервера и клиента совпали, то удаляем diff и обновляем _sha1
                if sha1 == confirm_element._sha1
                  __log.debug 'syncApply', '_sha1 ' + sha1 + ' совпали, всё в порядке', {}
                  doc._sha1 = confirm_element._sha1
                  __log.debug 'syncApply', '_sha1 совпали, присваиваю doc._sha1 = ' + confirm_element._sha1, { confirm_element, doc }
                  doc._tm = confirm_element._tm
                  __log.debug 'syncApply', '_sha1 совпали, обновил _tm и sha1 и сохраняю в базу', { doc }
                  mythis.db.put(db_name, doc).done (err)->
                    __log.info 'new data applyed', err, doc;
                    __log.debug 'syncApply', '_sha1 совпали. Сохранил в базу данных ' + doc._sha1, { err, doc }
                  __log.debug 'syncApply', '_sha1 совпали. Удалил локальные дифы. ', {}
                  delete mythis._tmp._diffs[confirm_id] if mythis._tmp._diffs[confirm_id]
                  delete mythis._tmp._send_doc_next_time[db_name][confirm_id] if mythis._tmp?._send_doc_next_time?[db_name]?[confirm_id]
                  mythis.db.remove('_diffs', confirm_id).done (err)->
                    __log.debug 'syncApply', '_sha1 совпали. Удалил дифы в базе ', { err }
                    dfd.resolve();
                else
                  #sha1 в базе не совпадает с присланным с сервера
                  __log.debug 'syncApply', '!= _sha1 sha1 в базе не совпадает с присланным с сервера ' + sha1 + ' != (сервер)' + confirm_element._sha1, { doc, confirm_element }
                  old_doc = mythis.before_sync[doc._id];
                  if old_doc
                    __log.debug 'syncApply', '!= Нашел элемент в бекапе _sha1 = ' + old_doc?._sha1, { old_doc }
                  #Если нам прислали документ целиком - значит это был merge
                  __log.debug 'EMPTY DOC RECIEVED!!! STRANGE';
                  if (confirm_element._doc)
                    doc = confirm_element._doc
                    __log.debug 'syncApply', '!= С сервера прислали документ целиком, беру его. _sha1 = ' + doc._sha1, { doc }
                    #Если его нет в бекапе, то просто сохраняю и стираю все изменения
                    if !old_doc or confirm_element.merged
                      __log.debug 'Прислали документ с мерджем!', confirm_element
                      machine_id = settingsApi.set.machine
                      alert('merged') if confirm_element.merged and machine_id == '7829517'
                      delete mythis._tmp._diffs[confirm_id] if mythis._tmp._diffs[confirm_id]
                      delete mythis._tmp._send_doc_next_time[db_name][confirm_id] if mythis._tmp?._send_doc_next_time?[db_name]?[confirm_id]
                      mythis.db.remove('_diffs', confirm_id).done (err)->
                        __log.debug 'syncApply', '_sha1 не совпали. Удалил дифы в базе, так как мне прислали новый элемент ', { err }
                      mythis.copyObject(mythis._db[db_name][confirm_id], doc);
                      __log.debug 'syncApply', '!= Есть данные в бекапе, сохраняю в память _sha1 = ' + doc._sha1, { doc }
                      mythis.db.put(db_name, doc).done (err)->
                        __log.debug 'syncApply', '!= Есть данные в бекапе, сохранил в базу _sha1 = ' + doc._sha1, { doc }
                        $timeout ()->
                          $rootScope.$emit 'refresh_editor'
                          __log.warn 'syncApply', '!= Попросил редактор обновиться ', { doc }
                        , 100
                  else
                    __log.warn 'Документ целиком не прислали, просто подтвердили старое изменение, нужно удалить дифы до нового изменения'
                  #Если данные в кеше и изменились
                  if old_doc and !confirm_element.merged and doc
                    __log.warn 'syncApply', 'Данные есть в кеше, но sha1 другой!!!!!!!!!!!!!!!!', { old_doc, doc }
                    #old_doc._sha1 = mythis.JSON_stringify(old_doc)._sha1
                    #doc._sha1 = old_doc._sha1
                    patch = mythis.diff.diff(JSON.parse(JSON.stringify(old_doc)), doc); #вычисляю патч
                    __log.warn 'BUG: ', { old_doc, doc, patch }
                    delete patch._sha1 if patch and patch._sha1
                    delete patch._tm if patch and patch._tm
                    __log.warn 'PATCH = ', patch

                    if patch
                      el = {
                        _id: confirm_id
                        patch: patch
                        db_name: db_name
                        _sha1: old_doc._sha1
                        user_id: settingsApi.set.user_id
                        machine: settingsApi.set.machine
                        _tm: new Date().getTime()
                      }
                      __log.warn '!!!!!!!!!!!SHA1!!!!!!', doc._sha1, doc
                      #если синхронизация уже идёт, то изменения пока не сохраняем
                      mythis.saving_diff_busy = true
                      mythis._tmp._diffs[el._id] = el

                    mythis._db[db_name][confirm_id] = doc;
                    mythis.db.put(db_name, old_doc).done (err)->
                      __log.warn 'old_saved _Sha1 = ', old_doc._sha1
                      mythis.db.put('_diffs', el).done ()->
                        $timeout ()->
                          $rootScope.$emit 'refresh_editor'
                          __log.warn 'syncApply', '!= Попросил редактор обновиться SHA1 ERROR', { doc }
                        , 100
                        mythis.saving_diff_busy = false
              else
                #добавление нового элемента в базу
                if confirm_element._doc
                  mythis.clearCache();
                  mythis._db[db_name][confirm_element._doc._id] = confirm_element._doc
                  mythis.db.put(db_name, confirm_element._doc).done (err)->
                    __log.info 'saved_to_db ', err


      dfd.resolve();
      dfd.promise



    #Определяет последнее время синхронизации и новые элементы
    getLastSyncTime: ()->
      dfd = $q.defer();
      max_time = new Date(2013, 3, 1);
      max_element = new Date(2013, 3, 1);
      mythis = @;
      new_db_elements = {};
      async.each mythis.store_schema, (table_schema, callback)->
        db_name = table_schema.name;
        if db_name[0] != '_'
          __log.info { db_name }
          max_element = _.max mythis._db[db_name], (el)->
            if el._new
              new_db_elements[db_name] = {} if !new_db_elements[db_name]
              new_db_elements[db_name][el._id] = el
            if el._tm
              return new Date(el._tm)
            else
              return 0
          max_time = new Date(max_element._tm) if new Date(max_element._tm) > max_time
          callback()
        else
          callback()
      , ()->
        dfd.resolve { last_sync_time: max_time, new_db_elements }
      dfd.promise;
    jsSyncJournalCount: ()->
      if @_tmp._diffs
        return Object.keys(@_tmp._diffs).length
      else
        return 0
    sync_now: false
    sync_later: undefined
    last_sync_time: 'не проводилась'
    syncDiff: ()->
      dfd = $q.defer();
      mythis = @;
      if !mythis.sync_now
        $('.sync_indicator').addClass('active');
        setTimeout ()->
          $('.sync_indicator').removeClass('active');
          mythis.sync_now = false
        , 950
        mythis.sync_now = true
        console.time 'sync_long' if __log.show_time_long
        sync_id = Math.round(Math.random()*100);
        __log.info '('+sync_id+') New syncing...';

        @getDiffsForSync().then (diffs)->
          if $socket.is_online() and false
            mythis.syncThrough('websocket', data).then ()->
              __log.info 'sync_socket_ended';
              mythis.sync_now = false
              dfd.resolve();
          else
            mythis.sendDiffToWeb(diffs).then (results)->
              mythis.syncApplyResults(results).then ()->
                mythis.refreshParentsIndex();
                mythis.sync_now = false
                dfd.resolve();
                __log.info 'sha1 applyed';
                __log.info '('+sync_id+') STOP syncing...';
                console.time 'sync_long' if __log.show_time_long
                $('.sync').removeClass('need_sync');
                now = new moment()
                mythis.last_sync_time = now.format("HH:mm:ss")

      else
        clearTimeout mythis.sync_later
        mythis.sync_later = setTimeout ()->
          mythis.syncDiff();
          __log.warn 'SyncAgain...'
        , 500
        __log.warn 'cant sync now, already syncing...................'
      dfd.promise

    sendDiffToWeb: (diffs)->
      __log.info 'Sending: ', JSON.stringify(diffs)?.length
      dfd = $q.defer();
      mythis = @;
      mythis.getLastSyncTime().then (last_sync_time_and_new)->
        last_sync_time = last_sync_time_and_new.last_sync_time;
        new_db_elements = last_sync_time_and_new.new_db_elements;
        sha1_sign = settingsApi.set.machine + mythis.JSON_stringify({diffs, new_db_elements})._sha1;
        oAuth2Api.jsGetToken().then (token)->
          $http({
            url: settingsApi.set.server + '/api/v2/sync',
            method: "POST",
            isArray: true,
            params:
              access_token: token
              machine: settingsApi.set.machine
              last_sync_time: last_sync_time
            data:
              diffs: diffs
              new_db_elements: new_db_elements
              sha1_sign: sha1_sign
              user_id: settingsApi.set.user_id
          }).error (data, err)->
            #if not auth
            if (err == 401)
              window.location.hash = '#/login';
            console.info 'error', data, err;
          .then (result)->
            dfd.resolve result.data

        dfd.promise
    before_sync: {}
    getDiffsForSync: ()->
      dfd = $q.defer()
      mythis = @
      diffs = mythis._tmp._diffs
      machine_id = settingsApi.set.machine
      if machine_id == '7829517' and diffs and Object.keys(diffs).length
        alert('stop!');
      mythis.before_sync = {}
      if !!diffs
        async.each Object.keys(diffs), (dif_id, callback)->
          dif = diffs[dif_id]
          __log.info 'dif = ', dif
          mythis.getElement(dif.db_name, dif._id).then (now_element)->
            if now_element
              mythis.before_sync[dif._id] = JSON.parse(JSON.stringify(now_element))
              mythis.before_sync[dif._id]._sha1 = mythis.JSON_stringify( mythis.before_sync[dif._id] )._sha1
              __log.warn 'backup = ', mythis.before_sync[dif._id]
            #если сервер просил отправить элемент целиком
            if mythis._tmp._send_doc_next_time?[dif.db_name]?[dif._id]
              mythis.getElementFromLocal(dif.db_name, dif._id).then (old_element)->
                if old_element._sha1 == mythis._tmp._send_doc_next_time?[dif.db_name]?[dif._id]
                  dif._doc = old_element;
                  callback();
                else
                  console.error 'strange, sha1 of local not equal'
                  callback();
            else
              callback();
        , ()->
          dfd.resolve(diffs);
      else
        dfd.resolve();
      dfd.promise

    TestJson: ()->
      mythis = @;
      $timeout ()->
        __log.info 'start test JSON'
        console.time 'JSON_test' if __log.show_time_long
        _.each ['tree', 'tasks', 'texts'], (db_name)->
          i = 0;
          _.each mythis._db[db_name], (element)->
            answer = mythis.JSON_stringify element
            if answer._sha1 != element._sha1
              __log.info 'SHA1 error [' + i + ']', element, answer
              i++;
          __log.info 'Congratulations.. ' + db_name + ' is equal...' if i == 0
        console.timeEnd 'JSON_test' if __log.show_time_long
      , 3000
    JSON_stringify: (json)->
      isObject = (a) ->
        Object::toString.call(a) is "[object Object]"

      isArray = (a) ->
        Object::toString.call(a) is "[object Array]"

      copyObjectWithSortedKeys = (object) ->
        if isObject(object)
          newObj = {}
          keysSorted = Object.keys(object).sort()
          key = undefined
          for i of keysSorted
            key = keysSorted[i]
            if _.has(object, key)
              newObj[key] = copyObjectWithSortedKeys(object[key])
          newObj
        else if isArray(object)
          object.map copyObjectWithSortedKeys
        else
          object
      delete_ = (key, value)->
        if (first_letter = key[0]) == '_' or first_letter == '$'
          return undefined
        else
          return value

      json2 = copyObjectWithSortedKeys(JSON.parse(JSON.stringify(json, delete_)))

      string = JSON.stringify json2, delete_, 0
      _id = json?._id;
      _sha1 = CryptoJS.SHA1(JSON.stringify(string)).toString().substr(0, 7)
      {_id, _sha1, string}




]

























