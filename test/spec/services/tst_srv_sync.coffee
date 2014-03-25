"use strict"
describe "Service syncApi test", ->

	# load the controller's module
	beforeEach module("4treeApp")
	MainCtrl = undefined
	scope = undefined
	syncApi = undefined
	translate = undefined
	db_tree = undefined
  
	#Initialize the controller and a mock scope
	beforeEach inject(($controller, $rootScope, $translate) ->
		scope = $rootScope.$new()
		MainCtrl = $controller("MainCtrl",
		$scope: scope
		)

		$injector = angular.injector(["4treeApp"])
		syncApi = $injector.get("syncApi")
		db_tree = $injector.get("db_tree")
		db_tree.constructor();

		syncApi.constructor();

	)
  
	it "Constructor function", ->
		expect( true ).toBe true









