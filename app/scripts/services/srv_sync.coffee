angular.module("4treeApp").service 'syncApi', ['$translate','db_tree', ($translate, db_tree) ->
	constructor: () -> 
		@color = 'grey'
		@log_show = false;
		@sync_journal = [];

	asyncEach: (obj, obj_old, fn)->
		mythis = @
		async.forEach Object.keys(obj), (key, callback)->
			if _.isArray(obj[key])
				fn(obj, obj_old, key)
				obj_old[key] = "" if(!obj_old[key]) 
				mythis.asyncEach obj[key], obj_old[key], fn
			else if _.isObject(obj[key])
				fn(obj, obj_old, key)
				obj_old[key] = "" if(!obj_old[key]) 
				mythis.asyncEach obj[key], obj_old[key], fn
			else
				fn(obj, obj_old, key)
			callback null

	asyncMarkChanges: (obj_new, obj_old, sync_time)->
		need_update_element_time = false;
		@.asyncEach obj_new, obj_old, (el, el_old, key)->
			if key == 'v' and (!el_old or !_.isEqual( el[key] , el_old[key]))
				el['_t'] = sync_time
				need_update_element_time = true
		obj_new['_changetime'] = sync_time if need_update_element_time;				
		obj_new

	jsDeepCopy: (obj)->
		obj_copy = {};
		_.each obj, 


	setChangeTimes: (new_element, old_element)->
		mythis = @;
		@myEach new_element, (new_el, key_array)->
			old_el = mythis.getElementByKeysArray( old_element, _.initial(key_array) )
			if old_el.v and (new_el != old_el.v)
				console.info 'changed = ', new_el, key_array
				new_el_toset = mythis.getElementByKeysArray( new_element, _.initial(key_array) )
				console.info 'new_element_to_set', new_el_toset
				new_el_toset._t = new Date() #время изменения конкретного поля, которое изменилось
				new_element._t = new Date()  #время изменения всего элемента - чтобы заметка попала в синхронизацию
				new_element._synced = false
			
	# getElementByKeysArray( obj, ['title', 'help', 2, 'ups'])
	note: {
		title: {
			help: [
				{ups:undefined}
			]
		}
	}

	getElementByKeysArray: (element, keys_array)->
		answer = element;
		prev_answer = {};
		prev_key = "";
		_.each keys_array, (key, i)->
			if !_.isUndefined( answer[key] )
				prev_answer = answer;
				prev_key = key;
				answer = answer[key]
			else if _.isNumber(key)
				if _.isArray(prev_answer[prev_key])
					#console.info 'key ??????????????', key, prev_answer, prev_key
					new_el = {};
					new_el[key] = {};
					prev_answer[prev_key].push( new_el ) 
					#answer = prev_answer;
				else
					prev_answer[prev_key] = [] if !_.isArray(prev_answer[prev_key])
					answer = prev_answer;
			else if _.isString(key)
				if _.isArray(prev_answer[prev_key])
					#console.info 'key !!!!!!!!!!!!!!', key, prev_answer, prev_key
					new_el = {};
					new_el[key] = {};
					prev_answer[prev_key].push( new_el ) 
					#answer = prev_answer;
				else
					answer[key] = {}
					prev_answer = answer;
					prev_key = key;
					answer = answer[key]

		answer

	deepOmit: (sourceObj, callback, thisArg) ->
	  mythis = @;
	  destObj = undefined
	  i = undefined
	  shouldOmit = undefined
	  newValue = undefined
	  return `undefined`  if _.isUndefined(sourceObj)
	  callback = (if thisArg then _.bind(callback, thisArg) else callback)
	  if _.isPlainObject(sourceObj)
	    destObj = {}
	    _.forOwn sourceObj, (value, key) ->
	      newValue = mythis.deepOmit(value, callback)
	      shouldOmit = callback(newValue, key, sourceObj)
	      destObj[key] = newValue  unless shouldOmit
	      return

	  else if _.isArray(sourceObj)
	    destObj = []
	    i = 0
	    while i < sourceObj.length
	      newValue = mythis.deepOmit(sourceObj[i], callback)
	      shouldOmit = callback(newValue, i, sourceObj)
	      destObj.push newValue  unless shouldOmit
	      i++
	  else
	    return sourceObj
	  destObj

	deepOmit2: (sourceObj, callback, path = []) ->
	  mythis = @;
	  destObj = undefined
	  i = undefined
	  shouldOmit = undefined
	  newValue = undefined
	  return `undefined`  if _.isUndefined(sourceObj)
	  if _.isPlainObject(sourceObj)
	    destObj = {}
	    _.forOwn sourceObj, (value, key) ->
	      path2 = path.slice(0);
	      path2.push(value);
	      newValue = mythis.deepOmit2(value, callback, path2)
	      shouldOmit = callback(newValue, key, sourceObj, path2)
	      destObj[key] = newValue  unless shouldOmit
	      return

	  else if _.isArray(sourceObj)
	    destObj = []
	    i = 0
	    while i < sourceObj.length
	      path2 = path.slice(0);
	      path2.push(sourceObj[i])
	      newValue = mythis.deepOmit2(sourceObj[i], callback, path2)
	      shouldOmit = callback(newValue, i, sourceObj, path2)
	      destObj.push newValue  unless shouldOmit
	      i++
	  else
	    return sourceObj
	  destObj

	#рекурсивный обход элементов
	myEach: (elements, fn, name=[])->
	  mythis = @;		
	  _.each elements, (el, key)->
	    if(!_.isObject(el) || !_.isArray(el)) 
	      name1 = name.slice(0) #так делаю копию массива
	      name1.push(key)
	      fn.call(this, el, name1) if !( key[0] in ['$','_'])
	    else 
	      name1 = name.slice(0)
	      name1.push(key)
	      mythis.myEach(el, fn, name1)

	getChangedSinceTime: (last_sync_time)->
		changed = []
		_.each db_tree.db_tree, (el, key)->
			if el._t >= last_sync_time
				changed.push el
		this.getElementByKeysArray({}, ['title', 'help']);
		changed

	getChanged: (last_sync_time)->
		@myEach db_tree.db_tree, (el, key)->
			console.info key


	#рекурсивный обход элементов
	jsEach: (elements, fn, name='')->
	  mythis = @;		
	  _.each elements, (el, key)->
	    if(!_.isObject(el)) 
	      dot = if name then '.' else ''
	      key = name + dot + key
	      fn.call(this, el, key)
	    else 
	      dot = if name then '.' else ''
	      #dot = if _.isArray(el) then '*'
	      name1 = name + dot + key;
	      mythis.jsEach(el, fn, name1)
	#находит или создаёт вложенный обкект по пути "first.second.third"
	jsGetByPoints: (obj, points, create_if_not_finded)->
	  split_point = points.split(".");
	  prev_obj = obj;
	  _.each split_point, (point,i)->
	    prev_obj = obj;
	    if (!obj[point])
	      obj = obj[point] = {} if (create_if_not_finded)
	    else 
	      obj = obj[point]
	  prev_obj
  	#функция перебора высушенного журнала
	jsDryObjectBySyncJournal: ()->
	  tree = db_tree.db_tree;
	  mythis = this;
	  console.info 'tree = ', tree  if @log_show
	  console.info 'journal = ', mythis.sync_journal  if @log_show
	  console.info '--------------'  if @log_show
	  answer = [];
	  _.each mythis.sync_journal, (jr)->
	    tree_by_id = _.find tree, (el)->
	    	el['n'+jr.id]
	    tree_by_id = tree_by_id['n'+jr.id]
	    return 0 if !tree_by_id #если элемент не найден, то не надо его 	сушить
	    element = { id: jr.id, _tm: jr.tm };
	    _.each jr.changes, (change_field_name)->
	      points = change_field_name.key.split('.');
	      e = mythis.jsGetByPoints(element, change_field_name.key, 'create_if_not_finded')
	      last_field_name = points[points.length-1];
	      e[last_field_name] = mythis.jsGetByPoints( tree_by_id, change_field_name.key )[last_field_name];
	    answer.push element
	  console.info "ANSWER = ", answer if @log_show
	  answer
	jsUnion: (last_changes, changes)->
		#last_changes - то что уже есть
		#changes - то что нужно добавить
		_.each changes, (ch) ->
			finded = _.find last_changes, (el)->
				el.key == ch.key

			if finded
				finded.tm = ch.tm
			else
				last_changes.push( {key: ch.key, tm: ch.tm} )
			return

		last_changes
		#_.union(last_changes, changes)
  	#вычисляет изменения в объекте, если передать новый и старый
  	#и добавляет запись о изменившихся полях в журнал
	jsAddToSyncJournal: (new_element, old_element)->
	  mythis = @;
	  answer = {
	    changes: []
	  }
	  mythis.jsEach new_element, (el, key)->
	    spl = key.split(".")
	    last_key = spl[spl.length-1]
	    #console.info "el = ", key, el, jsGetByPoints(old_element, )[last_key]
	    if el != mythis.jsGetByPoints(old_element, key)[last_key] and last_key and last_key[0]!='_' and last_key[0]!='$'
	      answer.tm = new Date()
	      #answer.type = 'update'
	      answer.id = new_element.id;
	      #answer.table = '4tree'
	      answer.changes.push { key: key, tm: new Date() }
	      journal_exist = _.filter mythis.sync_journal, (el)->
	      	el.id == answer.id
	      journal_exist_last = _.max journal_exist, (el)->
	      	el.tm
	      if _.isObject journal_exist_last
	      	journal_exist_last.changes = mythis.jsUnion(journal_exist_last.changes, answer.changes);
	      	journal_exist_last.tm = new Date()
	      else 
	      	mythis.sync_journal.push answer
	  @sync_journal



]




