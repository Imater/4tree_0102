"use strict"
describe "Service db_tree test", ->

	# load the controller's module
	beforeEach module("4treeApp")
	MainCtrl = undefined
	scope = undefined
	srv_db_tree = undefined
	translate = undefined


	db = {
		'tree': {
			'rows': [
				{id:'1', title: 'first!!!', parent: '4'}
				{id:'2', title: 'second', parent: '5'}
				{id:'3', title: 'third', parent: '5'}
				{id:'4', title: 'fours', parent: '4'}
				{id:'5', title: 'fives', parent: '5'}
				{id:'6', title: 'six', parent: '5'}
			]
		}
		'tasks': {
			'rows': [
				{id:'1', title: 'first', parent: 5}
				{id:2, title: 'second', parent: 5}
				{id:3, title: 'third', parent: 5}
				{id:4, title: 'fours', parent: 5}
				{id:5, title: 'fives', parent: 4}
				{id:6, title: 'six', parent: 5}
			]
		}
		'words': {
			rows: [
				{id:1, text: "привет как дела у тебя мой друг"}
				{id:2, text: "другой мыслитель хочет быть тут"}
				{id:3, text: "что мы тут делаем и хотим"}
				{id:4, text: "ласковый мерзавец тут у нас привет"}
			]
		}
	}

	views_refresh = (db)->
		_.each db, (db_base, db_name)->
			console.info 'Analyse Base = ', db_name; 
			_.each db_base.views, (view, view_name)->

				emit = (key, value)->
					view.rows = [] if !view.rows
					view.rows.push( {key, value} )

				console.info 'view = ', view_name
				_.each db_base.rows, (doc, key)->
					view['map'](doc, emit);

				view.result = view['reduce'](null, view.rows) if view['reduce'];
				view.rows = _.sortBy view.rows, (el)->
					el.key
  
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

	xit "MapReduce", ->
		views_refresh db
		console.info JSON.stringify db.tree.views.by_day
		console.info JSON.stringify db.tree.views.by_title
		console.info JSON.stringify db.tasks.views.by_parent
		console.info JSON.stringify db.tasks.views.by_id
		expect( srv_db_tree.jsView() ).toBe 'hi!'


	newView = (db_name, view_name, mymap, myreduce )->
		db[db_name]['views'] = {} if !db[db_name]['views']
		if !db?[db_name]?['views'][view_name]
			db?[db_name]?['views'][view_name] = {
				rows: []
				invalid: [] 
				'map': mymap
				'reduce': myreduce
			}

	generateView = (db_name, view_name, view_invalid)->
		view = db[db_name]['views'][view_name];

		if view_invalid
			myrows = _.filter db[db_name].rows, (el)->
				view_invalid.indexOf(el.id) != -1
		else 
			myrows = db[db_name].rows

		memo = {};

		emit = (key, value)->
			view.rows = [] if !view.rows
			view.rows.push( {key, value} )
			view['reduce'](memo, {key, value})

		_.each myrows, (doc, key)->
			result = view['map'](doc, emit);

		view.rows = _.sortBy view.rows, (el)->
			el.key

		view.invalid = [];

		view.result = memo;

		

	getView = (db_name, view_name)->
		view = db?[db_name]?['views'][view_name];
		if( view.rows.length && view.invalid.length == 0 )
			return view;
		else if (view.invalid.length > 0 and view.rows.length>0) 
			generateView(db_name, view_name, view.invalid);
			return view;
		else
			generateView(db_name, view_name);
			return view;

	refreshView = (db_name, ids)->
		_.each ids, (id)->
			_.each db[db_name].views, (view)->
				view.invalid.push( id )
				console.info "REFRESH", id, view.invalid


	xit "new MapReduce", ->

		mymap = (doc, emit)->
			if doc.parent == '4'
				emit(doc.parent, doc.title);

		myreduce = (keys, values, rereduce)->
			values.length

		newView('tree', 'by_day_new', mymap, myreduce);
		console.info JSON.stringify db['tree']

		console.info 'VIEW1 = ', JSON.stringify getView('tree','by_day_new');

		found = _.find db['tree'].rows, (el)->
			el.id == '4'
		found.title = 'NEW!!!!!!!!!!!!!!!!' 
		found.parent = '12' 

		refreshView('tree', ['4']);

		console.info 'VIEW2 = ', JSON.stringify getView('tree','by_day_new');

		expect(true).toBe true

	it "new new MapReduce", ->

		mymap = (doc, emit)->
			words = doc.text.split(" ");
			_.each words, (word)->
				emit(word, 1);

		myreduce = (memo, values)->
			key = 0 #values.key; 
			memo[key] = 0 if !memo[key]
			memo[key] += values.value if values.value
			console.info "MEMO = ", memo, values
			memo

		newView('words', 'by_word', mymap, myreduce)

		words = getView('words', 'by_word')

		_.each words.rows, (word)->
			#console.info word
		console.info "Result = ", words.result

		expect(true).toBe true



###
	newView('tree', 'by_day', map, reduce);
	Создаёт схему для нового вида

	getView('tree', 'by_day');
	возвращает вид по плану:
	1. Если вид пустой, генерирует его полностью
	2. Если вид полный, но есть инвалидные данные, генерирует только их:
		1. Пропускает невалидные данные через map
		2. Результат пропускает через Reduce
		3. Результат пропускает через ReReduce
		4. Помечает данные валидными


	refreshId('tree', _id);
	инвалидирует _id в виде, чтобы обновить его при следующем запросе
###



























