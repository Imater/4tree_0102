#webapp = require('server')
async = require('async')
_ = require('underscore')

describe 'Функции Async. ', ->
	it 'Водопад - функции выполняются одна за другой', ->
		async.waterfall [
			(callback)->
				setTimeout ()->
					callback null, "one.", "two."
				,1
			(arg1, arg2, callback) ->
				callback null, "three."+arg1+arg2
			(arg1, callback)->
			# arg1 now equals 'three'
				callback null, "FINISH."+arg1
		], (err, result)->
			expect(result).toEqual 'FINISH.three.one.two.'
			asyncSpecDone()
		asyncSpecWait()

	it 'Each - вызывает функцию для каждого аргумента', ->
		a = 0
		square = (num, callback)->
			a += num*num
			setTimeout (->
				callback null
			), 1000
		async.each [1..50], square, (err)->
		expect( a ).toBe 42925
		a = 0
		async.each [1..10], (el)->
			a += el
		expect( a ).toBe 55

	it 'parallel - выполняется параллельно', ->
		async.series {
			firstFunction: (callback)->
				setTimeout (->
					callback null, 'first_answer'
				), 2
			secondFunction: (callback)->
				setTimeout (->
					callback null, 'second_answer'
				), 1
		}, (err, results) ->
			expect( results.firstFunction ).toBe 'first_answer'
			expect( results.secondFunction ).toBe 'second_answer'
			asyncSpecDone()
		asyncSpecWait()

	it 'series - выполняется друг за другом', ->
		async.series {
			firstFunction: (callback)->
				setTimeout (->
					callback null, 'first_answer'
				), 1
			secondFunction: (callback)->
				setTimeout (->
					callback null, 'second_answer'
				), 1
		}, (err, results) ->
			expect( results.firstFunction ).toBe 'first_answer'
			expect( results.secondFunction ).toBe 'second_answer'
			asyncSpecDone()
		asyncSpecWait()

	it 'filter делает отбор значений, даже если функция отбора асинхронная', ->
		async.filter [1..10], (e, callback)->			
			setTimeout (->
				callback e >= 3
			), 1
		, (result)->
			expect(result).toEqual [3..10]
			asyncSpecDone()
		asyncSpecWait()

	it 'filterSeries делает отбор значений друг за другом', ->
		async.filterSeries [1..10], (e, callback)->			
			setTimeout (->
				callback e >= 3
			), 1
		, (result)->
			expect(result).toEqual [3..10]
			asyncSpecDone()
		asyncSpecWait()

	it 'map - функция подсчёта статистики, обходит элементы', ->
		async.map [1..64], (el, callback)->
			callback null, el
		, (err, result)->
			sum = 0;
			_.each result, (el)->
				sum += el
			expect( sum ).toBe 2080

	it 'reduce - сведение результатов полученных от map', ->
		async.reduce [1..100], 0, (memo, item, callback)->
			process.nextTick ()->
				callback null, memo + item
		, (err, result)->
			expect( result ).toBe 5050
			asyncSpecDone()
		asyncSpecWait()

	it 'detect - аналог find в Underscore, находит первый элемент', ->
		async.detect [0..10000], (el, callback)->
				setTimeout ()->
					callback el>50
				, Math.random()*100
		, (result, rrr)->
			expect( result ).toBeGreaterThan 50
			asyncSpecDone()
		asyncSpecWait()

	it 'sortBy - очень быстрая асинхронная сортировка', ->
		async.sortBy [100..1], (el, callback)->
			setTimeout(->
				callback null, el
			, Math.random()*1)
		, (err, result)->
			expect( result[1] ).toBe 2
			asyncSpecDone()
		asyncSpecWait()
			
	it 'some - любой первый попавшийся', ->
		async.some [1..150], (el, callback)->
			callback el == 10
		, (result)->
			expect(result).toBeTruthy()

	it 'every - любой первый попавшийся', ->
		async.every [1..150], (el, callback)->
			callback el > 0
		, (result)->
			expect(result).toBeTruthy()

	it 'concat - создание массива из всего, что подходит условию', ->
		async.concat [1..5], (el, callback)->
			callback null, el.toString()
		, (err, result)->
			expect(result[1]).toBe '2'

	it 'whilst - WHILE для функций, пока первая функция true', ->
		i = 0;
		async.whilst ()->
			i < 10
		, (callback)->
			i++;
			setTimeout callback, 1
		, (err)->
			expect(i).toBe 10
			asyncSpecDone()
		asyncSpecWait()

	it 'compose - составная функция a( b() )', ->
		add1 = (n, callback) ->
		  setTimeout (->
		    callback null, n + 1
		  ), 10
		mul3 = (n, callback) ->
		  setTimeout (->
		    callback null, n * 3
		  ), 10
		dev15 = (n, callback) ->
		    callback null, n*10
		add1mul3 = async.compose(dev15, mul3, add1)
		add1mul3 4, (err, result) ->
			expect(result).toBe 150

	it 'Memoize - кеширование очень медленных функций', ->
		slow_fn = (name, callback) ->
		  # do something
		  result = name
		  setTimeout ()->
		  	callback null, result
		  , 10

		fn = async.memoize(slow_fn)

		# fn can now be used as if it were slow_fn
		fn "some name", (err, result)->
			console.info result

		setTimeout ()->
			fn "some name2", (err, result)->
				console.info result
		,11
		setTimeout ()->
			fn "some name3", (err, result)->
				console.info result
		,15


		# callback

















