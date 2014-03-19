// Generated by CoffeeScript 1.6.3
(function() {
  angular.module("4treeApp").service('db_tree', [
    '$translate', '$http', '$q', '$rootScope', function($translate, $http, $q, $rootScope) {
      return {
        salt: function() {
          return 'Salt is a mineral substance composed';
        },
        pepper: function() {
          return ' primarily of sodium chloride (NaCl)';
        },
        constructor: function($timeout) {
          this.$timeout = $timeout;
          if (!this.db_tree) {
            this.db_parents = [];
            this.db_tree = [
              {
                id: 0,
                parent: -1,
                title: {
                  v: "4tree",
                  _t: new Date()
                },
                icon: 'icon-record',
                _open: false,
                _childs: 5
              }, {
                id: -2,
                parent: 0,
                title: {
                  v: "Новое",
                  _t: new Date()
                },
                icon: 'icon-download',
                _open: false,
                _childs: 5
              }, {
                id: 1,
                parent: 0,
                title: "Рабочие дела",
                icon: 'icon-wrench-1',
                _open: true,
                _childs: 1,
                share: [
                  {
                    link: {
                      v: 'sex1',
                      _t: new Date()
                    }
                  }, {
                    link: {
                      v: 'sex2'
                    }
                  }, {
                    link: {
                      v: 'sex3'
                    }
                  }, {
                    link: {
                      v: 'sex4'
                    }
                  }
                ]
              }, {
                id: 9,
                parent: 1,
                title: {
                  v: "Сделать очень срочно",
                  _t: new Date()
                },
                icon: 'icon-flash',
                _open: true,
                _childs: 1
              }, {
                id: 10,
                parent: 9,
                title: {
                  v: "Позвонить Боссу",
                  _t: new Date()
                },
                icon: 'icon-phone',
                _open: true,
                _childs: 4,
                _settings: false
              }, {
                id: 11,
                parent: 10,
                title: {
                  v: "Спросить про финансирование",
                  _t: new Date()
                },
                icon: 'icon-phone',
                _open: false,
                _childs: 0,
                _settings: false
              }, {
                id: 12,
                parent: 10,
                title: {
                  v: "Узнать вводные данные",
                  _t: new Date()
                },
                icon: 'icon-phone',
                _open: false,
                _childs: 0,
                _settings: false
              }, {
                id: 13,
                parent: 10,
                title: {
                  v: "Записать пожелания",
                  _t: new Date()
                },
                icon: 'icon-phone',
                _open: false,
                _childs: 0,
                _settings: false
              }, {
                id: 14,
                parent: 10,
                title: {
                  v: "Подчеркнуть самое важное",
                  _t: new Date()
                },
                icon: 'icon-phone',
                _open: false,
                _childs: 0,
                _settings: false
              }, {
                id: 2,
                parent: 0,
                title: {
                  v: "Домашние дела",
                  _t: new Date()
                },
                icon: 'icon-home-2',
                _open: false,
                _childs: 0
              }, {
                id: 3,
                parent: 0,
                title: {
                  v: "Дневник",
                  _t: new Date()
                },
                icon: 'icon-calendar',
                _open: true,
                _childs: 2
              }, {
                id: 4,
                parent: 0,
                title: {
                  v: "Архив",
                  _t: new Date()
                },
                icon: 'icon-archive',
                _open: false,
                _childs: 0
              }, {
                id: 5,
                parent: 3,
                title: {
                  v: "2013",
                  _t: new Date()
                },
                icon: 'icon-calendar',
                _open: false,
                _childs: 4
              }, {
                id: 6,
                parent: 3,
                title: {
                  v: "2014",
                  _t: new Date()
                },
                icon: 'icon-calendar',
                _open: true,
                _childs: 1
              }, {
                id: 7,
                parent: 6,
                title: {
                  v: "1 квартал",
                  _t: new Date()
                },
                icon: 'icon-calendar',
                _open: true,
                _childs: 1
              }, {
                id: 8,
                parent: 7,
                title: {
                  v: "7 февраля 2014",
                  _t: new Date()
                },
                icon: 'icon-calendar',
                _open: false,
                _childs: 0
              }
            ];
            return this.refreshParentsIndex();
          }
        },
        clearCache: function() {
          return _.each(this, function(fn) {
            if (fn) {
              return fn.cache = {};
            }
          });
        },
        getTreeFromNet: function() {
          var dfd, mythis;
          dfd = $q.defer();
          mythis = this;
          return $http({
            url: '/api/v2/tree',
            method: "GET",
            params: {
              user_id: 12
            }
          }).then(function(result) {
            mythis.db_tree = result.data;
            mythis.refreshParentsIndex();
            $rootScope.$$childTail.db.main_node = _.find(mythis.db_tree, function(el) {
              return el.id === 1034;
            });
            return dfd.resolve(result.data);
          });
        },
        refreshParentsIndex: function() {
          var mythis;
          mythis = this;
          mythis.db_parents = {};
          _.each(this.db_tree, function(el) {
            var cnt, parent;
            cnt = [
              {
                title: 'шагов',
                cnt_today: 20,
                days: [
                  {
                    d: '2013-03-01',
                    cnt: 12
                  }, {
                    d: '2013-03-02',
                    cnt: 10
                  }, {
                    d: '2013-03-03',
                    cnt: 8
                  }, {
                    d: '2013-03-05',
                    cnt: 15
                  }, {
                    d: '2013-03-12',
                    cnt: 21
                  }
                ]
              }, {
                title: 'прошёл км.',
                cnt_today: 30,
                days: [
                  {
                    d: '2013-03-01',
                    cnt: 12
                  }, {
                    d: '2013-03-02',
                    cnt: 10
                  }, {
                    d: '2013-03-03',
                    cnt: 8
                  }, {
                    d: '2013-03-05',
                    cnt: 15
                  }, {
                    d: '2013-03-12',
                    cnt: 21
                  }
                ]
              }, {
                title: 'отжиманий',
                cnt_today: 19,
                days: [
                  {
                    d: '2013-03-01',
                    cnt: 12
                  }, {
                    d: '2013-03-02',
                    cnt: 10
                  }, {
                    d: '2013-03-03',
                    cnt: 8
                  }, {
                    d: '2013-03-05',
                    cnt: 15
                  }, {
                    d: '2013-03-12',
                    cnt: 21
                  }
                ]
              }
            ];
            el.importance = el.importance ? el.importance : 50;
            el.tags = el.tags ? el.tags : [];
            el.counters = cnt;
            el._open = false;
            parent = 'n' + el.parent;
            if (!mythis.db_parents[parent]) {
              mythis.db_parents[parent] = [];
            }
            return mythis.db_parents[parent].push(el);
          });
          return _.each(this.db_parents, function(el, key) {
            var found;
            found = _.find(mythis.db_tree, function(e) {
              return key === 'n' + e.id;
            });
            if (found) {
              found._childs = el.length;
            }
            if (found) {
              found.childs = el;
            }
            if (found && found._childs > 30) {
              return found._open = false;
            }
          });
        },
        getTree: function(args) {
          return this.db_tree;
        },
        jsFindByParent: function(args) {
          return this.db_parents['n' + args];
        },
        web_tags: [
          {
            id: 1,
            parent: 0,
            title: "Кулинария",
            cnt: 1
          }, {
            id: 5,
            parent: 1,
            title: "Супы",
            cnt: 6
          }, {
            id: 7,
            parent: 5,
            title: "Диетические",
            cnt: 1
          }, {
            id: 8,
            parent: 5,
            title: "Фруктовые",
            cnt: 3
          }, {
            id: 6,
            parent: 1,
            title: "Каши",
            cnt: 3
          }, {
            id: 2,
            parent: 0,
            title: "Рукоделие",
            cnt: 1
          }, {
            id: 9,
            parent: 2,
            title: "Холодный фарфор",
            cnt: 2
          }, {
            id: 10,
            parent: 2,
            title: "Тильда",
            cnt: 0
          }, {
            id: 10,
            parent: 2,
            title: "Скрапбукинг",
            cnt: 1
          }, {
            id: 10,
            parent: 2,
            title: "Канзаши",
            cnt: 3
          }, {
            id: 10,
            parent: 2,
            title: "Бисероплетение",
            cnt: 211
          }, {
            id: 10,
            parent: 2,
            title: "Вязание",
            cnt: 1
          }, {
            id: 3,
            parent: 0,
            title: "Мои новости",
            cnt: 8
          }, {
            id: 4,
            parent: 0,
            title: "Я в лицах",
            cnt: 11
          }
        ],
        tree_tags: [
          {
            id: 1,
            parent: 0,
            title: "GTD",
            cnt: 0
          }, {
            id: 4,
            parent: 1,
            title: "Входящие",
            cnt: 12
          }, {
            id: 2,
            parent: 1,
            title: "Следующие действия",
            cnt: 4
          }, {
            id: 3,
            parent: 1,
            title: "Когда-нибудь",
            cnt: 24
          }, {
            id: 5,
            parent: 1,
            title: "Календарь",
            cnt: 120
          }, {
            id: 6,
            parent: 1,
            title: "Ожидание",
            cnt: 8
          }, {
            id: 7,
            parent: 1,
            title: "Проект",
            cnt: 3
          }, {
            id: 8,
            parent: 0,
            title: "Рабочие дела",
            cnt: 4
          }, {
            id: 9,
            parent: 0,
            title: "Домашние дела",
            cnt: 8
          }, {
            id: 10,
            parent: 0,
            title: "Мой сайт",
            cnt: 18
          }, {
            id: 11,
            parent: 0,
            title: "Чтение",
            cnt: 0
          }, {
            id: 12,
            parent: 11,
            title: "Почитать",
            cnt: 2
          }, {
            id: 13,
            parent: 11,
            title: "Прочитано",
            cnt: 243
          }
        ],
        jsFindByParentWeb: function(args) {
          return _.filter(this.web_tags, function(el) {
            return el.parent === args;
          });
        },
        jsFindByParentTags: function(args) {
          return _.filter(this.tree_tags, function(el) {
            return el.parent === args;
          });
        },
        jsFind: _.memoize(function(id) {
          var tree_by_id;
          tree_by_id = _.find(this.db_tree, function(el) {
            return el.id === id;
          });
          if (tree_by_id) {
            return tree_by_id;
          }
        }),
        jsGetPath: _.memoize(function(id) {
          var el, path, prevent_recursive;
          path = [];
          prevent_recursive = 5000;
          while ((el = this.jsFind(id)) && (prevent_recursive--)) {
            id = el.parent;
            path.push(el);
          }
          return path.reverse();
        })
      };
    }
  ]);

}).call(this);
