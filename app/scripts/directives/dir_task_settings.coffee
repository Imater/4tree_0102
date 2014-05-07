angular.module("4treeApp").directive "taskSettings", ->
  templateUrl: 'views/subviews/task_settings.html'
  transclude: true
  restrict: "E"
  require: "?ngModel"
  link: (scope, el, attrs, ngModel) ->
    console.info 'directive', el
    scope.show = {
      visible: false
    }

    scope.close = ()->
      scope.show.visible = false
      scope.set.set_task = undefined

    scope.$watch 'task', (old_value, new_value)->
      if old_value!=new_value
        ngModel.$setViewValue = new_value
        scope.show.visible = true;
    , true

    ngModel.$render = ->
      console.info 'render', ngModel.$viewValue
      if ngModel.$viewValue
        scope.task = ngModel.$viewValue;
        scope.show.visible = true;
      else
        scope.show.visible = false;
    return
