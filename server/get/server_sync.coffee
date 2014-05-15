async = require('async');
mongoose = require('mongoose')
logJson = require('../../logJson/_js/logJson.js');
JSON_stringify = require '../../scripts/_js/JSON_stringify.js'
$ = require('jquery')
_ = require('underscore');
winston = require('winston')
MYLOG = require('../../scripts/_js/mylog.js').mylog

jsondiffpatch = require('jsondiffpatch').create {
  objectHash: (obj) ->
    # try to find an id property, otherwise serialize it all
    return obj.name || obj.id || obj._id || obj._id || JSON.stringify(obj);  
  textDiff: {
      minLength: 3
  }
}

require '../../models/_js/model_diff.js'

Diff = mongoose.model('Diff');
Text = mongoose.model('Text');

sync = {
  apply_patch: (args, dont_save_to_db)->
    dfd = $.Deferred()
    mythis = @;
    MYLOG.log 'sync', 'apply_patch: Применяю патч к базе '+args.diff.db_name, { patch: args.old_row, args: args }
    args.old_row = jsondiffpatch.patch( args.old_row, args.diff.patch)
    args.old_row._sha1 = JSON_stringify.JSON_stringify( args.old_row )._sha1
    MYLOG.log 'sync', 'apply_patch: После применения', args.old_row
    args.old_row._tm = new Date()
    args.old_row._diff = args.diff;
    #при этом сохранится бекап в базе diff
    args.old_row.save (err)-> 
      dfd.resolve(args);
    dfd.promise();
  combineDiffsByTime: (_id)->
    dfd = $.Deferred()
    Diff.find {'db_id':_id}, undefined, {sort: {tm:1}}, (err, rows)->
      if !rows[0]
        MYLOG.log 'sync', 'combineDiffsByTime: Нашёл в базе diff по id='+ _id, { rows }
      answer = rows[0].body;
      async.eachSeries rows, (dif, callback)->
        MYLOG.log 'sync', 'combineDiffsByTime: Раньше (нашёл в diff) body was = ', answer
        answer = jsondiffpatch.patch(answer, dif.patch)
        MYLOG.log 'sync', 'combineDiffsByTime: Применил патч, теперь body = ', { body: answer, patch: patch }
        answer._sha1 = JSON_stringify.JSON_stringify( answer )._sha1
        MYLOG.log 'sync', 'combineDiffsByTime: Применил патч, теперь _sha1 = ', { sha1: answer._sha1 }
        callback()
      , ()->
        dfd.resolve(answer);
    dfd.promise()
  combineAllDiffs: (req, res)->
    mythis = @;
    _id = req.query._id
    mythis.combineDiffsByTime(_id).then (combined)->
      res.send(combined);
    answer = {};
  Merge: (diff)->
    dfd = new $.Deferred();
    MYLOG.log 'sync', 'Merge: Начинаю мерджить diff (смотри diff.patch) = ', { diff }
    delta1 = diff.patch
    #Находим старый текст с такой же контрольной суммой
    Diff.findOne {_sha1: diff._sha1, db_id: diff._id}, undefined, (err, doc0)->
      doc0 = { new_body: diff._doc } if !doc0 and diff._doc
      if (doc0)
        MYLOG.log 'sync', 'Merge: Нашёл в базе diff', { new_body: doc0.new_body }
        doc1 = jsondiffpatch.patch( doc0.new_body, delta1)
        MYLOG.log 'sync', 'Merge: Применил diff.patch, теперь doc1 = ', { doc1 }
        global._db_models[diff.db_name].findOne { _id: diff._id }, undefined, (err, doc2)->
          MYLOG.log 'sync', 'Merge: Нашёл в базе данных '+diff.db_name+' doc2 = ', { doc2 }
          delta2 = jsondiffpatch.diff( doc0.new_body, doc2.toObject() )
          delta2['_sha1'] = undefined if delta2['_sha1']
          delta2['_tm'] = undefined if delta2['_tm']
          MYLOG.log 'sync', 'Merge: Применил к doc0.new_body '+diff.db_name+' doc2 = ', { delta2, doc0new_body: doc0.new_body, doc2: doc2.toObject() }
          doc3 = jsondiffpatch.patch( doc1, delta2 )
          doc3 = jsondiffpatch.patch( doc3, delta1 )
          main_diff = jsondiffpatch.diff(doc2.toObject(), doc3)
          MYLOG.log 'sync', 'Merge: Сгенерировал объединённый текст doc3 ', { doc1, doc2, doc3, delta1, delta2, main_diff }
          MYLOG.log 'sync', 'Merge: MAIN_DIFF теперь = ', { main_diff }
          doc2 = _.extend( doc2, doc3)
          MYLOG.log 'sync', 'Merge: Extend doc2 = _.extend( doc2, doc3) = ', { doc2 }
          doc2._diff = diff
          doc2._tm = new Date()
          doc2.save (err, doc)->
            MYLOG.log 'sync', 'Merge: Merged saved', { err, doc }
            dfd.resolve(doc);
      else
        MYLOG.log 'sync', 'Merge: В базе не нашёл с _sha1: '+diff._sha1+' возвращаю пустой элемент'
        dfd.resolve();
    dfd.promise();

}

