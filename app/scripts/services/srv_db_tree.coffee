angular.module("4treeApp").factory 'datasource', ['$timeout', ($timeout)->
  get: (index, count, success)->
    console.info "COUNT = ", count
    result = []
    for i in [index..index + count-1]
      result.push "item ##{i}"
    success(result)
]

angular.module("4treeApp").service 'db_tree', ['$translate', '$http', '$q', '$rootScope', 'oAuth2Api', ($translate, $http, $q, $rootScope, oAuth2Api) ->
  _db: {}
  _cache: {}
  salt: ()->
    'Salt is a mineral substance composed'
  pepper: ()->
    ' primarily of sodium chloride (NaCl)'
  constructor: (@$timeout) -> 
    @loadTasks();
    if(!@_cache)
      @_cache = {}
    if(!@_db.tree)
      @_db.tree = [
        {id:0, parent: -1, title: {v: "4tree", _t: new Date()}, icon: 'icon-record', _open: false, _childs: 5}
      ]
      @refreshParentsIndex();
  clearCache: ()->
    _.each @, (fn)->
      fn.cache = {} if fn
  getTreeFromNet: ()->
    dfd = $q.defer();
    mythis = @;

    oAuth2Api.jsGetToken().then (access_token)->
      $http({
        url: '/api/v2/tree',
        method: "GET",
        params: {
          user_id: '5330ff92898a2b63c2f7095f'
          access_token: access_token
        }
      }).then (result)->
        mythis._db.tree = result.data;
        mythis.refreshParentsIndex();
        $rootScope.$$childTail.db.main_node = _.find mythis._db.tree, (el)->
          el._id == 1034
        $rootScope.$broadcast('tree_loaded');
        dfd.resolve(result.data);
  refreshParentsIndex: (parent_id)->
    mythis = @;
    if !parent_id
      mythis.db_parents = {}
    else
      mythis.db_parents['n'+parent_id] = []

    found = _.find @_db.tree, (el)->
      el.folder == 'main'
    if found
      $rootScope.$$childTail.set.main_parent_id = found._id if $rootScope.$$childTail.set.main_parent_id == 'no parent'
      $rootScope.$$childTail.set.top_parent_id = found._id


    _.each @_db.tree, (el)->
      if parent_id and el.parent_id != parent_id
        return true
      cnt = [
        {title:'шагов', cnt_today: 20, days: [ 
          {d: '2013-03-01', cnt: 12}
          {d: '2013-03-02', cnt: 10}
          {d: '2013-03-03', cnt: 8}
          {d: '2013-03-05', cnt: 15}
          {d: '2013-03-12', cnt: 21}
        ]}
        {title:'прошёл км.', cnt_today: 30,  days: [ 
          {d: '2013-03-01', cnt: 12}
          {d: '2013-03-02', cnt: 10}
          {d: '2013-03-03', cnt: 8}
          {d: '2013-03-05', cnt: 15}
          {d: '2013-03-12', cnt: 21}
        ]}
        {title:'отжиманий', cnt_today: 19, days: [ 
          {d: '2013-03-01', cnt: 12}
          {d: '2013-03-02', cnt: 10}
          {d: '2013-03-03', cnt: 8}
          {d: '2013-03-05', cnt: 15}
          {d: '2013-03-12', cnt: 21}
        ]}
      ]
      el._path = mythis.jsGetPath(el._id) if el._id
      el.importance = if el.importance then el.importance else 50;
      el.tags = if el.tags then el.tags else [];
      el.counters = cnt;
      #el._open = false if el.parent_id != '1';
      el.dates = {
        startDate: if el.dates then moment(el.dates.startDate) else ""
        endDate: if el.dates then moment(el.dates.endDate) else ""
      }
      parent = 'n' + el.parent_id

      mythis.db_parents[parent] = [] if !mythis.db_parents[parent];
      mythis.db_parents[parent].push( el ); 
      return true

    _.each mythis.db_parents, (el, key)->
      if parent_id and el._id != parent_id
        return true
      found = _.find mythis._db.tree, (e)->
        key == 'n' + e._id
      found._childs = el.length if found
      true
    true
        

    mymap = (doc, emit)->
      emit(doc.date, doc.title, doc) if doc.text and doc.text.indexOf('жопа')!=-1;

    @newView('tree', 'by_date', mymap);

    mymap_calendar = (doc, emit)->
      emit(doc.date2, doc, doc) if doc.date2;

    myreduce_calendar = (memo, values)->
      key = values.key; 
      key = moment(values.key);
      key = key.format("YYYY-MM-DD")
      memo[key] = [] if !memo[key]
      memo[key].push(values.value) if values.value

    @newView('tasks', 'tasks_by_date', mymap_calendar, myreduce_calendar)

  getTree: (args) ->
    @_db.tree
  jsFindByParent: (args) ->
    elements = _.sortBy @db_parents['n'+args], (value, key)->
      value.pos
    elements = _.filter elements, (value)->
      value.del!=1

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
  'first_element': {
    title: '4tree'
    parent_id: '0'
    _path: ['1']
  }
  'jsFind': _.memoize (id)->
    return @first_element if id == 1
    tree_by_id = _.find @_db.tree, (el)->
      el._id == id
    console.info "!!!", (tree_by_id) if id == '1'
    tree_by_id if tree_by_id
  'jsGetPath': _.memoize (id) ->
    path = [];
    prevent_recursive = 5000;
    while (el = @jsFind(id)) and (prevent_recursive--)
      id = el.parent_id
      path.push(el._id) if el.parent_id;
    path.push( $rootScope.$$childTail.set.main_parent_id );
    path.reverse();
  jsView: ()->
    @_cache


  newView: (db_name, view_name, mymap, myreduce )->
    mythis = @;
    mythis._cache[db_name] = {}
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
    if( view.rows.length && view.invalid.length == 0 )
      return view;
    else if (view.invalid.length > 0 and view.rows.length>0) 
      @generateView(db_name, view_name, view.invalid);
      return view;
    else
      @generateView(db_name, view_name);
      return view;


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
      view.rows.push( {id:doc._id, key, value} )
      view['reduce'](memo, {key, value}) if !view_invalid and view['reduce']

    _.each myrows, (doc, key)->
      result = view['map'](doc, emit);

    if view_invalid and view['reduce']
      _.each view.rows, (doc)->
        view['reduce'](memo, {key:doc.key, value:doc.value})

    view.rows = _.sortBy view.rows, (el)->
      el.key

    view.invalid = [];

    view.result = memo;

  refreshView: (db_name, ids, new_value, old_value)->
    mythis = @;
    _.each ids, (id)->
      _.each mythis._cache[db_name].views, (view)->
        view.invalid.push( id )
########################## T A S K S ########################
  loadTasks: ()->
    @_db.tasks = [
      { 
      id: 0, 
      tree_id: '1034', 
      date1: new Date(2014,2,31), 
      date2: new Date(2014,2,31, 8, 30), 
      title: 'Записаться в бассейн, это очень важно и нужно это сделать очень срочно, потомучто плавать это круто и всем нравится и это очень даже прикольно' 
      }

      { 
      id: 1, 
      tree_id: '1034', 
      date1: new Date(2014,3,4, 12, 30, 0), 
      date2: new Date(2014,3,4, 10, 30, 0), 
      title: 'Начало сериала на ТНТ про дружбу народов' 
      did: new Date();
      }

      { 
      id: 2, 
      tree_id: '1034', 
      date1: new Date(2013,2,3), 
      date2: new Date(2014,3,4, 17, 30, 0), 
      title: 'Как жизнь? написать письмо' 
      did: new Date();
      }

      { 
      id: 3, 
      tree_id: '1034', 
      date1: new Date(2014,1,4, 12, 30, 0), 
      date2: new Date(2014,3,2, 18, 30, 0), 
      title: 'Урал край голубых озёр - написать статью' 
      #did: new Date();
      }

      { 
      id: 4, 
      tree_id: '1034', 
      date1: new Date( new Date().getTime()-1000*60*220 ), 
      date2: new Date( new Date().getTime()-1000*60*220 ), 
      title: 'Двадцать минут назад я тут был :) И мне тут понравилось.' 
      }

      { 
      id: 5, 
      tree_id: '1034', 
      date1: '', 
      date2: new Date(2014,3,8, 12, 30, 0), 
      title: 'Как жизнь? написать письмо' 
      }
      { 
      id: 8, 
      tree_id: '1034', 
      date1: '', 
      date2: new Date(2014,3,8, 12, 30, 0), 
      title: 'Нужно купить Мартини' 
      }

      { 
      id: 6, 
      tree_id: '1034', 
      date1: new Date( new Date().getTime()+1000*60*20 ), 
      date2: new Date( new Date().getTime()+1000*60*20 ), 
      title: 'Через 20 минут выходим и нам нужно ехать будет в театр' 
      }

      { 
      id: -1, 
      tree_id: '2138', 
      date1: new Date(2014,2,29), 
      date2: new Date(2014,2,29, 14,20), 
      title: 'Очень важное дело, которое нужно сделать сегодня' 
      }
    ]
  clearCache: ()->
    _.each @, (fn)->
      fn.cache = {} if fn
  getTasks: ()->
    @_db.tasks;
  getTasksByTreeId: _.memoize (tree_id, only_next)->
    answer = _.filter @_db.tasks, (el)->
      console.info '? = ', el.tree_id
      el.tree_id == tree_id 
    answer = _.sortBy answer, (el)-> el.date1

    if only_next == true 
      answer1 = _.find answer, (el)-> el.date1 && !el.did;
      if !answer1
        answer1 = _.find answer, (el)-> !el.did
      if answer1
        answer = [ answer1 ];
      else
        answer = undefined;
    else
      answer = _.sortBy answer, (el)-> 
        if el.date1
          res = -el.date1.getTime();
          res = res + 100000000000000 
        else
          res = new Date().getTime();
          res = res + 200000000000000 

        if el.did
          res = res + 500000000000000 

        res

    if answer then answer else []
  , (tree_id, only_next)->
    tree_id+only_next

  jsExpand: (id, make_open)->
    _.each @_db.tree, (el)->
      if el._path and el._path.indexOf(id) != -1
        if !(make_open == true and el._childs>50)
          el._open = make_open if el._childs>0
        else 
          el._open = undefined
      return
  tree_template: ()->
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
    parents = @.db_parents['n'+tree.parent_id];
    parents = _.sortBy parents, (value)->
      value.pos
    found = _.find parents, (value)->
      value.pos>tree.pos
    if found and found.pos
      console.info "POS = ", found.pos, tree.pos
      return (parseInt(1000000000000*(found.pos - tree.pos)/1.1))/1000000000000
    else
      return 1
  addNote: (tree, new_note_title, make_child)->
    console.info 'new_note', tree, new_note_title
    new_note = new @tree_template;
    new_note.title = new_note_title;
    new_note._id = new ObjectId().toString();
    new_note.pos = tree.pos + @diffForSort(tree);
    new_note._add_show = true
    tree._add_show = false
    @_db.tree.push(new_note)
    if !make_child 
      new_note.parent_id = tree.parent_id;
      @refreshParentsIndex(tree.parent_id);
    else
      new_note.parent_id = tree._id;
      @refreshParentsIndex();
      tree._open = true;
    $rootScope.$$childTail.db.main_node=new_note



]

























