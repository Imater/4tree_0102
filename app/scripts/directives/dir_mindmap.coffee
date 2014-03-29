suspend_timer_off = _.debounce ()->
  #jsPlumb.setSuspendDrawing(true, true);  
  
  _.each draw_functions_queue, (fn, i)->
    fn.apply() if fn;
    delete draw_functions_queue[i]
  #draw_functions_queue = [];
  false
, 0

suspend_timer_on = _.debounce ()->
  #jsPlumb.setSuspendDrawing(false, true); 
  false
, 120

redraw_all_children = _.debounce (element)->
  $(element).parents("li").each (i,el)->
    found = $(el).find("._jsPlumb_endpoint_anchor_:first")
    console.info "repaint = ", found[0].id
    jsPlumb.repaint( found[0].id );
, 2



draw_functions_queue = {};

angular.module("4treeApp").directive "plumbConnect", ($timeout)->
  replace: true
  require: "?ngModel" # get a hold of NgModelController
  link: (scope, element, attrs, ngModel) ->
    #console.info "Add plumbing for the 'item' element ", attrs.plumbConnect, element.parent('li')

    parent_element = $(element).parents("li:first").parents("li:first").find('.col3')
    suspend_timer_off();

    jsPlumb.Defaults.Container = $(".mindmap .content")
    jsPlumb.Defaults.DragOptions = { cursor: 'pointer', zIndex: 2000 }
    jsPlumb.Defaults.PaintStyle = { 
        lineWidth:1, 
        strokeStyle:"#888"
      }
    jsPlumb.Defaults.Connector = [ "Bezier", { curviness: 30 } ]
    jsPlumb.Defaults.Endpoint = [ "Blank", { radius:5 } ]
    jsPlumb.Defaults.EndpointStyle = { fillStyle: "#567567"  }
    #jsPlumb.Defaults.Anchors = [[ 1, 1, 1, 0, -1, -1 ],[ 0, 1, -1, 0, 1, -1 ]]
    #jsPlumb.setSuspendDrawing(true, true);

    scope.$watch 'tree.title', (new_value, old_value)->
      if old_value != new_value
        console.info 'title_changed'
        redraw_all_children(element);
        

    if parent_element.length and true
      draw_functions_queue[attrs.id] = ()->
        #console.info element.parent().attr("")
        jsPlumb.Defaults.Container = parent_element.parents("li:first")
        jsPlumb.connect {
          source: parent_element
          target: element
          paintStyle: { 
            lineWidth:1, 
            strokeStyle:"#888"
          }
          anchors: [[ 1, 1, 1, 0, -1, -1 ],[ 0, 1, -1, 0, 1, -1 ]]
        }
        redraw_all_children(element);
        suspend_timer_on();
    
    element.on '$destroy', ()->
      suspend_timer_off()
      jsPlumb.detachAllConnections(element);
      redraw_all_children( $(element).parents("li:first").parents("li:first") );
      suspend_timer_on()

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

