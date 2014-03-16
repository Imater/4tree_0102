angular.module("4treeApp").service 'db_tree', ['$translate', '$http', '$q', '$rootScope', ($translate, $http, $q, $rootScope) ->
	salt: ()->
		'Salt is a mineral substance composed'
	pepper: ()->
		' primarily of sodium chloride (NaCl)'
	constructor: (@$timeout) -> 
		if(!@db_tree)
			@db_parents = []
			@db_tree = [
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
		$http({
			url: '/api/v2/tree',
			method: "GET",
			params: {
				user_id: 12
			}
		}).then (result)->
			mythis.db_tree = result.data;
			mythis.refreshParentsIndex();
			$rootScope.$$childTail.db.main_node = _.find mythis.db_tree, (el)->
				el.id == 1034
			dfd.resolve(result.data);
	refreshParentsIndex: ()->
		mythis = @;
		mythis.db_parents = {};
		_.each @db_tree, (el)->
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

			parent = 'n' + el.parent
			mythis.db_parents[parent] = [] if !mythis.db_parents[parent];
			mythis.db_parents[parent].push( el );	
		_.each @db_parents, (el, key)->
			found = _.find mythis.db_tree, (e)->
				key == 'n'+e.id
			found._childs = el.length if found
			found.childs = el if found
			found._open = false if found and found._childs > 30
	getTree: (args) ->
		@db_tree
	jsFindByParent: (args) ->
		@db_parents['n'+args]
	jsFind: _.memoize (id)->
		tree_by_id = _.find @db_tree, (el)->
			el.id == id
		tree_by_id if tree_by_id
	jsGetPath: _.memoize (id) ->
		path = [];
		prevent_recursive = 5000;
		while (el = @jsFind(id)) and (prevent_recursive--)
			id = el.parent
			path.push(el);
		path.reverse();
]