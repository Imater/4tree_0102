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
		expect( syncApi.sync_journal ).toBeDefined()

	it "jsEach function - рекурсивно обходит поля и выполняет функцию для каждого элемента", ->
		sample_object = {first: { second: {third: 'Hello, im third'} }, first2: 'hi!', third: [1,2,3,4,5]}
		keys = [];
		values = [];
		syncApi.jsEach sample_object, (el, key)->
			keys.push( key )
			values.push( el )
		expect( keys.length ).toBeGreaterThan (2)
		expect( keys[0] ).toBe 'first.second.third'
		expect( values.length ).toBeGreaterThan (2)

	it "jsGetByPoints - находит или создает элемент при помощи пути заданного точками", ->
		sample_object = {first: { second: {third: 'Hello, im third'} }, first2: 'hi!', third: [1,2,3,4,5]}
		expect( syncApi.jsGetByPoints(sample_object, 'first.second.third')['third'] ).toBe 'Hello, im third'
		expect( syncApi.jsGetByPoints(sample_object, 'third.0')['1'] ).toBe 2
		f5 = syncApi.jsGetByPoints(sample_object, 'f1.f2.f3.f4.f5', 'create_if_not_finded')
		f5.f5 = 100;
		answer = syncApi.jsGetByPoints(sample_object, 'f1.f2.f3.f4.f5')['f5']
		expect( answer ).toBe 100

	it "jsDryObjectBySyncJournal - выбирает из дерева только те элементы, которые есть в журнале синхронизаций", ->
		expect( true ).toBe true


	it "jsUnion - добавляет или заменяет время в списке изменившихся полей", ->
		old_value = [{key: 'title', tm: new Date(2012,11,1)}] #первый аргумент давнишние изменения
		new_value = [{key: 'title', tm: new Date(2013,11,1)}] #второй аргумент - только что прошедшее изменение
		union1 = syncApi.jsUnion( old_value, new_value )
		expect( +union1[0].tm == +new_value[0].tm ).toBeTruthy()

		new_value = [{key: 'note', tm: new Date(2013,11,1)}] #второй аргумент - только что прошедшее изменение
		union1 = syncApi.jsUnion( old_value, new_value )
		expect( union1.length ).toEqual 2
		expect( +union1[1].tm == +new_value[0].tm ).toBeTruthy()

	xit "getElementByKeysArray - Создание вложенного объекта", ->
		el = {};
		syncApi.getElementByKeysArray(el, ['first', 'second', 'third', 0, 'das']);
		syncApi.getElementByKeysArray(el, ['first', 'second', 'third', 0, 'das', 'sex']);

	have_child_changed = (parent, now_time)->
		answer = false;
		_.each parent, (el, key)->
			if key=='_t' and el > now_time
				answer = true;
			else if _.isObject(el) or _.isArray(el)
				answer = answer or have_child_changed(el, now_time)
		answer
		#true

	no_need = (now_time, el, key, parent, path)->
		have_time = false;
		have_time = have_child_changed(parent[key], now_time)
		_.each path, (p)->
			if p._t > now_time
				have_time = true;
		!have_time


	it "getElementByKeysArray - Создание вложенного объекта", ->
		obj_old = {
			id:1
			title: {v:'hello', _t: "" }
			tags: {v:['label', 'tags', 'new_tag', 'hi']}
			objects: {v: [0: 'first', 1: 'second', 3: 'thirs1']}
			one: { two: { three: {v:2, _t:""} } }
			lexus: {v: '1'}
			comments: [
				{v:'sex'}
				{v:'sex'}
			]
			texts: [
				{v: 'fdka'}
			]
		}
		obj_new = {
			id:1
			title: {v:'hello', _t: "" }
			tags: {v:['label', 'tags', 'new_tag', 'hi']}
			objects: {v: [0: 'first', 1: 'second', 3: 'thirs1']}
			one: { two: { three: {v:2, _t:""} } }
			lexus: {v: '1'}
			texts: {v: [
				{v: 'fdka'}
				{v: 'fdka2'}
			]}
		}
		sync_time = new Date(2015,1,15);
		marked = syncApi.asyncMarkChanges(obj_new, obj_old, sync_time);
		#console.info JSON.stringify marked
		now_time = new Date();
		#console.info JSON.stringify syncApi.deepOmit2 marked, (el, key, parent, path)->
		#	no_need(now_time, el, key, parent, path);











