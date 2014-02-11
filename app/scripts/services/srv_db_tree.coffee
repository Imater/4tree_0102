angular.module("4treeApp").service 'db_tree', ['$translate', ($translate) ->
	constructor: (@$timeout) -> 
		if(!@db_tree)
			@db_tree = [
				{id:0, parent: -1, title: "4tree", icon: 'icon-record', open: false, childs: 5}
				{id:-2, parent: 0, title: "Новое", icon: 'icon-download', open: false, childs: 5}
				{id:1, parent: 0, title: "Рабочие дела", icon: 'icon-wrench-1', open: true, childs: 1, share: [
					{link: 'sex1' }
					{link: 'sex2' }
					{link: 'sex3' }
					{link: 'sex4' }
				]}
				{id:9, parent: 1, title: "Сделать очень срочно", icon: 'icon-flash', open: true, childs: 1}
				{id:10, parent: 9, title: "Позвонить Боссу", icon: 'icon-phone', open: true, childs: 4, settings: false}
				{id:11, parent: 10, title: "Спросить про финансирование", icon: 'icon-phone', open: false, childs: 0, settings: false}
				{id:12, parent: 10, title: "Узнать вводные данные", icon: 'icon-phone', open: false, childs: 0, settings: false}
				{id:13, parent: 10, title: "Записать пожелания", icon: 'icon-phone', open: false, childs: 0, settings: false}
				{id:14, parent: 10, title: "Подчеркнуть самое важное", icon: 'icon-phone', open: false, childs: 0, settings: false}
				{id:2, parent: 0, title: "Домашние дела", icon: 'icon-home-2', open: false, childs: 0}
				{id:3, parent: 0, title: "Дневник", icon: 'icon-calendar', open: true, childs: 2}
				{id:4, parent: 0, title: "Архив", icon: 'icon-archive', open: false, childs: 0}
				{id:5, parent: 3, title: "2013", icon: 'icon-calendar', open: false, childs: 4}
				{id:6, parent: 3, title: "2014", icon: 'icon-calendar', open: true, childs: 1}
				{id:7, parent: 6, title: "1 квартал", icon: 'icon-calendar', open: true, childs: 1}				
				{id:8, parent: 7, title: "7 февраля 2014", icon: 'icon-calendar', open: false, childs: 0}				
			]
			_.each @db_tree, (el)->
				el.note = "Это очень длинный текст заметки "+el.title+Math.random() if parseInt(Math.random()*3) == 1
	getTree: (args) ->
		@db_tree
	jsFindByParent: (args) ->
		_.filter @db_tree, (el)->
			el.parent == args
	jsFind: (id) ->
		_.find @db_tree, (el)->
			el.id == id
	jsGetPath: (id) ->
		path = [];
		prevent_recursive = 5000;
		while (el = @jsFind(id)) and (prevent_recursive--)
			id = el.parent
			path.push(el);
		path.reverse();

]