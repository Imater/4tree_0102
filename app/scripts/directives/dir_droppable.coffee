angular.module("4treeApp").directive "windowDraggable", ->
  link: (scope, el, attrs) ->
    el.draggable
      appendTo: "#w_main"
      distance: 10
      handle: '.drag-handle'
    #cancel: '.contenteditable,.title'
      stop: (event, ui)->
        console.info 'draggable stop', ui
    #containment: "window"
    #el.disableSelection()
    return



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

mytmpl = '<div class="tree_tmpl" my-draggable=".sortable" data-id="{{tree._id}}" render-time> <div ng-controller="save_tree_db" class="tree_wrap" ng-class="{open:tree.panel[panel_id]._open, folder:tree._childs, active:(db.main_node[panel_id]._id==tree._id)}" ng-click="db.main_node[panel_id] = tree"> <div class="col1"> <div class="is_folder" ng-click="tree.panel[panel_id]._open=!tree.panel[panel_id]._open"></div> </div> <div class="col2" title="{{tree._childs}}" ng-click="set.main_parent_id[panel_id] = tree._id" style="background:{{tree.color}};" ng-class="{tree_new:tree._new}"> <i class="{{fn.service.db_tree.getIcon(tree)}}" style="color: {{tree.icon_color}};"></i> </div> <div class="col3"> <div class="title"> <span contenteditable="true" class="contenteditable" ng-model="tree.title" focus-me="tree._focus_me" hotkey="{\'Enter\':fn.service.db_tree.jsEnterPress,\'Esc\':fn.service.db_tree.jsEscPress}" ng-blur="fn.service.db_tree.jsBlur($event, undefined, tree)" tabindex="-1"></span> <span class="cnt" ng-if="tree._childs">({{tree._childs}})</span> </div> </div> <div class="col4" ng-click="fn.service.db_tree.jsAddNote(tree); $event.stopPropagation();"> <div class="col4table"> <i class="icon-plus"></i> </div> </div> </div> </div>'

angular.module("4treeApp").directive "oneNote", ()->
  restrict: "E" # only activate on element attribute  
  scope: false
  #template: "<div style='font-size:10px'>{{tree.title}}</div>"
  templateUrl: 'views/subviews/view_one_line0.html'
  #link: (scope, el, attr) ->
  #  console.info 'link!!!';


angular.module("4treeApp").directive "renderNote", ($timeout, db_tree)->
  restrict: "E"
  require: "?ngModel"
  template: ""
  link: (scope, el, attr, ngModel) ->
    ngModel.$render = ->
      title = ngModel.$viewValue.title
      el.html title or ""



angular.module("4treeApp").directive "renderTime", ($timeout)->
  link: (scope, el, attr) ->
    console.time 'renderTimeALL' if __log.show_time_long
    $timeout ()->
      console.timeEnd 'renderTimeALL' if __log.show_time_long


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


angular.module("4treeApp").directive "mySortableTab", ->
  require: "?ngModel" # get a hold of NgModelController
  link: (scope, el, attrs) ->
    console.info 'tab sort', el
    el.sortable
      revert: false
      distance: 5
      #helper: 'clone'
      tolerance: 'pointer'
      placeholder: "tab-state-highlight"
      #handle: '.handle, .col2'
      #cancel: '.contenteditable,.title'
    el.disableSelection()
    if true
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
              scope.$emit "my-tab-sorted",
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
