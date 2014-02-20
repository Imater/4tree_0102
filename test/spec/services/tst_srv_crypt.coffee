"use strict"
describe "Service db_tree test", ->

	# load the controller's module
	beforeEach module("4treeApp")
	MainCtrl = undefined
	scope = undefined
	cryptApi = undefined
	translate = undefined
  
	#Initialize the controller and a mock scope
	beforeEach inject(($controller, $rootScope, $translate) ->
		scope = $rootScope.$new()
		MainCtrl = $controller("MainCtrl",
		$scope: scope
		)

		$injector = angular.injector(["4treeApp"])
		cryptApi = $injector.get("cryptApi")
		cryptApi.constructor();
		translate = $translate;

	)
  
	it "Crypt some text", ->
		#expect( cryptApi.decrypt( cryptApi.encrypt('hello') ).toString() ).toBe 'hello'
		text = "The Cipher Input 111"
		_.each cryptApi.methods, (type, key)->
			crypted = cryptApi.encrypt( text, key );

			decrypted = cryptApi.decrypt( crypted ).text;

			console.info text.length, crypted.length, crypted, cryptApi.decrypt( crypted ).err

			expect( decrypted ).toBe text
		console.info 'errors = ', cryptApi.decrypt( '{"memo":"ФИО","data":"Чувак ты где?","method":"AES","salt":"38777"}' )
		console.info sha = cryptApi.sha3('sex');
		expect( sha.length ).toBeGreaterThan 5 
		return