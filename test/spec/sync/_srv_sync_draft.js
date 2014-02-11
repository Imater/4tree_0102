// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  describe("Sync_test", function() {
    var el123, el200, jsAddToSyncJournal, jsDryObjectBySyncJournal, jsEach, jsGetByPoints, last_sync_time, log_show, new_tree_db, path, sync_journal, sync_journal_TO_SERVER, sync_journal_old, sync_timer, tree_db, tree_db_TO_SERVER, very_new_tree_db;
    path = {};
    jsEach = function(elements, fn, name) {
      if (name == null) {
        name = '';
      }
      return _.each(elements, function(el, key) {
        var dot, name1;
        if (!_.isObject(el)) {
          dot = name ? '.' : '';
          key = name + dot + key;
          return fn.call(this, el, key);
        } else {
          dot = name ? '.' : '';
          name1 = name + dot + key;
          return jsEach(el, fn, name1);
        }
      });
    };
    jsGetByPoints = function(obj, points, create_if_not_finded) {
      var prev_obj, split_point;
      split_point = points.split(".");
      prev_obj = obj;
      _.each(split_point, function(point, i) {
        prev_obj = obj;
        if (!obj[point]) {
          if (create_if_not_finded) {
            return obj = obj[point] = {};
          }
        } else {
          return obj = obj[point];
        }
      });
      return prev_obj;
    };
    jsDryObjectBySyncJournal = function(tree, journal) {
      var answer;
      if (log_show) {
        console.info('tree = ', tree);
      }
      if (log_show) {
        console.info('journal = ', journal);
      }
      if (log_show) {
        console.info('--------------');
      }
      answer = [];
      _.each(journal, function(jr) {
        var element, tree_by_id;
        tree_by_id = tree['n' + jr.id];
        if (!tree_by_id) {
          return 0;
        }
        element = {
          id: jr.id,
          _tm: jr.tm
        };
        _.each(jr.changes, function(change_field_name) {
          var e, last_field_name, points;
          points = change_field_name.split('.');
          e = jsGetByPoints(element, change_field_name, 'create_if_not_finded');
          last_field_name = points[points.length - 1];
          return e[last_field_name] = jsGetByPoints(tree_by_id, change_field_name)[last_field_name];
        });
        return answer.push(element);
      });
      return answer;
    };
    jsAddToSyncJournal = function(journal, new_element, old_element) {
      var answer, journal_exist, journal_exist_last;
      answer = {
        changes: []
      };
      jsEach(new_element, function(el, key) {
        var last_key, spl;
        spl = key.split(".");
        last_key = spl[spl.length - 1];
        if (el !== jsGetByPoints(old_element, key)[last_key]) {
          answer.tm = new Date();
          answer.type = 'update';
          answer.id = new_element.id;
          answer.table = '4tree';
          return answer.changes.push(key);
        }
      });
      journal_exist = _.filter(journal, function(el) {
        return el.id === answer.id;
      });
      journal_exist_last = _.max(journal_exist, function(el) {
        return el.tm;
      });
      if (journal_exist[0]) {
        journal_exist_last.changes = _.union(journal_exist_last.changes, answer.changes);
      } else {
        journal.push(answer);
      }
      if (journal_exist[0]) {
        console.info('journal_exist = ', journal_exist_last.changes);
      }
      return journal;
    };
    log_show = true;
    sync_timer = new Date().getTime();
    tree_db = {
      'n123': {
        id: 123,
        title: 'Old title for id 123',
        parent_id: 11,
        share: {
          link: ''
        },
        sex: [
          {
            id: 1,
            title: 'how'
          }, {
            id: 2,
            title: 'asdasd'
          }
        ]
      },
      'n200': {
        id: 200,
        title: 'Old title for id 200',
        parent_id: 1,
        share: {
          link: '4tree/link'
        },
        sex: [
          {
            myid: 'ups',
            mytitle: 'forhow'
          }, {
            myid: 'iop',
            mytitle: 'asdasd1'
          }
        ]
      }
    };
    new_tree_db = jQuery.extend(true, {}, tree_db);
    el123 = new_tree_db['n123'];
    el123.title = 'New title for id 123';
    el123.parent_id = 2;
    el123.share.link = "http://4tree.ru/sx7";
    el200 = new_tree_db['n200'];
    el200.parent_id = 188;
    el200.share.link = 'upd//dd';
    sync_journal = [];
    sync_journal_old = [
      {
        type: 'update',
        tm: new Date(2014, 1, 11, 11, 30),
        changes: ['title', 'parent_id', 'share.link'],
        id: 123,
        table: '4tree'
      }, {
        type: 'update',
        tm: new Date(2014, 1, 11, 11, 40),
        changes: ['title'],
        id: 200,
        table: '4tree'
      }
    ];
    sync_journal = jsAddToSyncJournal(sync_journal, tree_db['n200'], new_tree_db['n200']);
    sync_journal = jsAddToSyncJournal(sync_journal, tree_db['n123'], new_tree_db['n123']);
    very_new_tree_db = jQuery.extend(true, {}, new_tree_db);
    el200 = very_new_tree_db['n200'];
    el200.title = 'VERY New title for id = 200';
    sync_journal = jsAddToSyncJournal(sync_journal, new_tree_db['n200'], very_new_tree_db['n200']);
    if (log_show) {
      console.info("JOURNAL = ", JSON.stringify(sync_journal));
    }
    sync_journal = _.sortBy(sync_journal, function(el) {
      return el.tm;
    });
    last_sync_time = new Date(2014, 1, 11, 10, 30);
    sync_journal_TO_SERVER = _.filter(sync_journal, function(el) {
      return el.tm > last_sync_time;
    });
    tree_db_TO_SERVER = jsDryObjectBySyncJournal(very_new_tree_db, sync_journal_TO_SERVER);
    _.each(sync_journal_TO_SERVER, function(el) {
      if (log_show) {
        return console.info("sync_journal_TO_SERVER", JSON.stringify(el));
      }
    });
    _.each(tree_db_TO_SERVER, function(el) {
      if (log_show) {
        return console.info("tree_db_TO_SERVER", JSON.stringify(el));
      }
    });
    if (log_show) {
      console.info('sync_timer', sync_timer - new Date().getTime());
    }
    return it("Get 8 mart object fron date", function() {
      return expect(true).toEqual(true);
    });
  });

}).call(this);
