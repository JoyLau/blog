---
title: 重剑无锋,大巧不工 SpringBoot --- 使用 Elasticsearch 进行更复杂的查询
date: 2017-11-16 08:56:55
description: "上一篇 SpringBoot 整合使用elasticsearch 只是实现了简单的增删改查，这在平时的生产应用中远远不够，这几天翻遍了 spring data elasticsearch 的文档和网上资料，总结了一下更复杂的查询操作，这篇文章进行更深层次的整合使用"
categories: [SpringBoot篇]
tags: [Spring,SpringBoot,Elasticsearch]
---

<!-- more -->

## 首先要说
java 操作 elasticsearch 有四种方式
1. 调用 elasticsearch 的 restapis 接口
2. 调用 java elasticsearch client 的接口
3. 整合 spring data 使用 ElasticsearchTemplate 封装的方法
4. 继承 ElasticsearchRepository 接口调用方法



里面具体的方法 我也小计一下

## ElasticSearchTemplate
一些很底层的方法，我们最常用的就是elasticsearchTemplate.queryForList(searchQuery, class);
而这里面最主要的就是构建searchQuery，一下总结几个最常用的searchQuery以备忘

### queryStringQuery
单字符串全文查询

``` java 
    /**
     * 单字符串模糊查询，默认排序。将从所有字段中查找包含传来的word分词后字符串的数据集
     */
    @RequestMapping("/singleWord")
    public Object singleTitle(String word, @PageableDefault Pageable pageable) {
        //使用queryStringQuery完成单字符串查询
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(queryStringQuery(word)).withPageable(pageable).build();
        return elasticsearchTemplate.queryForList(searchQuery, Post.class);
    }
```

我们修改一下排序方式，按照weight从大到小排序

``` java 
    /** 
     * 单字符串模糊查询，单字段排序。 
     */  
    @RequestMapping("/singleWord1")  
    public Object singlePost(String word, @PageableDefault(sort = "weight", direction = Sort.Direction.DESC) Pageable pageable) {  
        //使用queryStringQuery完成单字符串查询  
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(queryStringQuery(word)).withPageable(pageable).build();  
        return elasticsearchTemplate.queryForList(searchQuery, Post.class);  
    } 
```

### matchQuery
查询某个字段中模糊包含目标字符串，使用matchQuery

``` java 
    /** 
     * 单字段对某字符串模糊查询 
     */  
    @RequestMapping("/singleMatch")  
    public Object singleMatch(String content, Integer userId, @PageableDefault Pageable pageable) {  
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(matchQuery("content", content)).withPageable(pageable).build();  
        //SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(matchQuery("userId", userId)).withPageable(pageable).build();  
        return elasticsearchTemplate.queryForList(searchQuery, Post.class);  
    }
```

### PhraseMatch
PhraseMatch查询，短语匹配

``` java
    /** 
     * 单字段对某短语进行匹配查询，短语分词的顺序会影响结果 
     */  
    @RequestMapping("/singlePhraseMatch")  
    public Object singlePhraseMatch(String content, @PageableDefault Pageable pageable) {  
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(matchPhraseQuery("content", content)).withPageable(pageable).build();  
        return elasticsearchTemplate.queryForList(searchQuery, Post.class);  
    } 
```

### Term
这个是最严格的匹配，属于低级查询，不进行分词的，参考这篇文章 http://www.cnblogs.com/muniaofeiyu/p/5616316.html

``` java 
    /** 
     * term匹配，即不分词匹配，你传来什么值就会拿你传的值去做完全匹配 
     */  
    @RequestMapping("/singleTerm")  
    public Object singleTerm(Integer userId, @PageableDefault Pageable pageable) {  
        //不对传来的值分词，去找完全匹配的  
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(termQuery("userId", userId)).withPageable(pageable).build();  
        return elasticsearchTemplate.queryForList(searchQuery, Post.class);  
    }
```

### multi_match
多个字段匹配某字符串,如果我们希望title，content两个字段去匹配某个字符串，只要任何一个字段包括该字符串即可，就可以使用multimatch。

``` java 
    /** 
     * 多字段匹配 
     */  
    @RequestMapping("/multiMatch")  
    public Object singleUserId(String title, @PageableDefault(sort = "weight", direction = Sort.Direction.DESC) Pageable pageable) {  
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(multiMatchQuery(title, "title", "content")).withPageable(pageable).build();  
        return elasticsearchTemplate.queryForList(searchQuery, Post.class);  
    } 
```

### 完全包含查询
之前的查询中，当我们输入“我天”时，ES会把分词后所有包含“我”和“天”的都查询出来，如果我们希望必须是包含了两个字的才能被查询出来，那么我们就需要设置一下Operator。

``` java 
    /** 
     * 单字段包含所有输入 
     */  
    @RequestMapping("/contain")  
    public Object contain(String title) {  
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(matchQuery("title", title).operator(MatchQueryBuilder.Operator.AND)).build();  
        return elasticsearchTemplate.queryForList(searchQuery, Post.class);  
    } 
```

