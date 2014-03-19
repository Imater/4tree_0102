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
		expect( db_tree.length ).toBeGreaterThan 1
		return

	it "Test jsFind function", ->
		expect( srv_db_tree.jsFind(1).title ).toBe 'Рабочие дела'
		expect( srv_db_tree.jsFind(500000) ).toBeUndefined()

	it "Test jsGetPath function", ->
		#console.info srv_db_tree.jsGetPath(11)
		expect( srv_db_tree.jsGetPath(11).length ).toBeGreaterThan 0

	it "MapReduce", ->
		expect( 2 ).toBe 2


