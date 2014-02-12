angular.module("4treeApp").service 'syncApi', ['$translate','db_tree', ($translate, db_tree) ->
	constructor: () -> 
		@color = 'grey'
		@log_show = false;
		@sync_journal = [];
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