angular.module("4treeApp", [
  "ngCookies"
  "ngResource"
  "ngSanitize"
  "ngRoute"
  "pasvaz.bindonce"
  "pascalprecht.translate"
  "ngTouch"
  "sun.scrollable"
  "sf.virtualScroll"  
])

angular.module("4treeApp").config ["$translateProvider", "$routeProvider", ($translateProvider, $routeProvider) ->

  $routeProvider.when("/",
    templateUrl: "views/main.html"
    controller: "MainCtrl"
  ).otherwise redirectTo: "/"

  $translateProvider.translations "en",
    TREE: "Tree"
    CALENDAR: "Calendar"
    EDITOR: "Editor"
    PLANOFDAY: "Plan of the day"
    ADD: "Add task..."
    POMIDOR: "Timer Pomodorro"
    POMIDORS_TITLE: [
      '0': 'Нажмите, чтобы начать работу 25 минут'
      's1': 'Работайте не отвлекаясь 25 минут'
      '2': 'Отдохните 5 минут'
      '3': 'Работайте не отвлекаясь 25 минут'
      '4': 'Отдохните 5 минут'
      '5': 'Работайте не отвлекаясь 25 минут'
      '6': 'Отдохните 5 минут'
      '7': 'Работайте не отвлекаясь 25 минут'
      '6': 'Отдохните 15 минут'
    ]
    MONTH: { 
      '1': "jan"
      '2': "feb"
      '3': "mar"
      '4': "apr"
      '5': "may"
      '6': "jun"
      '7': "jul"
      '8': "aug"
      '9': "sept"
      '10': "oct"
      '11': "nov"
      '12': "dec"
    }
    WEEKDAY: {
      '0': "sun"
      '1': "mon"
      '2': "tue"
      '3': "wed"
      '4': "thu"
      '5': "fri"
      '6': "sat"
      '7': "sun"
    }

  $translateProvider.translations "ru",
    TREE: "Дерево"
    CALENDAR: "Календарь"
    EDITOR: "Редактор"
    PLANOFDAY: "План на день"
    POMIDOR: "Таймер Pomodorro"
    ADD: "Добавить..."
    POMIDORS_TITLE: {
      '0': 'Нажмите помидорку, и работайте 25 минут'
      '1': 'Работайте не отвлекаясь 25 минут'
      '2': 'Отлично. Отдохните 5 минут'
      '3': 'Работайте не отвлекаясь 25 минут'
      '4': 'Супер. Отдохните 5 минут'
      '5': 'Работайте не отвлекаясь 25 минут'
      '6': 'Так держать. Отдохните 5 минут'
      '7': 'Работайте не отвлекаясь 25 минут'
      '8': 'Вы заслужили отдых 15 минут'
    }
    MONTH: { 
      '1': "янв"
      '2': "февр"
      '3': "март"
      '4': "апр"
      '5': "май"
      '6': "июнь"
      '7': "июль"
      '8': "авг"
      '9': "сент"
      '10': "окт"
      '11': "нояб"
      '12': "дек"
    }
    WEEKDAY: {
      '0': "вс"
      '1': "пн"
      '2': "вт"
      '3': "ср"
      '4': "чт"
      '5': "пт"
      '6': "сб"
      '7': "вс"
    }

  lng = window.navigator.userLanguage || window.navigator.language; 

  lang = "en"
  lang = "ru" if (lng.indexOf("ru")!=-1) or (lng.indexOf("ukr")!=-1)

  $translateProvider.preferredLanguage lang



]


angular.module("4treeApp").directive "clickAnywhereButHere", [
  "$document"
  ($document) ->
    return link: postLink = (scope, element, attrs) ->
      onClick = (event) ->
        isChild = element.has(event.target).length > 0
        isSelf = element[0] is event.target
        isInside = isChild or isSelf
        scope.$apply attrs.clickAnywhereButHere  unless isInside
        return

      scope.$watch attrs.isActive, (newValue, oldValue) ->
        if newValue isnt oldValue and newValue is true
          $document.bind "click", onClick
        else $document.unbind "click", onClick  if newValue isnt oldValue and newValue is false
        return

      return
]