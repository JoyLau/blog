---
title: Elasticsearch 关键字自动补全的实现
date: 2018-08-13 11:01:12
description: 我们经常能看到在各大电商网站搜索关键字的时候,底下下拉框会补全你要搜索的商品,或者类似的商品,有时候甚至连错别字也能纠正过来,其实ElasticSearch也能实现这样的功能
categories: [大数据篇]
tags: [Elasticsearch]
---

<!-- more -->
### 背景
我们经常能看到在各大电商网站搜索关键字的时候,底下下拉框会补全你要搜索的商品,或者类似的商品,有时候甚至连错别字也能纠正过来,其实ElasticSearch也能实现这样的功能

### 创建索引
首先,能够被自动补全的需要设置索引类型为"completion",其次,还可以设置自动提示为中文分词

``` json
    {
      "settings": {
        "analysis": {
          "analyzer": {
            "ik": {
              "tokenizer": "ik_max_word"
            },
            "ngram_analyzer": {
              "tokenizer": "ngram_tokenizer"
            }
          },
          "tokenizer": {
            "ngram_tokenizer": {
              "type": "ngram",
              "min_gram": 1,
              "max_gram": 30,
              "token_chars": [
                "letter",
                "digit"
              ]
            }
          }
        }
      },
      "mappings": {
        "knowledge_info": {
          "properties": {
            "infoId": {
              "type": "string"
            },
            "infoTitle": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word",
              "fields": {
                "suggest": {
                  "max_input_length": 30,
                  "preserve_position_increments": false,
                  "type": "completion",
                  "preserve_separators": false,
                  "analyzer": "ik_max_word"
                },
                "wordCloud": {
                  "type": "string",
                  "analyzer": "ik_smart",
                  "fielddata":"true"
                }
              }
            },
            "infoKeywords": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word",
              "fields": {
                "suggest": {
                  "max_input_length": 30,
                  "preserve_position_increments": false,
                  "type": "completion",
                  "preserve_separators": false,
                  "analyzer": "ik_max_word"
                },
                "wordCloud": {
                  "type": "string",
                  "analyzer": "ik_smart",
                  "fielddata":"true"
                }
              }
            },
            "infoSummary": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word",
              "fields": {
                "suggest": {
                  "max_input_length": 30,
                  "preserve_position_increments": false,
                  "type": "completion",
                  "preserve_separators": false,
                  "analyzer": "ik_max_word"
                },
                "wordCloud": {
                  "type": "string",
                  "analyzer": "ik_smart",
                  "fielddata":"true"
                }
              }
            },
            "infoContent": {
              "type": "text",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word"
            },
            "propertyAuthor": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word"
            },
            "propertyIssueUnit": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word"
            },
            "propertyStandardCode": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word"
            },
            "propertyLiteratureCategory": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word"
            },
            "propertyLcCode": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word"
            },
            "propertyLiteratureCode": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word"
            },
            "data": {
              "type": "text"
            },
            "attachment.content": {
              "type": "text",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word"
            },
            "auditState": {
              "type": "string"
            },
            "infoType": {
              "type": "string"
            },
            "infoFileUrl": {
              "type": "string"
            },
            "infoFileName": {
              "type": "string",
              "search_analyzer": "ik_max_word",
              "analyzer": "ik_max_word",
              "fields": {
                "suggest": {
                  "max_input_length": 60,
                  "preserve_position_increments": false,
                  "type": "completion",
                  "preserve_separators": false,
                  "analyzer": "ik_max_word"
                }
              }
            },
            "createTime": {
              "type": "string"
            }
          }
        }
      }
    }
```

其中 elasticsearch 需要安装中文分词 ik 插件和附件处理插件 ingest-attachment

### Java API 调用

``` java
    /**
     * 自动完成提示
     * @param search search
     * @return MessageBody
     */
    public MessageBody autoCompleteKnowledgeInfo(KnowledgeSearch search) {
        //设置搜索建议
        CompletionSuggestionBuilder infoTitleSuggestion = new CompletionSuggestionBuilder("infoTitle.suggest")
                .text(search.getQuery())
                .size(6);
        CompletionSuggestionBuilder infoKeywordsSuggestion = new CompletionSuggestionBuilder("infoKeywords.suggest")
                .text(search.getQuery())
                .size(6);
        CompletionSuggestionBuilder infoSummarySuggestion = new CompletionSuggestionBuilder("infoSummary.suggest")
                .text(search.getQuery())
                .size(6);
        CompletionSuggestionBuilder infoFileNameSuggestion = new CompletionSuggestionBuilder("infoFileName.suggest")
                .text(search.getQuery())
                .size(6);
        SuggestBuilder suggestBuilder = new SuggestBuilder()
                .addSuggestion("标题", infoTitleSuggestion)
                .addSuggestion("关键字", infoKeywordsSuggestion)
                .addSuggestion("摘要", infoSummarySuggestion)
                .addSuggestion("附件",infoFileNameSuggestion);
        SearchRequestBuilder searchRequest = client.prepareSearch(ES_KNOWLEDGE_INDEX)
                .setFetchSource(false)
                .suggest(suggestBuilder);
        List<JSONObject> list = new ArrayList<>();

        //查询结果
        SearchResponse searchResponse = searchRequest.get();

        /*没查到结果*/
        if (searchResponse.getSuggest() == null) {
            return MessageBody.success(list);
        }
        searchResponse.getSuggest().forEach(entries -> {
            String name = entries.getName();
            for (Suggest.Suggestion.Entry<? extends Suggest.Suggestion.Entry.Option> entry : entries) {
                for (Suggest.Suggestion.Entry.Option option : entry.getOptions()) {
                    JSONObject object = new JSONObject();
                    object.put("name",name);
                    object.put("text",option.getText().string());
                    list.add(object);
                }
            }
        });
        return MessageBody.success(list);
    }
```


代码摘取自项目中的部分, 另外前端还可以配合自动完成的插件,最终来实现效果.