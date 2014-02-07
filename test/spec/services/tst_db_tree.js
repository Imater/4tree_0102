// Generated by CoffeeScript 1.6.3
(function() {
  "use strict";
  describe("Service db_tree test", function() {
    var MainCtrl, scope, srv_db_tree, translate;
    beforeEach(module("4treeApp"));
    MainCtrl = void 0;
    scope = void 0;
    srv_db_tree = void 0;
    translate = void 0;
    beforeEach(inject(function($controller, $rootScope, $translate) {
      var $injector;
      scope = $rootScope.$new();
      MainCtrl = $controller("MainCtrl", {
        $scope: scope
      });
      $injector = angular.injector(["4treeApp"]);
      srv_db_tree = $injector.get("db_tree");
      srv_db_tree.constructor();
      return translate = $translate;
    }));
    return it("Get db_tree from service db_tree", function() {
      var db_tree;
      db_tree = srv_db_tree.getTree();
      console.info(db_tree);
      expect(db_tree.length).toBeGreaterThan(1);
    });
  });

}).call(this);
