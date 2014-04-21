angular.module("4treeApp").service 'syncApi', ['$translate','db_tree', '$q', '$http', 'oAuth2Api', 'diffApi', '$rootScope', '$timeout', '$socket', ($translate, db_tree, $q, $http, oAuth2Api, diffApi, $rootScope, $timeout, $socket) ->
  autosync_on: true
  sync_journal: {}
  last_sync_time: "не проводилась"
  gen: 1;
  jsGetGen: ()->
    @gen++
  #добавляет в журнал синхронизации дату изменения полей
  jsFindChangesForSync: (new_value, old_value)->
    #console.info "jsFindChanges", new_value, old_value;
    mythis = @;
    @jsDeepEach new_value, (el, key)->
      old_el = mythis.jsGetByKeys(old_value, key)[ key[key.length-1] ]
      if !_.isEqual( el , old_el) and key[0] and key[0][0]!="_"
        mythis.jsAddToSyncJournal( new_value._id, key )
        console.info new_value._id + " changed " + key.join(".");
    @sync_journal
  jsAddToSyncJournal: ( _id, key )->
    now = new Date().getTime();
    gen = @jsGetGen();

    if !@sync_journal[ _id ]
      @sync_journal[ _id ] = { _tm: now, _gen: gen, changes: {} }
    else
      @sync_journal[ _id ]._tm = now;
      @sync_journal[ _id ]._gen = gen;
    json_key = key.join(".")
    to_push = { _tm: now, _gen: gen } 
    @sync_journal[ _id ].changes[json_key] = {} if !@sync_journal[ _id ].changes[json_key]
    @sync_journal[ _id ].changes[json_key] = to_push
    @jsStartSyncInWhile()
  jsDeepEach: (elements, fn, name=[])->
    mythis = @;   
    _.each elements, (el, key)->
      if(!_.isObject(el) || !_.isArray(el)) 
        name1 = name.slice(0) #так делаю копию массива
        name1.push(key)
        fn.call(this, el, name1) if !( key[0] in ['$','+'])
      else 
        name1 = name.slice(0)
        name1.push(key)
        mythis.jsDeepEach(el, fn, name1)
  jsGetByKeys: (obj, keys, create_if_not_finded)->
    prev_obj = obj;
    _.each keys, (point,i)->
      prev_obj = obj;
      if (obj[point])
        obj = obj[point]
    prev_obj
  'jsStartSyncInWhile': _.debounce ()->
      console.info 'wait 5 sec...'
      @jsStartSync() if @autosync_on and Object.keys(@diff_journal).length;
    , 1000
  jsHideSyncIndicator: _.debounce ()->
      $(".sync_indicator").removeClass('active')
    , 1000
  jsStartSync: ()->
    @syncToServer().then ()->
      $rootScope.$emit 'sync_ended';
    return true;
    $(".sync_indicator").addClass('active')
    mythis = @
    to_send = {
      notes: []
      sync_journal: @sync_journal
    }
    _.each @sync_journal, (sync_one, key)->
      found = _.find db_tree._db.tree, (el)-> el._id == key
      console.info sync_one, key, found
      to_send.notes.push( found ) if found
    #console.info JSON.stringify to_send
    @jsPostSync(to_send).then ()->
      mythis.sync_journal = {}
      now = new moment()
      mythis.last_sync_time = now.format("HH:mm:ss")
      mythis.jsHideSyncIndicator()
  jsPostSync: (sync_data_to_send)->
      dfd = $q.defer();
      console.info oAuth2Api
      oAuth2Api.jsGetToken().then (token)->
        $http({
          url: '/api/v1/sync',
          method: "POST",
          isArray: true,
          params: {
              access_token: token
          }
          data: {
            sync_data_to_send: sync_data_to_send
          }
        }).then (result)->
          console.info "SYNC_RESULT = ", result
          dfd.resolve result.data

      dfd.promise;
  jsSyncJournalCount: ()->
    Object.keys(@sync_journal).length
  #######################
  diff_journal: {}
  sync_now: false;
  constructor: ()->
    mythis = @;
    $rootScope.$on 'jsFindAndSaveDiff', (event, db_name, new_value, old_value)->
      console.info 'watch', mythis.sync_now
      return if !old_value or !new_value or mythis.sync_now
      diffs = diffApi.diff( old_value, new_value, new Date().getTime() );
      _.each diffs, (diff)->
        if diff.key[0][0] != '_' and diff.key[diff.key.length-1][0] != '$' and diff.key[diff.key.length-1][0] != '_' and diff.key[0] != 'tm'
          key = diff.type+':'+diff.key.join('.');
          mythis.diff_journal[db_name] = {} if !mythis.diff_journal[db_name]
          mythis.diff_journal[db_name][old_value._id] = {} if !mythis.diff_journal[db_name][old_value._id]
          mythis.diff_journal[db_name][old_value._id][key] = diff
        return
      if diffs.length
        db_tree.refreshView(db_name, [old_value._id], new_value, old_value)
        mythis.jsStartSyncInWhile();
        #diffApi.logJson 'diff_journal', mythis.diff_journal
      db_tree.jsSaveElementToLocal(db_name, new_value).then ()->
        console.info 'saved_local';
  getLastSyncTime: ()->
    max_element = _.max db_tree._db.tree, (el)->
      if el.tm
        return new Date(el.tm)
      else 
        return 0
    max_element.tm
  dfd_sync: $q.defer();
  syncThrough: (transport, data)->
    mythis = @;
    mythis.dfd_sync = $q.defer();
    diffApi.logJson 'sending data through ['+transport+']', data;
    if transport == 'http'
      oAuth2Api.jsGetToken().then (token)->
        $http({
          url: '/api/v1/sync_db',
          method: "POST",
          isArray: true,
          params: {
              access_token: token
          }
          data: data
        }).then (result)->
          mythis.jsUpdateDb(result.data).then ()->
            mythis.dfd_sync.resolve result.data
    if transport == 'websocket'
      $socket.emit 'sync_data', data

    mythis.dfd_sync.promise;

  syncToServer: ()->
    dfd = $q.defer();
    mythis = @;

    new_elements = {};

    async.each db_tree.store_schema, (table_schema, callback)->
      db_name = table_schema.name;

      #Нахожу все новые элементы дерева
      found_elements = _.filter db_tree._db[db_name], (el, key)->
        el._new == true

      _.each found_elements, (found)->
        new_elements[db_name] = {} if !new_elements[db_name]
        new_elements[db_name][found._id] = found
      callback();
    , ()->
      console.timeEnd 'load_local'

      data = {
        diff_journal: mythis.diff_journal
        last_sync_time: mythis.getLastSyncTime()
        user_instance: $rootScope.$$childTail.set.user_instance
        user_id: $rootScope.$$childTail.set.user_id
        new_elements: new_elements
      }

      if $socket.is_online() and false
        mythis.syncThrough('websocket', data).then ()->
          console.info 'sync_socket_ended';
          dfd.resolve();
      else
        mythis.syncThrough('http', data).then ()->
          console.info 'sync_http_ended';
          dfd.resolve();


    dfd.promise;

  jsUpdateDb: (data)->
    dfd = $.Deferred();
    dfdArray = [];
    mythis = @;
    _.each data, (db_table, db_name)->
      dfdArray.push mythis.jsUpdateDbOne(db_table, db_name)
    $.when.apply(null, dfdArray).then ()->
      dfd.resolve();
    dfd.promise();
  jsUpdateDbOne: (db_table, db_name)->
    console.info "ONE = ", db_table
    new_data = db_table.new_data;
    sync_confirm_id = db_table.sync_confirm_id;
    console.info 'confirm = ', sync_confirm_id, 'new_data = ', new_data
    dfd = $.Deferred();
    mythis = @;
    mythis.sync_now = true;

    copyObject = (source, obj)->
      newObj = source;
      for key of obj
          newObj[key] = obj[key];
      return newObj;

    i_need_refresh = false;
    _.each new_data, (new_data_element)->
      found = _.find db_tree._db[db_name], (el, key)->
        el._id == new_data_element._id
      if found
        copyObject(found, new_data_element)
        #found.$$hashKey = 'sex'
        i_need_refresh = true
        console.info 'new = ', found;
      else 
        console.info 'need_to_create!', new_data_element
        db_tree._db[db_name].push new_data_element
        i_need_refresh = true
      return true
    _.each sync_confirm_id, (confirm_element)->
      found = _.find db_tree._db[db_name], (el, key)->
        el._id == confirm_element._id
      if found
        console.info 'confirm_times', found.tm, confirm_element.tm, mythis.sync_now;
        i_need_refresh = true;
        found.tm = confirm_element.tm;
        found._new = false;
        delete mythis.diff_journal[db_name][confirm_element._id] if mythis.diff_journal?[db_name]?[confirm_element._id]

    if i_need_refresh
      db_tree.refreshParentsIndex();
    dfd.resolve();
    #mythis.diff_journal = {}; #объекты обновлены, можно считать синхронизацию завершённой
    $timeout ()->
      mythis.sync_now = false;

    dfd.promise();

  

]




