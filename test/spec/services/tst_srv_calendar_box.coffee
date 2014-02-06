"use strict"
describe "Service calendarBox test", ->

	# load the controller's module
	beforeEach module("4treeApp")
	MainCtrl = undefined
	scope = undefined
	myService = undefined
	translate = undefined
  
	#Initialize the controller and a mock scope
	beforeEach inject(($controller, $rootScope, $translate) ->
		scope = $rootScope.$new()
		MainCtrl = $controller("MainCtrl",
		$scope: scope
		)

		$injector = angular.injector(["4treeApp"])
		myService = $injector.get("calendarBox")
		translate = $translate;

	)
  
	it "Get 8 mart object fron date", ->
		mydate = new Date(2014,2,8)
		expect( myService.getDateBox( mydate ).day ).toEqual '8' 
		expect( myService.getDateBox( mydate ).month ).toEqual 'март' 
		expect( myService.getDateBox( mydate ).week_day ).toEqual 'сб' 
		return




