angular.module("4treeApp").directive "myDraggable", ->
  link: (scope, el, attrs) ->
    el.draggable
      connectToSortable: attrs.myDraggable
      helper: "clone"
      appendTo: "#w_main"
      distance: 10
      stop: (event, ui)->
        console.info 'draggable stop', ui
      #containment: "window"

    el.disableSelection()
    return


angular.module("4treeApp").directive "myTree8", ->
  restrict: "A"
  scope: {
    tree: '='
    fn: '='
    set: '='
    db: '='
    panel_id: '=panelid'
  }
  replace: true
  transclude: false
  templateUrl: "views/subviews/view_one_line0.html"
  link: ($scope, $element, $attributes)->
    return

<<<<<<< HEAD
strVar="";
strVar += "  <div class=\"tree_tmpl\" my-draggable=\".sortable\" data-id=\"{{tree._id}}\">";
strVar += "    <div ng-controller=\"save_tree_db\" class=\"tree_wrap\" ng-class=\"{open:tree.panel[panel_id]._open, folder:tree._childs, active:(db.main_node[panel_id]._id==tree._id)}\" ng-click=\"db.main_node[panel_id] = tree\">";
strVar += "        <div class=\"col1\">";
strVar += "          <div class=\"is_folder\" ng-click=\"tree.panel[panel_id]._open=!tree.panel[panel_id]._open\"><\/div>";
strVar += "        <\/div>";
strVar += "        <div class=\"col2\" title=\"{{tree._childs}}\" ng-click=\"set.main_parent_id[panel_id] = tree._id\" style=\"background:{{tree.color}};\" ng-class=\"{tree_new:tree._new}\">";
strVar += "          <i class=\"{{fn.service.db_tree.getIcon(tree)}}\" style=\"color: {{tree.icon_color}};\"><\/i>";
strVar += "        <\/div>";
strVar += "        <div class=\"col3\">";
strVar += "            <div class=\"title\">";
strVar += "                 <span contenteditable=\"true\" ng-model=\"tree.title\" focus-me=\"tree._focus_me\" hotkey=\"{'Enter':fn.service.db_tree.jsEnterPress,'Esc':fn.service.db_tree.jsEscPress}\" ng-blur=\"fn.service.db_tree.jsBlur($event, undefined, tree)\" tabindex=\"-1\"><\/span>";
strVar += "                 <span class=\"cnt\" ng-if=\"tree._childs\">({{tree._childs}})<\/span>";
strVar += "            <\/div>    ";
strVar += "        <\/div>        ";
strVar += "        <div class=\"col4\" ng-click=\"fn.service.db_tree.jsAddNote(tree); $event.stopPropagation();\">";
strVar += "          <div class=\"col4table\">";
strVar += "            <i class=\"icon-plus\"><\/i>";
strVar += "          <\/div>";
strVar += "        <\/div>";
strVar += "    <\/div>";
strVar += "  <\/div>";


angular.module("4treeApp").directive "member", ($compile, $rootScope, $timeout)->
=======
angular.module("4treeApp").directive "member", ($compile, $rootScope)->
>>>>>>> parent of b410692... Ускорил
  restrict: 'E'
  replace: true
  transclude: true
  scope: {
    tree: '=member'
    fn: '='
    db: '='
    set: '='
    panel_id: '=panelid'
  }
<<<<<<< HEAD
  templateUrl: 'views/subviews/view_one_line_10.html'
  template2: "<div style='font-size:10px'>"+
    "<div contenteditable='true' ng-model='tree.title'></div>"+
    "</div>"
  #template: strVar
  link: (scope, element, attrs)->
    console.time 'treeRenderTime';
    $timeout ()->
      console.timeEnd 'treeRenderTime';
    scope.$watch 'tree.panel['+scope.panel_id+']._open', (newVal, oldVal)->
      console.info 'change', newVal
      if newVal != oldVal
        if scope.tree._childs > 0 and scope.tree.panel[scope.panel_id]._open
          #scope.elements = scope.fn.service.db_tree.jsFindByParent(scope.tree._id);
          element.append('<my-tree-childs tree="fn.service.db_tree.jsFindByParent(tree._id)" fn="fn" set="set" db="db" panelid="panel_id"></my-tree-childs>')
          $compile(element.contents())(scope)
=======
  templateUrl: 'views/subviews/view_one_line0.html'
  link: (scope, element, attrs)->
    if scope.tree._childs > 0 and scope.tree.panel[1]._open and (elements = $rootScope.$$childTail.fn.service.db_tree.jsFindByParent( scope.tree._id ))
      element.append('<my-tree-childs tree="fn.service.db_tree.jsFindByParent(tree._id)" fn="fn" set="set" db="db" panelid="panel_id"></my-tree-childs>')
      $compile(element.contents())(scope)
>>>>>>> parent of b410692... Ускорил

angular.module("4treeApp").directive "myTreeChilds", ($compile)->
  restrict: "E"
  scope: {
    tree: '='
    fn: '='
    db: '='
    set: '='
    panel_id: '=panelid'
  }
  replace: true
  transclude: true
  template: "<ul><member member='note' fn='fn' set='set' db='db' panelid='panel_id' ng-repeat='note in tree'></member></ul>"
  link: ($scope, $element, $attributes)->
    return



angular.module("4treeApp").directive "mySortable", ->
  require: "?ngModel" # get a hold of NgModelController
  link: (scope, el, attrs) ->
    el.sortable 
      revert: false
      distance: 10
    el.disableSelection()
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
