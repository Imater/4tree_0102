  ###
  usage: <textarea ng-model="content" redactor></textarea>
  
  additional options:
  redactor: hash (pass in a redactor options hash)
  ###


  angular.module("angular-redactor", []).directive "smartRedactor", [
    "$timeout", "$rootScope", "db_tree"
    ($timeout, $rootScope, db_tree) ->
      return (
        restrict: "A"
        require: "ngModel"
        link: (scope, element, attrs, ngModel) ->

          updateModel = (value) ->
            scope.$apply ->
              text_id = ngModel.$viewValue
              db_tree.setText text_id, value if text_id

          resizecontent = _.debounce ()->
            $(element).parents('.content').scroll();
          , 100

          $(window).resize ()->
            resizecontent();

          options = { 
            boldTag: 'b'
            changeCallback: _.debounce (value)->
              updateModel(value);
            , 100
            imageUpload: '/api/v1/uploadImage/?id='+$rootScope.$$childTail.set.user_id
            clipboardUploadUrl: '/api/v1/uploadImage/?id='+$rootScope.$$childTail.set.user_id
          }


          additionalOptions = (if attrs.smartRedactor then scope.$eval(attrs.smartRedactor) else {})
          editor = undefined
          $_element = angular.element(element)
          angular.extend options, additionalOptions
          
          # put in timeout to avoid $digest collision.  call render() to
          # set the initial value.
          $timeout ->
            editor = $_element.redactor(options)
            ngModel.$render()
          , 10

          $rootScope.$on 'refresh_editor', _.debounce (value)->
              db_tree.getText( ngModel.$viewValue ).then (text_element)->
                $_element.redactor "set", text_element?.text or "", false
            , 1

          ngModel.$render = ->
            if angular.isDefined(editor)
              #$timeout ->
              db_tree.getText( ngModel.$viewValue ).then (text_element)->
                $_element.redactor "set", text_element?.text or "", false

      )
  ]
