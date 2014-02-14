MongoClient = require('mongodb').MongoClient
mongo = MongoClient = require('mongodb')
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


	it 'Вставка 100 элементов в базу', (done)->
		
		insert_one = (val, callback)->
			tag = if val%2 and val > 50 then 'новости' else 'рыба'
			tree_note = new Tree_note({id: val, title: 'Я элемент №'+val, time: new Date(), tags: ['мысли', tag]});
			collection.insert tree_note, (err, count)->
				callback err

		insert_many = (callback)->
			async.eachLimit [1..100], 50, insert_one, (err)->	
				callback null

		async.series [
			async.apply mymongo.connect, 'test_insert'
			async.apply insert_many
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.count (err, count)->
					expect( count ).toEqual 102
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()
	  

	it 'Отбор элементов из базы, содержащих оба тега', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.find({tags:['мысли','новости']}).toArray (err, results)->
					expect( results.length ).toEqual 25
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Отбор элементов из базы, содержащих один тег', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.find({tags:'рыба'}).toArray (err, results)->
					expect( results.length ).toEqual 75
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()
    
	it 'Отбор элементов из базы, содержащих один тег', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				collection.findOne {id:28}, (err, results)->
					expect( results.title ).toEqual 'Я элемент №28'
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()

	it 'Работа с курсором', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				cursor = collection.find {}
				cursor.nextObject (err, doc)->
					expect(doc.timenow).toBeDefined()
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()

	it 'Explain - помогает понять, используются ли индексы', (done)->		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				cursor = collection.find {tags:'новости'}
				cursor.limit(1).explain (err, doc)->
					expect( JSON.stringify(doc.indexBounds) ).toMatch /tags/
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Insert - вставка нескольких элементов', (done)->		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				elements = [];
				_.each [1..50], (el)->
					one_element = new Tree_note({title: 'Ещё элемент №'+el});
					one_element.labels = {
						label1: el
					}
					elements.push( one_element )
				collection.insert elements, (err, result)->
					expect(result.length).toBe 50
					done();
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Update - изменение элемента $set', (done)->		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				collection.update {id: 18}, {$set: {note: 'ss', title: 'LOOP', tags: [1,2,3,4]}}, (err, result)->
					expect(result).toBe 1
					done();
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Update - изменение элемента $push', (done)->		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				collection.update {id: 18}, {$push: {tags: 122}}, {multi:true}, (err, result)->
					expect(result).toBe 1
					done();
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Update - изменение элемента $inc - инкремент', (done)->		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				collection.update {id: 18}, {$inc: {count: 1}}, {multi:true}, (err, result)->
					expect(result).toBe 1
					done();
					callback err
			(callback)->
				collection.update {id: 18}, {$inc: {count: 1}}, {multi:true}, (err, result)->
					expect(result).toBe 1
					done();
					callback err
			(callback)->
				collection.findOne {id:18}, (err, result)->
					expect( result.count ).toBe 2

					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()

	it 'Update - изменение элемента Upsert', (done)->		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				collection.update {id: -18}, {$set: {note: 'ss', title: 'LOOP', tags: [1,2,3,4]}}, {upsert:true},(err, result)->
					expect(result).toBe 1
					done();
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Создание индекса по полю note', (done)->		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				collection.ensureIndex {note: 1}, {unique: false, safe: true}, (err, result)->
					expect( result ).toBe 'note_1'
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Отбор элементов из базы, Больше 10 ($gt)', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.find({id: {$gt: 10}}).toArray (err, results)->
					expect( results.length ).toEqual 90
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Отбор элементов из базы, Меньше 10 ($lt)', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.find({id: {$lt: 10}}).toArray (err, results)->
					expect( results.length ).toEqual 10
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Отбор элементов из базы, не равно 10 ($ne)', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.find({id: {$ne: 10}}).toArray (err, results)->
					expect( results.length ).toEqual 152
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Отбор элементов из базы, содержат 1 в тегах ($in)', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.find({tags: {$in: [1]}}).toArray (err, results)->
					expect( results.length ).toEqual 3
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()


	it 'Отбор элементов из базы, содержат 1 в тегах ($all)', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				#считаем кол-во элементов в коллекции
				collection.find({$or:[{id: 18}, {id: 19}]}).toArray (err, results)->
					expect( results.length ).toEqual 2
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()

	it 'Отбор сегодняшних элементов из базы', (done)->
		
		async.series [
			async.apply mymongo.connect, 'test_insert'
			(callback)->
				#считаем кол-во элементов в коллекции
				d = new Date();
				collection.find( {time: {$gte: new Date(d.getFullYear(),d.getMonth(),d.getDate()), $lt: new Date(d.getFullYear(),d.getMonth(),d.getDate()+1) } } ).toArray (err, results)->
					expect( results.length ).toEqual 100
					done();
					callback err
		], (err, result)->
			expect( 1 ).toEqual 1
			mymongo.disconnect()
			done()







