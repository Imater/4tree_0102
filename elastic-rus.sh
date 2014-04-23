curl -XPOST 'localhost:9200/trees/_close'
curl -XPOST 'localhost:9200/tasks/_close'

curl -XDELETE 'localhost:9200/trees'
curl -XDELETE 'localhost:9200/tasks'

curl -XPUT 'localhost:9200/trees' -d '{
   "index": 
    { "number_of_shards": 11,
      "analysis": {
         "filter": {
                    "mynGram" : {"type": "nGram", "min_gram": 2, "max_gram": 10},
                    "my_stopwords": {
                      "type": "stop",
                      "stopwords": "а,без,более,бы,был,была,были,было,быть,в,вам,вас,весь,во,вот,все,всего,всех,вы,где,да,даже,для,до,его,ее,если,есть,еще,же,за,здесь,и,из,или,им,их,к,как,ко,когда,кто,ли,либо,мне,может,мы,на,надо,наш,не,него,нее,нет,ни,них,но,ну,о,об,однако,он,она,они,оно,от,очень,по,под,при,с,со,так,также,такой,там,те,тем,то,того,тоже,той,только,том,ты,у,уже,хотя,чего,чей,чем,что,чтобы,чье,чья,эта,эти,это,я,a,an,and,are,as,at,be,but,by,for,if,in,into,is,it,no,not,of,on,or,such,that,the,their,then,there,these,they,this,to,was,will,with"
                    }
                   },
         "analyzer": { "a1" : {
                      "type":"custom",
                      "tokenizer": "standard",
                      "filter": ["lowercase", "mynGram"]
                      }
                    } 
       }
    }
  }
}'

curl -XPUT 'localhost:9200/tasks' -d '{
   "index": 
    { "number_of_shards": 11,
      "analysis": {
         "filter": {
                    "mynGram" : {"type": "nGram", "min_gram": 2, "max_gram": 10},
                    "my_stopwords": {
                      "type": "stop",
                      "stopwords": "а,без,более,бы,был,была,были,было,быть,в,вам,вас,весь,во,вот,все,всего,всех,вы,где,да,даже,для,до,его,ее,если,есть,еще,же,за,здесь,и,из,или,им,их,к,как,ко,когда,кто,ли,либо,мне,может,мы,на,надо,наш,не,него,нее,нет,ни,них,но,ну,о,об,однако,он,она,они,оно,от,очень,по,под,при,с,со,так,также,такой,там,те,тем,то,того,тоже,той,только,том,ты,у,уже,хотя,чего,чей,чем,что,чтобы,чье,чья,эта,эти,это,я,a,an,and,are,as,at,be,but,by,for,if,in,into,is,it,no,not,of,on,or,such,that,the,their,then,there,these,they,this,to,was,will,with"
                    }
                   },
         "analyzer": { "a1" : {
                      "type":"custom",
                      "tokenizer": "standard",
                      "filter": ["lowercase", "mynGram"]
                      }
                    } 
       }
    }
  }
}'

curl -XPUT 'localhost:9200/trees/tree/_mapping' -d '{
    "tree" : {
      properties: {
        title: {
          "index_analyzer" : "a1",
          "search_analyzer" : "standard",
          "type": "string",
          "index_options" : "offsets"
        },
        text: {
          "index_analyzer" : "a1",
          "search_analyzer" : "standard",
          "type": "string",
          "index_options" : "offsets"
        }
      }
    }}'
curl -XPUT 'localhost:9200/tasks/task/_mapping' -d '{
    "task" : {
      properties: {
        title: {
          "index_analyzer" : "a1",
          "search_analyzer" : "standard",
          "type": "string",
          "index_options" : "offsets"
        },
        text: {
          "index_analyzer" : "a1",
          "search_analyzer" : "standard",
          "type": "string",
          "index_options" : "offsets"
        }
      }
    }}'

curl -XPOST 'localhost:9200/trees/_open'
curl -XPOST 'localhost:9200/tasks/_open'


##, 