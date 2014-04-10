angular.module("4treeApp").directive "myDraggable", ->
  link: (scope, el, attrs) ->
    el.draggable
      connectToSortable: attrs.myDraggable
      helper: "clone"
      appendTo: "#w_main"
      distance: 10
      handle: '.handle, .col2'
      #cancel: '.contenteditable,.title'
      stop: (event, ui)->
        console.info 'draggable stop', ui
      #containment: "window"
    #el.disableSelection()
    return





angular.module("4treeApp").directive "mySortable", ->
  require: "?ngModel" # get a hold of NgModelController
  link: (scope, el, attrs) ->
    el.sortable 
      revert: false
      distance: 10
      handle: '.handle, .col2'
      cancel: '.contenteditable,.title'
    #el.disableSelection()
    el.on "sortstart", (event, ui) ->
      console.info 'start', ui.item[0].dataset.id
      $(this).data().sort_id = ui.item[0].dataset.id;
      $(".tree_tmpl[data-id='"+$(this).data().sort_id+"']").addClass('drag_now')
    el.on "sortbeforestop", (event, ui) -> #deactivate
      event.stopPropagation();
      event.preventDefault();
      from_data_id = $(this).data().sort_id;
      $(".tree_tmpl[data-id='"+$(this).data().sort_id+"']").removeClass('drag_now')      
      from = angular.element(ui.item).scope().$index
      to = el.children().index(ui.item)
      to = angular.element(event.target).children("[data-id='"+from_data_id+"']").index();
      to_data_parent_id = angular.element(this).attr('data-parent-id');
      console.info "FROM", from_data_id, "TO", to_data_parent_id;
      if to >= 0
        scope.$apply ->
          if from >= 0 or true
            console.info 'sorted', {to, from}, angular.element(ui.item).scope().tree;
            scope.$emit "my-sorted",
              from: from
              to: to
              from_id: from_data_id
              to_id: to_data_parent_id

          else
            console.info 'created', {to};
            scope.$emit "my-created",
              to_id: to_data_parent_id
              to_index: to
              name: ui.item.text()

            ui.item.remove()
          return
      return

    return
