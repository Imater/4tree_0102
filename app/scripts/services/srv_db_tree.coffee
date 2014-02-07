angular.module("4treeApp").service 'db_tree', ['$translate', ($translate) ->
	constructor: (@$timeout) -> 
		if(!@db_tree)
			@db_tree = [
				{id:-1, parent: 0, title: "Новое"}
				{id:1, parent: 0, title: "Рабочие дела"}
				{id:2, parent: 0, title: "Домашние дела"}
				{id:3, parent: 0, title: "Дневник"}
				{id:4, parent: 0, title: "Архив"}
				{id:5, parent: 3, title: "2013"}
				{id:6, parent: 3, title: "2014"}
				{id:7, parent: 6, title: "1 квартал"}				
				{id:8, parent: 7, title: "7 февраля 2014"}				
			]
			console.info 'tree constructored...';
	getTree: (args) ->
		@db_tree
	jsFindByParent: (args) ->
		_.filter @db_tree, (el)->
			el.parent == args
]