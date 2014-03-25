angular.module("4treeApp").service 'db_tree', ['$translate', '$http', '$q', '$rootScope', 'oAuth2Api', ($translate, $http, $q, $rootScope, oAuth2Api) ->
  _db: {}
  _cache: {}
  salt: ()->
    'Salt is a mineral substance composed'
  pepper: ()->
    ' primarily of sodium chloride (NaCl)'
  constructor: (@$timeout) -> 
    if(!@_cache)
      @_cache = {}
    if(!@_db.tree)
      @_db.tree = [
        {id:0, parent: -1, title: {v: "4tree", _t: new Date()}, icon: 'icon-record', _open: false, _childs: 5}
        {id:-2, parent: 0, title: {v: "Новое", _t: new Date()}, icon: 'icon-download', _open: false, _childs: 5}
        {id:1, parent: 0, title: "Рабочие дела", icon: 'icon-wrench-1', _open: true, _childs: 1, share: [
          {link: {v:'sex1', _t: new Date() }}
          {link: {v:'sex2'}}
          {link: {v:'sex3'}}
          {link: {v:'sex4'}}
        ]}
        {id:9, parent: 1, title: {v: "Сделать очень срочно", _t: new Date()}, icon: 'icon-flash', _open: true, _childs: 1}
        {id:10, parent: 9, title: {v: "Позвонить Боссу", _t: new Date()}, icon: 'icon-phone', _open: true, _childs: 4, _settings: false}
        {id:11, parent: 10, title: {v: "Спросить про финансирование", _t: new Date()}, icon: 'icon-phone', _open: false, _childs: 0, _settings: false}
        {id:12, parent: 10, title: {v: "Узнать вводные данные", _t: new Date()}, icon: 'icon-phone', _open: false, _childs: 0, _settings: false}
        {id:13, parent: 10, title: {v: "Записать пожелания", _t: new Date()}, icon: 'icon-phone', _open: false, _childs: 0, _settings: false}
        {id:14, parent: 10, title: {v: "Подчеркнуть самое важное", _t: new Date()}, icon: 'icon-phone', _open: false, _childs: 0, _settings: false}
        {id:2, parent: 0, title: {v: "Домашние дела", _t: new Date()}, icon: 'icon-home-2', _open: false, _childs: 0}
        {id:3, parent: 0, title: {v: "Дневник", _t: new Date()}, icon: 'icon-calendar', _open: true, _childs: 2}
        {id:4, parent: 0, title: {v: "Архив", _t: new Date()}, icon: 'icon-archive', _open: false, _childs: 0}
        {id:5, parent: 3, title: {v: "2013", _t: new Date()}, icon: 'icon-calendar', _open: false, _childs: 4}
        {id:6, parent: 3, title: {v: "2014", _t: new Date()}, icon: 'icon-calendar', _open: true, _childs: 1}
        {id:7, parent: 6, title: {v: "1 квартал", _t: new Date()}, icon: 'icon-calendar', _open: true, _childs: 1}        
        {id:8, parent: 7, title: {v: "7 февраля 2014", _t: new Date() }, icon: 'icon-calendar', _open: false, _childs: 0}        
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
          user_id: 12
          access_token: access_token
        }
      }).then (result)->
        mythis._db.tree = result.data;
        mythis.refreshParentsIndex();
        $rootScope.$$childTail.db.main_node = _.find mythis._db.tree, (el)->
          el.id == 1034
        dfd.resolve(result.data);
  refreshParentsIndex: ()->
    mythis = @;
    mythis.db_parents = {};
    _.each @_db.tree, (el)->
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
      el.importance = if el.importance then el.importance else 50;
      el.tags = if el.tags then el.tags else [];
      el.counters = cnt;
      el._open = false;
      el.dates = {
        startDate: moment()
        endDate: moment()
      }

      parent = 'n' + el.parent
      mythis.db_parents[parent] = [] if !mythis.db_parents[parent];
      mythis.db_parents[parent].push( el ); 
    _.each @db_parents, (el, key)->
      found = _.find mythis._db.tree, (e)->
        key == 'n'+e.id
      found._childs = el.length if found
      found._open = false if found and found._childs > 30

    mymap = (doc, emit)->
      emit(doc.date, doc.title, doc) if doc.text and doc.text.indexOf('жопа')!=-1;

    @newView('tree', 'by_date', mymap);

  getTree: (args) ->
    @_db.tree
  jsFindByParent: (args) ->
    @db_parents['n'+args]
  web_tags: [
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
      el.parent == args
  jsFindByParentTags: (args) ->
    _.filter @tree_tags, (el)->
      el.parent == args
  'jsFind': _.memoize (id)->
    tree_by_id = _.find @_db.tree, (el)->
      el.id == id
    tree_by_id if tree_by_id
  'jsGetPath': _.memoize (id) ->
    path = [];
    prevent_recursive = 5000;
    while (el = @jsFind(id)) and (prevent_recursive--)
      id = el.parent
      path.push(el) if el?.parent >= 0;
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
        view_invalid.indexOf(el.id) != -1
      ]
      view.rows = _.filter view.rows, (el)->
        view_invalid.indexOf(el.id) == -1
    else 
      myrows = @_db[db_name]

    memo = {};

    emit = (key, value, doc)->
      view.rows = [] if !view.rows
      view.rows.push( {id:doc.id, key, value} )
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


]

























