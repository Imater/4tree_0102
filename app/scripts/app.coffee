angular.module("4treeApp", [
  "ngCookies"
  "ngResource"
  "ngSanitize"
  "ngRoute"
  "pasvaz.bindonce"
  "pascalprecht.translate"
  "ngTouch"
  "sun.scrollable"
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


angular.module("4treeApp").directive "scrollpane", ($compile) ->
  restrict: "A"
  link: (scope, element, attrs) ->
    console.info element
    element.addClass "scroll-pane"
    element.jScrollPane()
    api = element.data("jsp")
    scope.$watch (->
      element.find("." + attrs.scrollpane).length
    ), (length) ->
      api.reinitialise()
      return
