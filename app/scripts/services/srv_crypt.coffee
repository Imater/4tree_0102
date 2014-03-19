angular.module("4treeApp").service 'cryptApi', ['$translate','db_tree', '$rootScope', ($translate, db_tree, $rootScope) ->
	constructor: () -> 
		console.time('start')
		@pass_salt = @sha3(db_tree.salt() + db_tree.pepper())
		@password = "990990";
		@pass = @sha3( @password + @pass_salt + @password + @pass_salt );
		#console.info @pass
		@reminder = 'ФИО'
		@methods = {
			0: 'AES'
			1: 'DES'
			2: 'TripleDES'
			3: 'Rabbit'
			4: 'RC4Drop'
		}
		console.timeEnd('start')
	encrypt: (text, type)->
		salt = @sha3( "_"+Math.random()*100000000 ).substr(0,5);
		encrypt_method = if @methods[type] then @methods[type] else 'AES'
		console.time('encrypt start '+encrypt_method);
		if CryptoJS[encrypt_method]
			encrypt = CryptoJS[encrypt_method].encrypt(text, @pass + salt).toString();
		else
			encrypt = text;
		answer = { 
			memo: @reminder
			data: encrypt
			method: encrypt_method,
			salt: salt
		}
		console.timeEnd('encrypt start '+encrypt_method);
		JSON.stringify answer;
	decrypt: (text)->
		errors = null;
		try
			text = JSON.parse text
		catch e
			errors = $translate('ENCRYPT.JSON_ERROR'); 
		
		if CryptoJS[text.method]
			answer = CryptoJS[text.method].decrypt(text.data, @pass + text.salt);
			errors = $translate('ENCRYPT.PASS_ERROR') if answer.sigBytes <= 0;
			answer = answer.toString(CryptoJS.enc.Utf8)
		{text: answer, err: errors}
	sha3: (value)->
		CryptoJS.SHA3(value, { outputLength: 512 }).toString()

]