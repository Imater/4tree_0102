// Generated by CoffeeScript 1.6.3
/*
 Класс для сохранения настроек
 Центр полётов, куда стекаются все данные
 */


(function () {
  var MySettingsClass;

  MySettingsClass = (function () {
    MySettingsClass.$inject = ['$timeout'];

    function MySettingsClass($timeout) {
      $timeout(function () {
        if (false) {
          return console.info('constructor MySettingsClass did');
        }
      }, 3000);
    }

    MySettingsClass.prototype.set = {
      hello: 'hello!!!'
    };

    return MySettingsClass;

  })();

  angular.module("4treeApp").service('mySettings', MySettingsClass);

}).call(this);
