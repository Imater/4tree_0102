"use strict"












sync_journal_example = {
  '8': {
    _tm: new Date().getTime()
    changes: [
      'title': { _tm: new Date().getTime() }
    ]
  }
}




syncApi = {
  sync_journal: {}
  gen: 1;
  jsGetGen: ()->
    @gen++
  #добавляет в журнал синхронизации дату изменения полей
  jsFindChangesForSync: (new_value, old_value)->
    mythis = @;
    @jsDeepEach new_value, (el, key)->
      old_el = mythis.jsGetByKeys(old_value, key)[ key[key.length-1] ]
      if !_.isEqual( el , old_el)
        console.info key, el, "?=", old_el, new_value._id
        mythis.jsAddToSyncJournal( new_value._id, key )
    @sync_journal
  jsAddToSyncJournal: ( _id, key )->
    now = new Date().getTime();
    gen = @jsGetGen();
    console.info "id = ", _id

    if !@sync_journal[ _id ]
      @sync_journal[ _id ] = { _tm: now, _gen: gen, changes: {} }
    else
      @sync_journal[ _id ]._tm = now;
      @sync_journal[ _id ]._gen = gen;
    json_key = key.join(".")
    to_push = { _tm: now, _gen: gen } 
    @sync_journal[ _id ].changes[json_key] = {} if !@sync_journal[ _id ].changes[json_key]
    @sync_journal[ _id ].changes[json_key] = to_push
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
}







describe "Service syncApi test", ->
  now = new Date(2014,2,23,17,31,1).getTime();
  it "Find changes 1", ->
    new_value = {
      _id: "1"
      title: "hi!"
      tags: [
        'tag1'
        'tag3'
      ]
      first_level: {second: {third: "i'm third"}}
      parent: 8
    }

    new_value2 = {
      _id: "1"
      title: "hi33"
      tags: [
        'tag1'
        'tag3'
      ]
      first_level: {second: {third: "i'm third"}}
      parent: 8
    }

    old_value = {
      _id: "1"
      title: "hello"
      tags: [
        'tag1'
        'tag2'
      ]
      first_level: {second: {third: "i'm third"}}
      parent: 8
    }

    sync_journal_element = {
      _id: "1"
      _tm: now
      changes: [
        {'title': { _tm: now }}
      ]
    }

    console.info JSON.stringify syncApi.jsFindChangesForSync(new_value, old_value)
    console.info JSON.stringify syncApi.jsFindChangesForSync(new_value2, new_value), null, "  "
    expect( true ).toBe true
