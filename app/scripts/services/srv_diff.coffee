angular.module("4treeApp").service 'diffApi', ['db_tree', (db_tree) ->
  # a = old, b = new
  diff: (old, new_, time) ->
    delCheck = (op) ->
      if op.type is "put" and op.value is `undefined`
        op.type = "del"
        delete op.value
      op
    compare = (path, old, new_, time) ->
      changes = []
      if old isnt null and new_ isnt null and typeof old is "object" and !_.isDate(old)
        oldKeys = Object.keys(old)
        newKeys = Object.keys(new_)
        sameKeys = _.intersection(oldKeys, newKeys)
        sameKeys.forEach (k) ->
          childChanges = compare(path.concat(k), old[k], new_[k], time)
          changes = changes.concat(childChanges)
          return

        delKeys = _.difference(oldKeys, newKeys)
        delKeys.forEach (k) ->
          changes.push
            type: "del"
            key: path.concat(k)
            tm: time

          return

        newKeys_ = _.difference(newKeys, oldKeys)
        newKeys_.forEach (k) ->
          changes.push delCheck(
            type: "put"
            key: path.concat(k)
            value: new_[k]
            tm: time
          )
          return

      else if old isnt new_
        changes.push delCheck(
          type: "put"
          key: path
          value: new_
          tm: time
        )
      changes

    changes = []
    changes = changes.concat(compare([], old, new_, time))
    changes
  apply: (changes, target, modify) ->
    obj = undefined
    if modify
      obj = target
    else
      try
        obj = JSON.parse(JSON.stringify(target))
      catch err
        obj = `undefined`
    changes.forEach (ch) ->
      ptr = undefined
      keys = undefined
      len = undefined
      switch ch.type
        when "put"
          ptr = obj
          keys = ch.key
          len = keys.length
          if len
            keys.forEach (prop, i) ->
              ptr[prop] = {}  unless prop of ptr
              if i < len - 1
                ptr = ptr[prop]
              else
                ptr[prop] = ch.value
              return

          else
            obj = ch.value
        when "del"
          ptr = obj
          keys = ch.key
          len = keys.length
          if len
            keys.forEach (prop, i) ->
              ptr[prop] = {}  unless prop of ptr
              if i < len - 1
                ptr = ptr[prop]
              else
                delete ptr[prop]
              return

          else
            obj = null

    obj
  logJson: (title, data, compact)->
    time = new Date();
    hours = time.getHours();
    minutes = time.getMinutes();
    seconds = time.getSeconds();
    console.info '['+hours+':'+minutes+':'+seconds+'] '+title+' = '+ JSON.stringify(data, false, if !compact then '  ')
]