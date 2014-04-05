// Generated by CoffeeScript 1.6.3
(function() {
  angular.module("4treeApp").service('calendarBox', [
    '$translate', 'db_tree', '$rootScope', function($translate, db_tree, $rootScope) {
      var _i, _results;
      return {
        _calendar_container: (function() {
          _results = [];
          for (_i = 1; _i <= 5000; _i++){ _results.push(_i); }
          return _results;
        }).apply(this),
        datasource: function() {
          var _j, _results1;
          return (function() {
            _results1 = [];
            for (_j = 1; _j <= 5000; _j++){ _results1.push(_j); }
            return _results1;
          }).apply(this);
        },
        constructor: function($timeout) {
          this.$timeout = $timeout;
          return this.color = 'grey';
        },
        getDate: function(args) {
          return 1;
        },
        jsDateDiff: function(date2, only_days) {
          var answer, days, dif_sec, hours, minutes, now, pr2;
          answer = {
            text: "∞",
            "class": "nodate",
            image: ""
          };
          if (!date2) {
            return answer;
          }
          if (date2 === "0000-00-00 00:00:00") {
            return answer;
          }
          answer["class"] = "";
          now = new Date;
          if (only_days) {
            now.setHours(0);
            now.setMinutes(0);
            now.setSeconds(0);
            date2 = new Date(date2);
            date2.setHours(0);
            date2.setMinutes(0);
            date2.setSeconds(0);
          }
          dif_sec = date2.getTime() - now;
          if (dif_sec > 0) {
            dif_sec += 1000;
          }
          if (dif_sec < 0) {
            dif_sec -= 1000;
          }
          days = parseInt(dif_sec / (60 * 1000 * 60 * 24), 10);
          minutes = parseInt(dif_sec / (60 * 1000), 10);
          if (only_days && days === 0) {
            minutes = 0;
          }
          if (days === 0) {
            if ((minutes > 59) || (minutes < -59)) {
              hours = parseInt(dif_sec / (60 * 1000 * 60) * 10, 10) / 10;
              answer.text = (minutes > 0 ? "+ " : "") + hours + " ч.";
            } else {
              answer.text = (minutes > 0 ? "+ " : "") + minutes + " мин.";
            }
            if (only_days) {
              answer.text = "сегодня";
            }
          } else {
            answer.text = (days > 0 ? "+ " : "") + days + " дн.";
          }
          if (days === 0) {
            if (minutes < 0) {
              answer["class"] = "datetoday past";
              pr2 = (-minutes / 480) * 100;
              if (pr2 > 80) {
                pr2 = 80;
              }
              answer.image = "background-image: -webkit-gradient(linear, left top, right top, color-stop(" + (pr2 - 25) + "%, #f56571), color-stop(" + (pr2 + 25) + "%, rgba(0,0,0,0))) !important;";
            }
            if (minutes >= 0) {
              answer["class"] = "datetoday";
            }
          } else {
            if (minutes < 0) {
              answer["class"] = "datepast";
            }
          }
          return answer;
        },
        getDates: function(args) {
          return this.getDate(args.today);
        },
        getDateBox: _.memoize(function(date) {
          var add, answer, day, fulldate, month, month1, myclass, week_day, year;
          if (!this.current_month) {
            this.current_month = (new Date()).getMonth();
          }
          day = date.getDate().toString();
          month1 = date.getMonth();
          year = date.getFullYear().toString().substr(2, 4);
          fulldate = date;
          week_day = $translate('WEEKDAY.' + (date.getDay()));
          month = $translate('MONTH.' + (month1 + 1));
          myclass = 'week_' + (date.getDay());
          if (date < new Date()) {
            myclass += " past";
          }
          if (date.toString() === new Date().toString()) {
            myclass += " today";
          }
          if (this.current_month % 2) {
            add = 1;
          }
          return answer = {
            day: day,
            month: month,
            year: year,
            week_day: week_day,
            myclass: myclass,
            fulldate: fulldate
          };
        }),
        getDays: _.memoize(function(date, only_days) {
          return this.jsDateDiff(date, only_days);
        }, function(date, only_days) {
          return date + parseInt(new Date().getTime() / 1000 / 120) + only_days;
        }),
        getCalendarForIndex: function($index) {
          var date, element, key;
          $index = $index + $rootScope.$$childHead.set.from_today_index;
          date = new Date(new Date().getTime() + ($index - 3) * 24 * 60 * 60 * 1000);
          element = this.getDateBox(date);
          key = moment(element.fulldate).format('YYYY-MM-DD');
          element.tasks = db_tree.getView('tasks', 'tasks_by_date').result[key];
          _.each(element.tasks, function(task) {
            var tm;
            tm = moment(task.date2).format('HH:MM');
            return task.time = tm;
          });
          element.tasks = _.sortBy(element.tasks, function(task) {
            return task.time;
          });
          return element;
        }
      };
    }
  ]);

}).call(this);