无论是matchQuery，multiMatchQuery，queryStringQuery等，都可以设置operator。默认为Or，设置为And后，就会把符合包含所有输入的才查出来。
如果是and的话，譬如用户输入了5个词，但包含了4个，也是显示不出来的。我们可以通过设置精度来控制。

``` java 
    /** 
     * 单字段包含所有输入(按比例包含) 
     */  
    @RequestMapping("/contain")  
    public Object contain(String title) {  
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(matchQuery("title", title).operator(MatchQueryBuilder.Operator.AND).minimumShouldMatch("75%")).build();  
        return elasticsearchTemplate.queryForList(searchQuery, Post.class);  
    } 
```

minimumShouldMatch可以用在match查询中，设置最少匹配了多少百分比的能查询出来。

### 合并查询
即boolQuery，可以设置多个条件的查询方式。它的作用是用来组合多个Query，有四种方式来组合，must，mustnot，filter，should。
must代表返回的文档必须满足must子句的条件，会参与计算分值；
filter代表返回的文档必须满足filter子句的条件，但不会参与计算分值；
should代表返回的文档可能满足should子句的条件，也可能不满足，有多个should时满足任何一个就可以，通过minimum_should_match设置至少满足几个。
mustnot代表必须不满足子句的条件。
譬如我想查询title包含“XXX”，且userId=“1”，且weight最好小于5的结果。那么就可以使用boolQuery来组合。

``` java
    /** 
     * 多字段合并查询 
     */  
    @RequestMapping("/bool")  
    public Object bool(String title, Integer userId, Integer weight) {  
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(boolQuery().must(termQuery("userId", userId))  
                .should(rangeQuery("weight").lt(weight)).must(matchQuery("title", title))).build();  
        return elasticsearchTemplate.queryForList(searchQuery, Post.class);  
    } 
```
详细点的看这篇 http://blog.csdn.net/dm_vincent/article/details/41743955
boolQuery使用场景非常广泛，应该是主要学习的知识之一。

### Query和Filter的区别
query和Filter都是QueryBuilder，也就是说在使用时，你把Filter的条件放到withQuery里也行，反过来也行。那么它们两个区别在哪？
查询在Query查询上下文和Filter过滤器上下文中，执行的操作是不一样的：
1、查询：是在使用query进行查询时的执行环境，比如使用search的时候。
在查询上下文中，查询会回答这个问题——“这个文档是否匹配这个查询，它的相关度高么？”
ES中索引的数据都会存储一个_score分值，分值越高就代表越匹配。即使lucene使用倒排索引，对于某个搜索的分值计算还是需要一定的时间消耗。
2、过滤器：在使用filter参数时候的执行环境，比如在bool查询中使用Must_not或者filter
在过滤器上下文中，查询会回答这个问题——“这个文档是否匹配？”
它不会去计算任何分值，也不会关心返回的排序问题，因此效率会高一点。
另外，经常使用过滤器，ES会自动的缓存过滤器的内容，这对于查询来说，会提高很多性能。


## ElasticsearchRepository
ElasticsearchRepository接口的方法有

``` java
    @NoRepositoryBean
    public interface ElasticsearchRepository<T, ID extends Serializable> extends ElasticsearchCrudRepository<T, ID> {
        <S extends T> S index(S var1);
    
        Iterable<T> search(QueryBuilder var1);
    
        FacetedPage<T> search(QueryBuilder var1, Pageable var2);
    
        FacetedPage<T> search(SearchQuery var1);
    
        Page<T> searchSimilar(T var1, String[] var2, Pageable var3);
    }
```

执行复杂查询最常用的就是 FacetedPage<T> search(SearchQuery var1); 这个方法了，需要的参数是 SearchQuery
主要是看QueryBuilder和SearchQuery两个参数，要完成一些特殊查询就主要看构建这两个参数。
我们先来看看它们之间的类关系
![image](http://img.blog.csdn.net/20170726163702583?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvdGlhbnlhbGVpeGlhb3d1/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

实际使用中，我们的主要任务就是构建NativeSearchQuery来完成一些复杂的查询的。

``` java
    public NativeSearchQuery(QueryBuilder query, QueryBuilder filter, List<SortBuilder> sorts, Field[] highlightFields) {  
            this.query = query;  
            this.filter = filter;  
            this.sorts = sorts;  
            this.highlightFields = highlightFields;  
        }  
```

我们可以看到要构建NativeSearchQuery，主要是需要几个构造参数

当然了，我们没必要实现所有的参数。
可以看出来，大概是需要QueryBuilder，filter，和排序的SortBuilder，和高亮的字段。
一般情况下，我们不是直接是new NativeSearchQuery，而是使用NativeSearchQueryBuilder。
通过NativeSearchQueryBuilder.withQuery(QueryBuilder1).withFilter(QueryBuilder2).withSort(SortBuilder1).withXXXX().build();这样的方式来完成NativeSearchQuery的构建。
从名字就能看出来，QueryBuilder主要用来构建查询条件、过滤条件，SortBuilder主要是构建排序。

很幸运的 ElasticsearchRepository 里的 SearchQuery 也就是上述描述的 temple 的 SearchQuery，2 者可以共用