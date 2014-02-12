###
"use strict"
describe "Sync_test", ->

  jsEach = (elements, fn, name='')->
    _.each elements, (el, key)->
      if(!_.isObject(el)) 
        dot = if name then '.' else ''
        key = name + dot + key
        fn.call(this, el, key)
      else 
        dot = if name then '.' else ''
        name1 = name + dot + key;
        jsEach(el, fn, name1)


  jsGetByPoints = (obj, points, create_if_not_finded)->
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
  jsDryObjectBySyncJournal = (tree, journal)->
    console.info 'tree = ', tree  if log_show
    console.info 'journal = ', journal  if log_show
    console.info '--------------'  if log_show
    answer = [];
    _.each journal, (jr)->
      tree_by_id = tree[ 'n'+jr.id ]
      return 0 if !tree_by_id #если элемент не найден, то не надо его сушить
      element = { id: jr.id, _tm: jr.tm };
      _.each jr.changes, (change_field_name)->
        points = change_field_name.split('.');
        e = jsGetByPoints(element, change_field_name, 'create_if_not_finded')
        last_field_name = points[points.length-1];
        e[last_field_name] = jsGetByPoints(tree_by_id, change_field_name)[last_field_name];
        #e = jsGetByPoints(tree_by_id, change_field_name);
      answer.push element
    #console.info "ANSWER = ", answer
    answer



  jsAddToSyncJournal = (journal, new_element, old_element)->

    answer = {
      changes: []
    }

    jsEach new_element, (el, key)->
      spl = key.split(".")
      last_key = spl[spl.length-1]
      #console.info "el = ", key, el, jsGetByPoints(old_element, key)[last_key]
      if el != jsGetByPoints(old_element, key)[last_key]
        answer.tm = new Date()
        answer.type = 'update'
        answer.id = new_element.id;
        answer.table = '4tree'
        answer.changes.push key

    journal_exist = _.filter journal, (el)->
      el.id == answer.id

    journal_exist_last = _.max journal_exist, (el)->
      el.tm

    if journal_exist[0]
      journal_exist_last.changes = _.union(journal_exist_last.changes, answer.changes);
    else 
      journal.push answer

    console.info 'journal_exist = ', journal_exist_last.changes if journal_exist[0]
    journal



  log_show = true;

  #СИНХРОНИЗАЦИЯ

  sync_timer = new Date().getTime();

  #база данных
  tree_db = {
    'n123': {id: 123, title: 'Old title for id 123', parent_id: 11, share: { link: '' }, sex: [{id:1, title: 'how'},{id:2, title: 'asdasd'}] }
    'n200': {id: 200, title: 'Old title for id 200', parent_id: 1, share: { link: '4tree/link' }, sex: [{myid:'ups', mytitle: 'forhow'},{myid:'iop', mytitle: 'asdasd1'}]}
  }

  new_tree_db = jQuery.extend(true, {}, tree_db);


  el123 = new_tree_db['n123']

  el123.title = 'New title for id 123'
  el123.parent_id = 2
  el123.share.link = "http://4tree.ru/sx7"

  el200 = new_tree_db['n200']
  el200.parent_id = 188
  el200.share.link = 'upd//dd'

  #process.hrtime()

  #Клиент ведёт журнал изменений:
  sync_journal = [];
  sync_journal_old = [
    { 
    	type: 'update' # update, add, delete
    	tm: new Date(2014,1,11, 11,30)
    	changes: ['title', 'parent_id', 'share.link']
    	id: 123
    	table: '4tree'
    }
    { 
    	type: 'update'
    	tm: new Date(2014,1,11, 11,40)
    	changes: ['title']
    	id: 200
    	table: '4tree' 
    }
  ]

  sync_journal = jsAddToSyncJournal(sync_journal, tree_db['n200'], new_tree_db['n200']);
  
  sync_journal = jsAddToSyncJournal(sync_journal, tree_db['n123'], new_tree_db['n123']);

  very_new_tree_db = jQuery.extend(true, {}, new_tree_db);
  el200 = very_new_tree_db['n200']
  el200.title = 'VERY New title for id = 200'

  sync_journal = jsAddToSyncJournal(sync_journal, new_tree_db['n200'], very_new_tree_db['n200']);

  console.info "JOURNAL = ", JSON.stringify sync_journal if log_show;

  #Отсортировать журнал по времени изменения
  sync_journal = _.sortBy sync_journal, (el)->
   el.tm

  #Клиент хранит время последней синхронизации
  last_sync_time = new Date(2014,1,11, 10,30)


  #При синхронизации делаем отбор того, что отошлём на сервер
  sync_journal_TO_SERVER = _.filter sync_journal, (el)->
  	el.tm > last_sync_time



  #Подбираем все изменившиеся объекты (сушим, чтобы не отправлять лишнее)
  tree_db_TO_SERVER = jsDryObjectBySyncJournal(very_new_tree_db, sync_journal_TO_SERVER);





  #Выводим в консоль журнал изменений
  _.each sync_journal_TO_SERVER, (el)-> 
    console.info "sync_journal_TO_SERVER", JSON.stringify( el ) if log_show


  _.each tree_db_TO_SERVER, (el)-> 
    console.info "tree_db_TO_SERVER", JSON.stringify( el ) if log_show


  #Время выполения скрипта
  console.info 'sync_timer', sync_timer - new Date().getTime() if log_show



  it "Get 8 mart object fron date", ->    
    expect( true ).toEqual true 
###