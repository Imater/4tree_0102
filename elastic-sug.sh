curl -X PUT localhost:9200/trees/tree/_mapping -d '{
  "tree" : {
        "properties" : {
            "title" : { "type" : "string" },
            "suggest" : { "type" : "completion",
                          "index_analyzer" : "simple",
                          "search_analyzer" : "simple",
                          "payloads" : true
            }
        }
    }
}'