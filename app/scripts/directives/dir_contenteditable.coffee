angular.module("4treeApp").directive "contenteditable", ->
  restrict: "A" # only activate on element attribute
  require: "?ngModel" # get a hold of NgModelController
  link: (scope, element, attrs, ngModel) ->
    # do nothing if no ng-model
    
    # Specify how UI should be updated
    
    # Listen for change events to enable binding
    
    # No need to initialize, AngularJS will initialize the text based on ng-model attribute
    
    # Write data to the model
    readViewText = ->
      html = element.html()
      
      # When we clear the content editable the browser leaves a <br> behind
      # If strip-br attribute is provided then we strip this out
      html = ""  if attrs.stripBr and html is "<br>"
      ngModel.$setViewValue html
    return  unless ngModel
    ngModel.$render = ->
      element.html ngModel.$viewValue or ""

    element.on "blur keyup change", ->
      scope.$apply readViewText

    element.on '$destroy', ()->
      element.unbind('blur keyup change')





