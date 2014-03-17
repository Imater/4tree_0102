// Generated by CoffeeScript 1.6.3
(function() {
  angular.module("4treeApp").service('db_tasks', [
    '$translate', '$http', '$q', function($translate, $http, $q) {
      return {
        constructor: function($timeout) {
          this.$timeout = $timeout;
          return this.db_tasks = [
            {
              id: 0,
              tree_id: 1034,
              date1: new Date(2014, 4, 11),
              date2: new Date(2014, 4, 11),
              title: 'Записаться в бассейн, это очень важно и нужно это сделать очень срочно, потомучто плавать это круто и всем нравится и это очень даже прикольно'
            }, {
              id: 1,
              tree_id: 1034,
              date1: new Date(2014, 2, 3),
              date2: new Date(2014, 2, 3),
              title: 'Начало сериала на ТНТ про дружбу народов',
              did: new Date()
            }, {
              id: 2,
              tree_id: 1034,
              date1: new Date(2013, 2, 3),
              date2: new Date(2014, 2, 3),
              title: 'Как жизнь? написать письмо',
              did: new Date()
            }, {
              id: 3,
              tree_id: 1034,
              date1: new Date(2014, 2, 2),
              date2: new Date(2014, 2, 2),
              title: 'Урал край голубых озёр - написать статью'
            }, {
              id: 4,
              tree_id: 1034,
              date1: new Date(new Date().getTime() - 1000 * 60 * 220),
              date2: new Date(2014, 2, 3),
              title: 'Двадцать минут назад я тут был :)'
            }, {
              id: 5,
              tree_id: 1034,
              date1: '',
              date2: new Date(2014, 2, 3),
              title: 'Как жизнь? написать письмо'
            }, {
              id: 8,
              tree_id: 1034,
              date1: '',
              date2: new Date(2014, 2, 3),
              title: 'Нужно купить Мартини'
            }, {
              id: 6,
              tree_id: 1034,
              date1: new Date(new Date().getTime() + 1000 * 60 * 20),
              date2: new Date(new Date().getTime() + 1000 * 60 * 20),
              title: 'Через 20 минут выходим'
            }, {
              id: -1,
              tree_id: 2138,
              date1: new Date(2014, 2, 1),
              date2: new Date(2014, 2, 1),
              title: 'Очень важное дело, которое нужно сделать сегодня'
            }
          ];
        },
        clearCache: function() {
          return _.each(this, function(fn) {
            if (fn) {
              return fn.cache = {};
            }
          });
        },
        getTasks: function() {
          return this.db_tasks;
        },
        getTasksByTreeId: _.memoize(function(tree_id, only_next) {
          var answer, answer1;
          answer = _.filter(this.db_tasks, function(el) {
            return el.tree_id === tree_id;
          });
          answer = _.sortBy(answer, function(el) {
            return el.date1;
          });
          if (only_next === true) {
            answer1 = _.find(answer, function(el) {
              return el.date1 && !el.did;
            });
            if (!answer1) {
              answer1 = _.find(answer, function(el) {
                return !el.did;
              });
            }
            if (answer1) {
              answer = [answer1];
            } else {
              answer = void 0;
            }
          } else {
            answer = _.sortBy(answer, function(el) {
              var res;
              if (el.date1) {
                res = -el.date1.getTime();
                res = res + 100000000000000;
              } else {
                res = new Date().getTime();
                res = res + 200000000000000;
              }
              if (el.did) {
                res = res + 500000000000000;
              }
              return res;
            });
          }
          if (answer) {
            return answer;
          } else {
            return [];
          }
        }, function(tree_id, only_next) {
          return tree_id + only_next;
        })
      };
    }
  ]);

}).call(this);
