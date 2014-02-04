angular.module("4treeApp", [
  "ngCookies"
  "ngResource"
  "ngSanitize"
  "ngRoute"
  "pasvaz.bindonce"
  "pascalprecht.translate"
  "ngTouch"
])

angular.module("4treeApp").config ["$translateProvider", "$routeProvider", ($translateProvider, $routeProvider) ->

  $routeProvider.when("/",
    templateUrl: "views/main.html"
    controller: "MainCtrl"
  ).otherwise redirectTo: "/"

  $translateProvider.translations "en",
    TITLE: "Hello"
    FOO: "This is a paragraph"

  $translateProvider.translations "de",
    TITLE: "Hallo"
    FOO: "Dies ist ein Paragraph"

  $translateProvider.preferredLanguage "en"



]