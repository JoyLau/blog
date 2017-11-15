---
title: FastJSON 还有这样的用法 涨姿势了
date: 2017-11-15 09:14:19
description: "用了很长时间段FastJSON，没想到还有JSONPath这样容易使用的方法"
categories: [工具类篇]
tags: [JSON]
---

<!-- more -->
### 介绍
JSONPath。这是一个很强大的功能，可以在java框架中当作对象查询语言（OQL）来使用

### 语法说明
| JSONPATH | 描述 |
|:-----|:-----|
| $	| 根对象，例如$.name |
| [num] | 	数组访问，其中num是数字，可以是负数。例如$[0].leader.departments[-1].name | 
| [num0,num1,num2...]	 | 数组多个元素访问，其中num是数字，可以是负数，返回数组中的多个元素。例如$[0,3,-2,5] | 
| [start:end]	 | 数组范围访问，其中start和end是开始小表和结束下标，可以是负数，返回数组中的多个元素。例如$[0:5] | 
| [start:end :step]	 | 数组范围访问，其中start和end是开始小表和结束下标，可以是负数；step是步长，返回数组中的多个元素。例如$[0:5:2] | 
| [?(key)]	 | 对象属性非空过滤，例如$.departs[?(name)] | 
| [key > 123]	 | 数值类型对象属性比较过滤，例如$.departs[id >= 123]，比较操作符支持=,!=,>,>=,<,<= | 
| [key = '123']	 | 字符串类型对象属性比较过滤，例如$.departs[name = '123']，比较操作符支持=,!=,>,>=,<,<= | 
| [key like 'aa%']	 | 字符串类型like过滤，例如$.departs[name like 'sz*']，通配符只支持% 支持not like |
| [key rlike 'regexpr']	 | 字符串类型正则匹配过滤，例如departs[name like 'aa(.)*']，正则语法为jdk的正则语法，支持not rlike |
| [key in ('v0', 'v1')]	 | IN过滤, 支持字符串和数值类型 例如: $.departs[name in ('wenshao','Yako')] $.departs[id not in (101,102)] |
| [key between 234 and 456]	 | BETWEEN过滤, 支持数值类型，支持not between 例如: $.departs[id between 101 and 201]$.departs[id not between 101 and 201]length() 或者 size()	数组长度。例如$.values.size() 支持类型java.util.Map和java.util.Collection和数组
| .	 | 属性访问，例如$.name | 
| .. | 	deepScan属性访问，例如$..name | 
| *	 | 对象的所有属性，例如$.leader.*  | 
| ['key']	 | 属性访问。例如$['name'] | 
| ['key0','key1']	 | 多个属性访问。例如$['id','name'] | 



### 语法示例
| JSONPath | 语义 |
|:-----|:-----|
| $	 | 根对象 |
| $[-1]	| 最后元素 |
| $[:-2] | 	第1个至倒数第2个 |
| $[1:]| 	第2个之后所有元素 |
| $[1,2,3]| 集合中1,2,3个元素 |

### java 示例
``` json
    { "store": {
        "book": [ 
          { "category": "reference",
            "author": "Nigel Rees",
            "title": "Sayings of the Century",
            "price": 8.95
          },
          { "category": "fiction",
            "author": "Evelyn Waugh",
            "title": "Sword of Honour",
            "price": 12.99,
            "isbn": "0-553-21311-3"
          }
        ],
        "bicycle": {
          "color": "red",
          "price": 19.95
        }
      }
    }
```

``` java
    private static void jsonPathTest() {
        JSONObject json = jsonTest();//调用自定义的jsonTest()方法获得json对象，生成上面的json
         
        //输出book[0]的author值
        String author = JsonPath.read(json, "$.store.book[0].author");
         
        //输出全部author的值，使用Iterator迭代
        List<String> authors = JsonPath.read(json, "$.store.book[*].author");
         
        //输出book[*]中category == 'reference'的book
        List<Object> books = JsonPath.read(json, "$.store.book[?(@.category == 'reference')]");               
         
        //输出book[*]中price>10的book
        List<Object> books = JsonPath.read(json, "$.store.book[?(@.price>10)]");
         
        //输出book[*]中含有isbn元素的book
        List<Object> books = JsonPath.read(json, "$.store.book[?(@.isbn)]");
         
        //输出该json中所有price的值
        List<Double> prices = JsonPath.read(json, "$..price");
         
        //可以提前编辑一个路径，并多次使用它
        JsonPath path = JsonPath.compile("$.store.book[*]"); 
        List<Object> books = path.read(json); 
    }
```