angular.module("4treeApp").directive "focusMe", ($timeout) ->
  scope:
    trigger: "=focusMe"

  link: (scope, element) ->
    scope.$watch "trigger", (value) ->
      if value is true
        
        #console.log('trigger',value);
        $timeout ()->
          element[0].focus()
          document.execCommand('selectAll', false, null);
        scope.trigger = false
      return

    return