angular.module("4treeApp").service 'syncApi', ['$translate', ($translate) ->
	constructor: () -> 
		@color = 'grey'
		@log_show = true;
		@sync_journal = [];
	#рекурсивный обход элементов
	jsEach: (elements, fn, name='')->
	  _.each elements, (el, key)->
	    if(!_.isObject(el)) 
	      dot = if name then '.' else ''
	      key = name + dot + key
	      fn.call(this, el, key)
	    else 
	      dot = if name then '.' else ''
	      name1 = name + dot + key;
	      @jsEach(el, fn, name1)
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
  	jsDryObjectBySyncJournal: (tree, journal) ->
  	  fn=this;
  	  console.info 'tree = ', tree  if @log_show
  	  console.info 'journal = ', journal  if @log_show
  	  console.info '--------------'  if @log_show
  	  answer = [];
  	  _.each journal, (jr)->
  	    tree_by_id = tree[ 'n'+jr.id ]
  	    return 0 if !tree_by_id #если элемент не найден, то не надо его 	сушить
  	    element = { id: jr.id, _tm: jr.tm };
  	    _.each jr.changes, (change_field_name)->
  	      points = change_field_name.split('.');
  	      e = fn.jsGetByPoints(element, change_field_name, '	create_if_not_finded')
  	      last_field_name = points[points.length-1];
  	      e[last_field_name] = @jsGetByPoints(tree_by_id, change_field_name	)[last_field_name];
  	    answer.push element
  	  answer
	  #вычисляет изменения в объекте, если передать новый и старый
	  #и добавляет запись о изменившихся полях в журнал
	jsAddToSyncJournal: (new_element, old_element)->
	  fn = @;
	  answer = {
	    changes: []
	  }
	  @jsEach new_element, (el, key)->
	    spl = key.split(".")
	    last_key = spl[spl.length-1]
	    #console.info "el = ", key, el, jsGetByPoints(old_element, )[last_key]
	    if el != fn.jsGetByPoints(old_element, key)[last_key]
	      answer.tm = new Date()
	      answer.type = 'update'
	      answer.id = new_element.id;
	      answer.table = '4tree'
	      answer.changes.push key
	  journal_exist = _.filter @sync_journal, (el)->
	    el.id == answer.id
	  journal_exist_last = _.max journal_exist, (el)->
	    el.tm
	  if journal_exist_last.length
	    journal_exist_last.changes = _.union(journal_exist_last.changes, answer.changes);
	  else 
	    @sync_journal.push answer
	  console.info 'journal_exist = ', @sync_journal
	  @sync_journal



]