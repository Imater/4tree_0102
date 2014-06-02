angular.module("4treeApp").directive "onOutClick", [
  "$document"
  ($document) ->
    return (
      restrict: "A"
      link: (scope, element, attrs) ->
        console.info 'hello', element
        element.bind "click", (e) ->
          e.stopPropagation()
          return

        $document.on "click", ($event) ->
          scope.$apply ->
            scope.$eval attrs.onOutClick
            return

          return

        return
    )
]