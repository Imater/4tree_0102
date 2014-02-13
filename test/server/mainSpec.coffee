webapp = require('server')
http = require('http')
#console.info JSON.stringify webapp


describe 'First Test', ->
	it 'test №1', ->

		options =
		  host: 'ya.ru'
		  port: 80
		  path: '/'

		request = http.get options, (response) ->
		  #console.log("Got response: " + response.statusCode)
		  #console.dir(response)  
		  response.on 'data', (chunk) -> 
		    console.log('body: ' + chunk)
		    asyncSpecDone()
		expect(true).toEqual true
		asyncSpecWait()
		request.on 'error', (error) ->
		  #console.log("Got error: " + error.message)


	

###	it "shows asynchronous test", ->
	  setTimeout (->
	    expect("second").toEqual "second"
	    asyncSpecDone()
	    return
	  ), 100
	  expect("first").toEqual "first"
	  asyncSpecWait()
	  return
###