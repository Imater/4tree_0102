angular.module("4treeApp").directive "jqShowEffect", [
  "$timeout"
  ($timeout) ->
    return (
      restrict: "A"
      link: ($scope, element, attrs) ->
        
        # configure options
        passedOptions = $scope.$eval(attrs.jqOptions)
        
        # defaults
        options =
          type: "fade" # or 'slide'
          duration: 200
          delay: 0
          hideImmediately: false # if true, will hide without effects or duration
          callback: null

        $.extend options, passedOptions
        type = options.type
        duration = options.duration
        callback = options.callback
        delay = options.delay
        hideImmediately = options.hideImmediately
        
        # watch the trigger
        jqElm = $(element)
        $scope.$watch attrs.jqShowEffect, (value) ->
          if hideImmediately and not value
            jqElm.hide 0, callback
          else
            $timeout (->
              if type is "fade"
                (if value then jqElm.fadeIn(duration, callback) else jqElm.fadeOut(duration, callback))
              else if type is "slide"
                (if value then jqElm.slideDown(duration, callback) else jqElm.slideUp(duration, callback))
              else
                (if value then jqElm.show(duration, callback) else jqElm.hide(duration, callback))
              return
            ), delay
          return

        return
    )
]