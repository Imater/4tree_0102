angular.module("4treeApp").service 'db_tree', ['$translate', ($translate) ->
	constructor: (@$timeout) -> 
		mythis = @;
		if(!@db_tree)
			@db_parents = []
			@db_tree = [
				{'n0': {id:0, parent: -1, title: "4tree", icon: 'icon-record', _open: false, _childs: 5} }
				{'n-2': {id:-2, parent: 0, title: "Новое", icon: 'icon-download', _open: false, _childs: 5} }
				{'n1': {id:1, parent: 0, title: "Рабочие дела", icon: 'icon-wrench-1', _open: true, _childs: 1, share: [
					{link: 'sex1' }
					{link: 'sex2' }
					{link: 'sex3' }
					{link: 'sex4' }
				]} }
				{'n9': {id:9, parent: 1, title: "Сделать очень срочно", icon: 'icon-flash', _open: true, _childs: 1} }
				{'n10': {id:10, parent: 9, title: "Позвонить Боссу", icon: 'icon-phone', _open: true, _childs: 4, _settings: false} }
				{'n11': {id:11, parent: 10, title: "Спросить про финансирование", icon: 'icon-phone', _open: false, _childs: 0, _settings: false} }
				{'n12': {id:12, parent: 10, title: "Узнать вводные данные", icon: 'icon-phone', _open: false, _childs: 0, _settings: false} }
				{'n13': {id:13, parent: 10, title: "Записать пожелания", icon: 'icon-phone', _open: false, _childs: 0, _settings: false} }
				{'n14': {id:14, parent: 10, title: "Подчеркнуть самое важное", icon: 'icon-phone', _open: false, _childs: 0, _settings: false} }
				{'n2': {id:2, parent: 0, title: "Домашние дела", icon: 'icon-home-2', _open: false, _childs: 0} }
				{'n3': {id:3, parent: 0, title: "Дневник", icon: 'icon-calendar', _open: true, _childs: 2} }
				{'n4': {id:4, parent: 0, title: "Архив", icon: 'icon-archive', _open: false, _childs: 0} }
				{'n5': {id:5, parent: 3, title: "2013", icon: 'icon-calendar', _open: false, _childs: 4} }
				{'n6': {id:6, parent: 3, title: "2014", icon: 'icon-calendar', _open: true, _childs: 1} }
				{'n7': {id:7, parent: 6, title: "1 квартал", icon: 'icon-calendar', _open: true, _childs: 1} }				
				{'n8': {id:8, parent: 7, title: "7 февраля 2014", icon: 'icon-calendar', _open: false, _childs: 0} }				 
			]
			_.each @db_tree, (el)->
				id = Object.keys(el)[0]
				parent = 'n' + el[id].parent
				mythis.db_parents[parent] = [] if !mythis.db_parents[parent];
				mythis.db_parents[parent].push( el[id] );
	getTree: (args) ->
		@db_tree
	jsFindByParent: (args) ->
		@db_parents['n'+args]
	jsFind: (id) ->
	    tree_by_id = _.find @db_tree, (el)->
	    	el['n'+id]
	    tree_by_id['n'+id] if tree_by_id
	jsGetPath: (id) ->
		path = [];
		prevent_recursive = 5000;
		while (el = @jsFind(id)) and (prevent_recursive--)
			id = el.parent
			path.push(el);
		path.reverse();

]