exports.get2 = (req, res)->
  #sync.combineAllDiffs(req, res)
  global._db_models['tree'].findOne { _id: req.query._id }, undefined, (err, row)->
    answer = JSON_stringify.JSON_stringify( row )
    res.send(answer)


exports.get = (req, res)->
  MYLOG.profile 'Время исполнения синхронизации'
  exports.fullSyncUniversal(req, res).then (data_to_client)->
    res.send(data_to_client);
    MYLOG.profile 'Время исполнения синхронизации'

exports.fullSyncUniversal = (req, res)->
  dfd = new $.Deferred();
  diffs = req.body.diffs;
  new_db_elements = req.body.new_db_elements;
  user_id = req.body.user_id;
  last_sync_time = req.query.last_sync_time;
  machine = req.query.machine;

  confirm_count = 0;
  MYLOG.log 'sync', '---------------------------------------'+ (new Date().toString());
  MYLOG.log 'sync', 'Начинаю синхронизацию для machine='+machine, {diffs, new_db_elements, last_sync_time};


  sha1_sign = req.query.machine + JSON_stringify.JSON_stringify({diffs, new_db_elements})._sha1
  if sha1_sign != req.body.sha1_sign
    MYLOG.log 'sync', 'SHA1sign: Ошибка подписи http: '+req.body.sha1_sign+' != '+sha1_sign
    res.send();
  else
    send_to_client = {};
    async.series [
      #Обрабатываю все новые элементы
      (callback_main)->
        if new_db_elements
          MYLOG.log 'sync', 'NEW_DB_ELEMENTS: Начинаю обработку ', { new_db_elements }
          async.eachLimit Object.keys(new_db_elements), 50, (db_name, callback)->
            new_elements = new_db_elements[db_name];
            MYLOG.log 'sync', 'NEW_DB_ELEMENTS: Обрабатываю первый ', { new_elements }
            if new_elements
              async.eachLimit Object.keys(new_elements), 50, (doc_id, callback2)->
                doc = new_elements[doc_id]
                MYLOG.log 'sync', 'NEW_DB_ELEMENTS: Сейчас буду сохранять doc', {doc}
                DB_MODEL = global._db_models[db_name];
                doc._tm = new Date();
                db_model = new DB_MODEL(doc)
                MYLOG.log 'sync', 'NEW_DB_ELEMENTS: Документ подготовил ', {db_model}
                db_model.save (err, saved)->
                  console.info 'SAVED - ', err, saved
                  if saved
                    confirm_count++;
                    MYLOG.log 'sync', 'NEW_DB_ELEMENTS: Успешно сохранил в базу', { err, saved }
                  else
                    MYLOG.log 'sync', 'NEW_DB_ELEMENTS: Ошибка сохранения', { err }
                  if saved and false
                    send_to_client[db_name] = { confirm: {} } if !send_to_client[db_name]
                    send_to_client[db_name]['confirm'][saved._id] = { _sha1: saved._sha1, _tm: saved._tm }
                    MYLOG.log 'sync', 'NEW_DB_ELEMENTS: Добавил в список подтверждённых', { send_to_client }
                  callback2();
              , ()->
                MYLOG.log 'sync', 'NEW_DB_ELEMENTS: Новые Элементы обработаны', {new_elements}
                callback();
            else
              MYLOG.log 'sync', 'NEW_DB_ELEMENTS: Новые Элементы не обнаружены', {new_elements}
              callback();

          , ()->
            callback_main();
        else
          callback_main();
      #Обрабатываю все изменения
      (callback_main)->
        if diffs
          MYLOG.log 'sync', 'DIFFS: Начинаю обрабатывать изменения', { diffs }
          async.eachLimit Object.keys(diffs), 50, (diff_id, callback)->
            diff = diffs[diff_id];
            MYLOG.log 'sync', 'DIFFS: Одно из изменений!!!', { diff }

            global._db_models[diff.db_name].findOne {'_sha1':diff._sha1, '_id':diff._id}, undefined, (err, row)->
              if row
                MYLOG.log 'sync', 'DIFFS: 1. Нашёл элемент в основной базе', { row }

                sync.apply_patch({
                  old_row: row
                  diff: diff
                }).then (args)->
                  send_to_client[diff.db_name] = { confirm: {} } if !send_to_client[diff.db_name]
                  send_to_client[diff.db_name]['confirm'][args.old_row._id] = { _sha1: args.old_row._sha1, _tm: args.old_row._tm }
                  MYLOG.log 'sync', 'DIFFS: 1. Применил патч, получил ответ', {args, send_to_client}
                  confirm_count++;
                  callback()
              else
                #в основной базе нет, буду искать в диффах
                MYLOG.log 'sync', 'DIFFS: 2. В основоной базе нет, запускаю Merge...'
                if diff
                  sync.Merge(diff).then (doc)->
                    send_to_client[diff.db_name] = { confirm: {} } if !send_to_client[diff.db_name]
                    if doc
                      send_to_client[diff.db_name]['confirm'][doc._id] = { _sha1: doc._sha1, _tm: doc._tm, _doc: doc, merged: true }
                      confirm_count++;
                      MYLOG.log 'sync', 'DIFFS: 2. Merge применён, подтверждаю', {doc, send_to_client}
                      callback()
                    else
                      #Если не найден в дифах, попрошу клиента прислать ещё раз
                      send_to_client[diff.db_name].not_found = {} if !send_to_client[diff.db_name].not_found
                      send_to_client[diff.db_name].not_found[diff._id] = diff._sha1;
                      MYLOG.log 'sync', 'NOT FOUND IN DIFFS, NEED RESEND', diff._id;
                      callback()
                else
                  callback()

          , ()->
            MYLOG.log 'sync', 'NEW: Все дифы обработаны, пошли дальше. Сейчас будем искать изменившиеся элементы.'
            async.each Object.keys(global._db_models), (db_name, callback)->
              tm = new Date( JSON.parse(last_sync_time) ).toISOString();
              global._db_models[db_name].find { _tm: { $gt: tm } }, (err, docs)->
                if docs and docs.length
                  MYLOG.log 'sync', 'NEW: Нашли дела в '+db_name+' с датой больше '+tm, { err, docs }
                async.each docs, (doc, callback2)->
                  if (confirm = send_to_client?[db_name]?['confirm']?[ doc._id ])
                    MYLOG.log 'sync', 'NEW: В базе подтверждений такой элемент есть, значит мы его сейчас меняли', {confirm}
                    if confirm._sha1 != doc._sha1
                      MYLOG.log 'sync', 'NEW: Но confirm._sha1 не совпадает с базой', {confirm_sha1: confirm._sha1, doc: doc._sha1}
                      confirm._doc = doc
                      confirm.becouse_new = true
                  else
                    console.info 'EEEEE = ', { doc, send_to_client }, !(send_to_client[db_name] and send_to_client[db_name].not_found and send_to_client[db_name].not_found[doc._id])
                    if !(send_to_client[db_name] and send_to_client[db_name].not_found and send_to_client[db_name].not_found[doc._id])
                      #Если элемент найден в диффах, если нет, мы уже попросили клиента прислать данные целиком
                      MYLOG.log 'sync', 'NEW: Нашли НОВЫЙ элемент, будем отправлять клиенту', {doc}
                      send_to_client[db_name] = { confirm: {} } if !send_to_client[db_name]
                      send_to_client[db_name]['confirm'][doc._id] = { _sha1: doc._sha1, _tm: doc._tm, _doc: doc, just_new: true }
                      MYLOG.log 'sync', 'NEW: Нашли НОВЫЙ элемент, будем отправлять клиенту send_to_client[db_name][confirm][doc._id]', {send_to_client: send_to_client[db_name]['confirm'][doc._id]}
                    else
                      MYLOG.log 'sync', 'Не подтверждаю, так как нужен элемент целиком'
                  callback2();
                , (docs_filtered)->
                  callback();
            , ()->
              callback_main();
          #logJson 'send_to_client', send_to_client
    ], ()->
      send_to_client.server_time = new Date()
      send_to_client.confirm_count = confirm_count;
      dfd.resolve(send_to_client);

      if confirm_count > 0
        clients = global.io.sockets.clients('user_id:'+user_id)
        MYLOG.log 'sync', 'SOCKETS: Есть что подтверждать клиентам '+clients.length
        if clients
          async.each Object.keys(clients), (client_i, callback3)->
            client = clients[client_i]
            client.get 'nickname', (err, nickname)->
              nickname = JSON.parse(nickname)
              if nickname and nickname.machine != machine
                MYLOG.log 'sync', 'SOCKETS: Клиента '+nickname.machine+' попросили синхронизироваться', {client_i}
                client.emit('need_sync_now')
            callback3()
          ,()->
            MYLOG.log 'sync', 'SOCKETS: Всех клиентов оповестили';

      MYLOG.log 'sync', 'Синхронизация завершена', { send_to_client }

  dfd.promise();

















