"use strict"
describe "Service db_tree test", ->

	# load the controller's module
	beforeEach module("4treeApp")
	MainCtrl = undefined
	scope = undefined
	srv_db_tree = undefined
	translate = undefined
  
	#Initialize the controller and a mock scope
	beforeEach inject(($controller, $rootScope, $translate) ->
		scope = $rootScope.$new()
		MainCtrl = $controller("MainCtrl",
		$scope: scope
		)

		$injector = angular.injector(["4treeApp"])
		srv_db_tree = $injector.get("db_tree")
		srv_db_tree.constructor();
		translate = $translate;

	)
  
	it "Get db_tree from service db_tree", ->
		db_tree = srv_db_tree.getTree()
		console.info db_tree;
		expect( db_tree.length ).toBeGreaterThan 1
		return




