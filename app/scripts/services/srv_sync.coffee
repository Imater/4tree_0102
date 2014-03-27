angular.module("4treeApp").service 'syncApi', ['$translate','db_tree', '$q', '$http', 'oAuth2Api', ($translate, db_tree, $q, $http, oAuth2Api) ->
  autosync_on: false
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
      if !_.isEqual( el , old_el)
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
      @jsStartSync() if @autosync_on;
    , 5000
  jsHideSyncIndicator: _.debounce ()->
      $(".sync_indicator").removeClass('active')
    , 1000
  jsStartSync: ()->
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
  

]




