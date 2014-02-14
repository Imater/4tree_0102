MongoClient = require('mongodb').MongoClient
async = require('async')
_ = require('underscore')

class Tree_note 
	constructor: (args)->
		@id = undefined
		@title = undefined
		@note = undefined
		@tags = [
		]
		mythis = @
		#присваеваем все заданные значения

		_.each args, (val, key)->
			mythis[key] = val

class Mongofunctions 
	constructor: ()->
	connect: (collection_name, callback)->
		MongoClient.connect 'mongodb://127.0.0.1:27017/test', (err, db)->
			@collection = db.collection(collection_name)
			@db = db;
			callback err
	removecollection: (callback)->
		collection.remove {}, (err, count)->
			callback err
	disconnect: (callback)->
		db.close()

mymongo = new Mongofunctions;

describe 'MondoDB - проверка работы разных функций', ->


	it 'Вставка значения', (done)->
		async.series [
			async.apply mymongo.connect, 'test_insert'
			async.apply mymongo.removecollection
			(callback)->
				#вставка нового элемента в базу
				collection.insert {timenow: new Date()}, (err, count)->
					expect( count.length ).toEqual 1
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Вставка второго значения', (done)->
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				tree_note = new Tree_note({title:'Привет', tags: [1,2,3,4]});
				collection.insert tree_note, (err, count)->
					expect( count.length ).toEqual 1
					callback err
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.count (err, count)->
					expect( count ).toEqual 2
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Вставка тысячи элементов в базу', (done)->
		
		insert_one = (val, callback)->
			tree_note = new Tree_note({id: val, title: 'Я элемент №'+val, time: new Date()});
			collection.insert tree_note, (err, count)->
				callback err

		insert_many = (callback)->
			async.eachLimit [1..10000], 100, insert_one, (err)->	
				console.info 'done!'
				callback null

		async.series [
			async.apply mymongo.connect, 'test_insert'
			async.apply insert_many
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.count (err, count)->
					expect( count ).toEqual 10002
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()
	  
  