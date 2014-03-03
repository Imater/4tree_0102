angular.module("4treeApp").service 'db_tasks', ['$translate', '$http', '$q', ($translate, $http, $q) ->
	constructor: (@$timeout) -> 
		@db_tasks = [
			{ 
			id: 0, 
			tree_id: 1034, 
			date1: new Date(2014,4,11), 
			date2: new Date(2014,4,11), 
			title: 'Записаться в бассейн, это очень важно и нужно это сделать очень срочно, потомучто плавать это круто и всем нравится и это очень даже прикольно' 
			}

			{ 
			id: 1, 
			tree_id: 1034, 
			date1: new Date(2014,2,3), 
			date2: new Date(2014,2,3), 
			title: 'Начало сериала на ТНТ про дружбу народов' 
			}

			{ 
			id: 2, 
			tree_id: 1034, 
			date1: new Date(2013,2,3), 
			date2: new Date(2014,2,3), 
			title: 'Как жизнь? написать письмо' 
			}

			{ 
			id: 3, 
			tree_id: 1034, 
			date1: new Date(2014,2,2), 
			date2: new Date(2014,2,2), 
			title: 'Урал край голубых озёр - написать статью' 
			}

			{ 
			id: 4, 
			tree_id: 1034, 
			date1: new Date( new Date().getTime()-1000*60*20 ), 
			date2: new Date(2014,2,3), 
			title: 'Двадцать минут назад я тут был :)' 
			}

			{ 
			id: 5, 
			tree_id: 1034, 
			date1: '', 
			date2: new Date(2014,2,3), 
			title: 'Как жизнь? написать письмо' 
			}

			{ 
			id: 6, 
			tree_id: 1034, 
			date1: new Date( new Date().getTime()+1000*60*20 ), 
			date2: new Date( new Date().getTime()+1000*60*20 ), 
			title: 'Через 20 минут выходим' 
			}

			{ 
			id: -1, 
			tree_id: 2138, 
			date1: new Date(2014,2,1), 
			date2: new Date(2014,2,1), 
			title: 'Очень важное дело, которое нужно сделать сегодня' 
			}
		]
	clearCache: ()->
		_.each @, (fn)->
			fn.cache = {} if fn
	getTasks: ()->
		@db_tasks;
	getTasksByTreeId: _.memoize (tree_id)->
		answer = _.filter @db_tasks, (el)->
			el.tree_id == tree_id 
		answer = _.sortBy answer, (el)->
			-el.date1
]