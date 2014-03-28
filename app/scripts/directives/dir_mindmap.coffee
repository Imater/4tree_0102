angular.module("4treeApp").directive "plumbConnect", ($timeout)->
  replace: true
  require: "?ngModel" # get a hold of NgModelController
  link: (scope, element, attrs, ngModel) ->
    #console.info "Add plumbing for the 'item' element ", attrs.plumbConnect, element.parent('li')

    parent_element = $(element).parents("li:first").parents("li:first").find('.title')
    console.info parent_element.attr('class');

    jsPlumb.Defaults.DragOptions = { cursor: 'pointer', zIndex: 2000 }
    jsPlumb.Defaults.PaintStyle = { 
        lineWidth:1, 
        strokeStyle:"#888"
      }
    jsPlumb.Defaults.Connector = [ "Bezier", { curviness: 30 } ]
    jsPlumb.Defaults.Endpoint = [ "Blank", { radius:5 } ]
    jsPlumb.Defaults.EndpointStyle = { fillStyle: "#567567"  }
    #jsPlumb.Defaults.Anchors = [[ 1, 1, 1, 0, -1, -1 ],[ 0, 1, -1, 0, 1, -1 ]]

    if parent_element.length and false
      $timeout ()->
        jsPlumb.connect {
          source: parent_element
          target: element
          paintStyle: { 
            lineWidth:1, 
            strokeStyle:"#888"
          }
          anchors: [[ 0, 0.5, -1, 0, 1, -1 ],[ 0, 0, 0, 0, 0, 0 ]]
        }
      , 0

    
    element.on '$destroy', ()->
      console.info 'destroy ' + attrs.id

    return











if false
    jsPlumb.makeTarget element,
      anchor: "Continuous"
      maxConnections: 2

    jsPlumb.draggable element,
      containment: "parent"

    
    # this should actually done by a AngularJS template and subsequently a controller attached to the dbl-click event
    element.bind "dblclick", (e) ->
      jsPlumb.detachAllConnections $(this)
      $(this).remove()
      
      # stop event propagation, so it does not directly generate a new state
      e.stopPropagation()
      
      #we need the scope of the parent, here assuming <plumb-item> is part of the <plumbApp>     
      scope.$parent.removeState attrs.identifier
      scope.$parent.$digest()
      return

