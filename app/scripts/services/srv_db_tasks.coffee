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
      did: new Date();
      }

      { 
      id: 2, 
      tree_id: 1034, 
      date1: new Date(2013,2,3), 
      date2: new Date(2014,2,3), 
      title: 'Как жизнь? написать письмо' 
      did: new Date();
      }

      { 
      id: 3, 
      tree_id: 1034, 
      date1: new Date(2014,2,2), 
      date2: new Date(2014,2,2), 
      title: 'Урал край голубых озёр - написать статью' 
      #did: new Date();
      }

      { 
      id: 4, 
      tree_id: 1034, 
      date1: new Date( new Date().getTime()-1000*60*220 ), 
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
      id: 8, 
      tree_id: 1034, 
      date1: '', 
      date2: new Date(2014,2,3), 
      title: 'Нужно купить Мартини' 
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
  getTasksByTreeId: _.memoize (tree_id, only_next)->
    answer = _.filter @db_tasks, (el)->
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
]
















