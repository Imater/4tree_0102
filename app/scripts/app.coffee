moment.lang('ru')

angular.module("4treeApp", [
  "ngCookies"
  "ngResource"
  #"ngSanitize"
  "app.directives"
  "ngRoute"
  "pasvaz.bindonce"
  "pascalprecht.translate"
  #"ngTouch"
  "sun.scrollable"
  "ui.scroll" 
  #"sf.virtualScrollNew" 
  "angular-redactor"
  #"ngAnimate"
  "ui-rangeSlider"
  "$strap"
  "$strap.directives"
  "ngSanitize"
  "ngBootstrap"
  "ngTagsInput"
  "sly"
  "ngClipboard"
  "ngSocket"
  #"Decorators"
  "drahak.hotkeys"
  'route-segment'
  'view-segment'
  'ngRoute'
])

angular.module("4treeApp").config ["$translateProvider", "$locationProvider", "$routeProvider", "$routeSegmentProvider", ($translateProvider, $locationProvider, $routeProvider, $routeSegmentProvider) ->

  ###
  $routeProvider.when("/",
    templateUrl: "views/main.html"
    controller: "MainCtrl"
  ).otherwise redirectTo: "/"
  ###

  $routeSegmentProvider.options.autoLoadTemplates = true;

  $routeSegmentProvider
  .when '/home', 'home'
  .when '/login', 'login'
  .segment 'home', {
    templateUrl: 'views/main.html'
    controller: 'MainCtrl'
  }
  .segment 'login', {
    templateUrl: 'views/main/login.html'
    controller: 'LoginCtrl'
  }

  $routeProvider.otherwise({redirectTo: '/home'});


  $translateProvider.translations "en",
    TREE: "Tree"
    CALENDAR: "Calendar"
    EDITOR: "Editor"
    PLANOFDAY: "Plan of the day"
    ADD: "Add task..."
    TASKS: "Tasks"    
    POMIDOR: "Timer Pomodorro"
    ENCRYPT: {
      JSON_ERROR: "Error in JSON parse of encrypted data"
      PASS_ERROR: "Wrong password"
    }
    POMIDORS_TITLE: {
      '0': 'Click and work for 25 minutes'
      '1': 'Work for 25 minutes'
      '2': 'Ok. Take a rest for 5 minutes'
      '3': 'Work for 25 minutes'
      '4': 'Ok. Take a rest for 5 minutes'
      '5': 'Work for 25 minutes'
      '6': 'Ok. Take a rest for 5 minutes'
      '7': 'Work for 25 minutes'
      '8': 'Good. Take a rest for 15 minutes'
    }
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
    TASKS: "Дела"    
    ENCRYPT: {
      JSON_ERROR: "Ошибка расшифровки, так как данные не в формате JSON"
      PASS_ERROR: "Неверный пароль"
    }
    POMIDORS_TITLE: {
      '0': 'Нажмите, и работайте 25 минут'
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
      '1': "янв."
      '2': "февр."
      '3': "марта"
      '4': "апр."
      '5': "мая"
      '6': "июня"
      '7': "июля"
      '8': "авг."
      '9': "сент."
      '10': "окт."
      '11': "нояб."
      '12': "дек."
    }
    MONTH_FULL: { 
      '1': "Январь"
      '2': "Февраль"
      '3': "Март"
      '4': "Апрель"
      '5': "Май"
      '6': "Июнь"
      '7': "Июль"
      '8': "Август"
      '9': "Сентябрь"
      '10': "Октябрь"
      '11': "Ноябрь"
      '12': "Декабрь"
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



# Recursive underscore methods

# fn(value,keyChain)

# Default value for maxDepth

# Kick off recursive function

# If the key is null, this is the root item, so skip this step
# Descend

# If the current item is a collection

# Leaf items land here and execute the iterator

# fn(original,newOne,anotherNewOne,...)

# TO-DO: make this work for more than one newObj
# var newObjects = _.toArray(arguments).shift();

# If the new value is a non-object or array, 
# or the old value is a non-object or array, use it

# Otherwise, we have to descend recursively

# fn(original,newOne,anotherNewOne,...)

# TO-DO: make this work for more than one newObj
# var newObjects = _.toArray(arguments).shift();

# If the new value is a non-object or array, 
# or the old value is a non-object or array, use it

# Otherwise, we have to descend recursively

# ### _.objMap
# _.map for objects, keeps key/value associations
objMap = (input, mapper, context) ->
  _.reduce input, ((obj, v, k) ->
    obj[k] = mapper.call(context, v, k, input)
    obj
  ), {}, context
_.recursive =
  all: (collection, fn, maxDepth) ->
    _all = (item, key, keyChain, fn, depth) ->
      lengthenedKeyChain = []
      throw new Error("Depth of object being parsed exceeds maxDepth ().  Maybe it links to itself?")  if depth > maxDepth
      if key isnt null and keyChain
        lengthenedKeyChain = keyChain.slice(0)
        lengthenedKeyChain.push key
      if _.isObject(item)
        _.all item, (subval, subkey) ->
          _all subval, subkey, lengthenedKeyChain, fn, depth + 1

      else
        fn item, lengthenedKeyChain
    return true  unless _.isObject(collection)
    maxDepth = maxDepth or 50
    return _all(collection, null, [], fn, 0)
    return

  extend: (original, newObj) ->
    _.extend original, objMap(newObj, (newVal, key) ->
      oldVal = original[key]
      if _.isArray(newVal) or not _.isObject(newVal) or _.isArray(oldVal) or not _.isObject(oldVal)
        newVal or oldVal
      else
        _.recursive.extend oldVal, newVal
    )

  defaults: (original, newObj) ->
    _.extend original, objMap(newObj, (newVal, key) ->
      oldVal = original[key]
      if _.isArray(newVal) or not _.isObject(newVal) or _.isArray(oldVal) or not _.isObject(oldVal)
        oldVal or newVal
      else
        _.recursive.extend oldVal, newVal
    )


