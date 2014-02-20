// Generated by CoffeeScript 1.6.3
(function() {
  var objMap;

  angular.module("4treeApp", ["ngCookies", "ngResource", "ngRoute", "pasvaz.bindonce", "pascalprecht.translate", "ngTouch", "sun.scrollable", "sf.virtualScroll", "angular-redactor"]);

  angular.module("4treeApp").config([
    "$translateProvider", "$routeProvider", function($translateProvider, $routeProvider) {
      var lang, lng;
      $routeProvider.when("/", {
        templateUrl: "views/main.html",
        controller: "MainCtrl"
      }).otherwise({
        redirectTo: "/"
      });
      $translateProvider.translations("en", {
        TREE: "Tree",
        CALENDAR: "Calendar",
        EDITOR: "Editor",
        PLANOFDAY: "Plan of the day",
        ADD: "Add task...",
        POMIDOR: "Timer Pomodorro",
        ENCRYPT: {
          JSON_ERROR: "Error in JSON parse of encrypted data",
          PASS_ERROR: "Wrong password"
        },
        POMIDORS_TITLE: {
          '0': 'Click and work for 25 minutes',
          '1': 'Work for 25 minutes',
          '2': 'Ok. Take a rest for 5 minutes',
          '3': 'Work for 25 minutes',
          '4': 'Ok. Take a rest for 5 minutes',
          '5': 'Work for 25 minutes',
          '6': 'Ok. Take a rest for 5 minutes',
          '7': 'Work for 25 minutes',
          '8': 'Good. Take a rest for 15 minutes'
        },
        MONTH: {
          '1': "jan",
          '2': "feb",
          '3': "mar",
          '4': "apr",
          '5': "may",
          '6': "jun",
          '7': "jul",
          '8': "aug",
          '9': "sept",
          '10': "oct",
          '11': "nov",
          '12': "dec"
        },
        WEEKDAY: {
          '0': "sun",
          '1': "mon",
          '2': "tue",
          '3': "wed",
          '4': "thu",
          '5': "fri",
          '6': "sat",
          '7': "sun"
        }
      });
      $translateProvider.translations("ru", {
        TREE: "Дерево",
        CALENDAR: "Календарь",
        EDITOR: "Редактор",
        PLANOFDAY: "План на день",
        POMIDOR: "Таймер Pomodorro",
        ADD: "Добавить...",
        ENCRYPT: {
          JSON_ERROR: "Ошибка расшифровки, так как данные не в формате JSON",
          PASS_ERROR: "Неверный пароль"
        },
        POMIDORS_TITLE: {
          '0': 'Нажмите, и работайте 25 минут',
          '1': 'Работайте не отвлекаясь 25 минут',
          '2': 'Отлично. Отдохните 5 минут',
          '3': 'Работайте не отвлекаясь 25 минут',
          '4': 'Супер. Отдохните 5 минут',
          '5': 'Работайте не отвлекаясь 25 минут',
          '6': 'Так держать. Отдохните 5 минут',
          '7': 'Работайте не отвлекаясь 25 минут',
          '8': 'Вы заслужили отдых 15 минут'
        },
        MONTH: {
          '1': "янв",
          '2': "февр",
          '3': "март",
          '4': "апр",
          '5': "май",
          '6': "июнь",
          '7': "июль",
          '8': "авг",
          '9': "сент",
          '10': "окт",
          '11': "нояб",
          '12': "дек"
        },
        WEEKDAY: {
          '0': "вс",
          '1': "пн",
          '2': "вт",
          '3': "ср",
          '4': "чт",
          '5': "пт",
          '6': "сб",
          '7': "вс"
        }
      });
      lng = window.navigator.userLanguage || window.navigator.language;
      lang = "en";
      if ((lng.indexOf("ru") !== -1) || (lng.indexOf("ukr") !== -1)) {
        lang = "ru";
      }
      return $translateProvider.preferredLanguage(lang);
    }
  ]);

  angular.module("4treeApp").directive("clickAnywhereButHere", [
    "$document", function($document) {
      var postLink;
      return {
        link: postLink = function(scope, element, attrs) {
          var onClick;
          onClick = function(event) {
            var isChild, isInside, isSelf;
            isChild = element.has(event.target).length > 0;
            isSelf = element[0] === event.target;
            isInside = isChild || isSelf;
            if (!isInside) {
              scope.$apply(attrs.clickAnywhereButHere);
            }
          };
          scope.$watch(attrs.isActive, function(newValue, oldValue) {
            if (newValue !== oldValue && newValue === true) {
              $document.bind("click", onClick);
            } else {
              if (newValue !== oldValue && newValue === false) {
                $document.unbind("click", onClick);
              }
            }
          });
        }
      };
    }
  ]);

  objMap = function(input, mapper, context) {
    return _.reduce(input, (function(obj, v, k) {
      obj[k] = mapper.call(context, v, k, input);
      return obj;
    }), {}, context);
  };

  _.recursive = {
    all: function(collection, fn, maxDepth) {
      var _all;
      _all = function(item, key, keyChain, fn, depth) {
        var lengthenedKeyChain;
        lengthenedKeyChain = [];
        if (depth > maxDepth) {
          throw new Error("Depth of object being parsed exceeds maxDepth ().  Maybe it links to itself?");
        }
        if (key !== null && keyChain) {
          lengthenedKeyChain = keyChain.slice(0);
          lengthenedKeyChain.push(key);
        }
        if (_.isObject(item)) {
          return _.all(item, function(subval, subkey) {
            return _all(subval, subkey, lengthenedKeyChain, fn, depth + 1);
          });
        } else {
          return fn(item, lengthenedKeyChain);
        }
      };
      if (!_.isObject(collection)) {
        return true;
      }
      maxDepth = maxDepth || 50;
      return _all(collection, null, [], fn, 0);
    },
    extend: function(original, newObj) {
      return _.extend(original, objMap(newObj, function(newVal, key) {
        var oldVal;
        oldVal = original[key];
        if (_.isArray(newVal) || !_.isObject(newVal) || _.isArray(oldVal) || !_.isObject(oldVal)) {
          return newVal || oldVal;
        } else {
          return _.recursive.extend(oldVal, newVal);
        }
      }));
    },
    defaults: function(original, newObj) {
      return _.extend(original, objMap(newObj, function(newVal, key) {
        var oldVal;
        oldVal = original[key];
        if (_.isArray(newVal) || !_.isObject(newVal) || _.isArray(oldVal) || !_.isObject(oldVal)) {
          return oldVal || newVal;
        } else {
          return _.recursive.extend(oldVal, newVal);
        }
      }));
    }
  };

}).call(this);
