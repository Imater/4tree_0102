# Синхронизация

# user ->
#
# book -> table -> [d]


_g = 1; #поколение
_sync_g = 8; #поколение успешной синхронизации

d = {
  _id: ObjectId('4445445446')
  title: 'Привет'
  parent: 8
  tags: [
    { _id: ObjectId('4445445446'), title: 'Новости' }
    { _id: ObjectId('4445445448'), title: 'АСЭТД' }
  ]
  comments: [
    { _id: ObjectId('4445445449'), text: "Hello frend!"}
    { _id: ObjectId('4445445410'), text: "Hi!"}
  ]
  sync: {
    '_last': {_g: 1, tm: 2233244} #всегда максимальные значения
    'title': {_g: 1, tm: 2233244}
    'parent': {_g: 5, tm: 4546464}
    'tags': {_g: 2, tm: 5844644}
    'comments.4445445449.text': {_g: 3, tm: 4797797}
    'comments.4445445410.text': {_g: 4, tm: 7788877}
  }

}



sync = {
  insert_gen: 1       #номер поколения
  update_gen: 1       #номер поколения изменения
  delete_gen: 1       #номер поколения удаления
  tm: 4323            #время изменения
  server_tm: 5547     #время синхронизации от сервера (означает, что синхронизация проведена)
}