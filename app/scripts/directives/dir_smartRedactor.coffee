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

          getCurrent = ()->
            path = [];
            parent = $( $_element.redactor "getParent" );
            first_parent = parent;
            current = $( $_element.redactor "getCurrent" );
            path.push({ element: parent, index: parent.index() });
            while parent and parent.length and !parent.hasClass('redactor_editor')
              parent = parent.parent();
              if parent.length
                path.push({element: parent, index: parent.index()});
                console.info '?'.parent;
            {first_parent, current, path}

          setCurrent = (old_position)->
            path_reverse = old_position.path.reverse();
            element = $('body');
            _.each path_reverse, (path)->
              if path.element and path.element[0].length
                element = element.find(path.element[0])
              else
                if $(path.element[0]).hasClass('redactor_editor')
                  element = $(path.element[0])
                else
                  element = element.find(path.element[0].localName+':eq('+path.index+')')
              console.info '!', path.element[0], path.index
            element
            

          $rootScope.$on 'refresh_editor', _.debounce (value)->
              db_tree.getText( ngModel.$viewValue ).then (text_element)->
                
                #offset = $_element.redactor("getCaretOffset", parent)
                #console.info $_element.redactor "getBlock", $_element.redactor "getParent"
                #index = $(parent).index();
                old_position = getCurrent();
                if old_position.first_parent and old_position.first_parent.length
                  offset = $_element.redactor("getCaretOffset", old_position.first_parent[0] )
                else
                  offset = 0
                $_element.redactor "set", text_element?.text or "", false
                old_element = setCurrent( old_position );
                console.info '&&&&&&&', old_element.html().length, offset
                if offset > old_element.html().length
                  offset = old_element.html().length;
                $_element.redactor "setCaret", old_element, offset if old_element.length
                #txt = $(parent).html();
                #find_again = $_element.find( '*:contains('+txt.substr(0,txt.length-1)+')' ); 
                #'*:eq('+index+')'
                #$_element.redactor "focus"
                #$timeout ()->
                #  $_element.redactor "setCaret", find_again, offset if find_again.length
                #, 0
                #console.info "!!!!!SET!!!", find_again, offset
            , 1

          ngModel.$render = ->
            if angular.isDefined(editor)
              #$timeout ->
              db_tree.getText( ngModel.$viewValue ).then (text_element)->
                $_element.redactor "set", text_element?.text or "", false

      )
  ]
