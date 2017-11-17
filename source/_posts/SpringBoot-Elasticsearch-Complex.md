---
title: 重剑无锋,大巧不工 SpringBoot --- 使用 Elasticsearch 进行更复杂的查询
date: 2017-11-16 08:56:55
description: "上一篇 SpringBoot 整合使用elasticsearch 只是实现了简单的增删改查，这在平时的生产应用中远远不够，这几天翻遍了 spring data elasticsearch 的文档和网上资料，花了一篇大的功夫总结了一下更复杂的查询操作，这篇文章进行更深层次的整合使用"
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

## 测试准备
我们先来准备一些数据,写了一个之前的获取JoyMusic 的音乐数据的项目来说,项目的结构是这样的:
![elasticsearch-test-project](http://image.joylau.cn/blog/elasticsearch-test-project.png)
获取数据的主要代码如下,只是为了增加数据

``` java 
    @RunWith(SpringJUnit4ClassRunner.class)
    @SpringBootTest(classes = JoylauElasticsearchApplication.class,webEnvironment = SpringBootTest.WebEnvironment.MOCK)
    public class JoylauElasticsearchApplicationTests {
    	@Autowired
    	private RestTemplate restTemplate;
    
    	@Autowired
    	private PlaylistDAO playlistDAO;
    
    	@Autowired
    	private SongDAO songDAO;
    
    	@Autowired
    	private CommentDAO commentDAO;
    	@Test
    	public void createData() {
    		String personalizeds = restTemplate.getForObject("http://localhost:3003/apis/v1"+"/personalized",String.class);
    		JSONObject perJSON = JSONObject.parseObject(personalizeds);
    		JSONArray perArr = perJSON.getJSONArray("result");
    		List<Playlist> list = new ArrayList<>();
    		List<Integer> playListIds = new ArrayList<>();
    		for (Object o : perArr) {
    			JSONObject playListJSON = JSONObject.parseObject(o.toString());
    			Playlist playlist = new Playlist();
    			playlist.setId(playListJSON.getIntValue("id"));
    			playListIds.add(playlist.getId());
    			playlist.setName(playListJSON.getString("name"));
    			playlist.setPicURL(playListJSON.getString("picUrl"));
    			playlist.setPlayCount(playListJSON.getIntValue("playCount"));
    			playlist.setBookCount(playListJSON.getIntValue("bookCount"));
    			playlist.setTrackCount(playListJSON.getIntValue("trackCount"));
    			list.add(playlist);
    		}
    		playlistDAO.saveAll(list);
    
    
    
    		/*存储歌曲*/
    		List<Integer> songIds = new ArrayList<>();
    		List<Song> songList = new ArrayList<>();
    		for (Integer playListId : playListIds) {
    			String res = restTemplate.getForObject("http://localhost:3003/apis/v1"+"/playlist/detail?id="+playListId,String.class);
    			JSONArray songJSONArr = JSONObject.parseObject(res).getJSONObject("playlist").getJSONArray("tracks");
    			for (Object o : songJSONArr) {
    				JSONObject songJSON = JSONObject.parseObject(o.toString());
    				Song song = new Song();
    				song.setId(songJSON.getIntValue("id"));
    				songIds.add(song.getId());
    				song.setName(songJSON.getString("name"));
    				song.setAuthor(getSongAuthor(songJSON.getJSONArray("ar")));
    				song.setTime(songJSON.getLong("dt"));
    				song.setPlaylistId(playListId);
    				song.setPicURL(songJSON.getJSONObject("al").getString("picUrl"));
    				song.setAlbum(songJSON.getJSONObject("al").getString("name"));
    				songList.add(song);
    			}
    		}
    		songDAO.saveAll(songList);
    
    
    
    		/*存储评论*/
    		List<Comment> commentList = new ArrayList<>();
    		for (Integer songId : songIds) {
    			String res = restTemplate.getForObject("http://localhost:3003/apis/v1"+"/comment/music?id="+songId+"&offset="+300,String.class);
    			JSONArray commentArr = JSONObject.parseObject(res).getJSONArray("comments");
    			for (Object o : commentArr) {
    				JSONObject commentJSON = JSONObject.parseObject(o.toString());
    				Comment comment = new Comment();
    				comment.setId(commentJSON.getIntValue("commentId"));
    				comment.setSongId(songId);
    				comment.setContent(commentJSON.getString("content"));
    				comment.setAuthor(commentJSON.getJSONObject("user").getString("nickname"));
    				comment.setPicUrl(commentJSON.getJSONObject("user").getString("avatarUrl"));
    				comment.setTime(commentJSON.getLong("time"));
    				comment.setSupport(commentJSON.getIntValue("likedCount"));
    				commentList.add(comment);
    			}
    
    		}
    
    		commentDAO.saveAll(commentList);
    	}
    
    	/**
    	 * 获取歌曲作者名
    	 * @param arr arr
    	 * @return String
    	 */
    	private String getSongAuthor(JSONArray arr){
    		StringBuilder author = new StringBuilder();
    		for (Object o : arr) {
    			JSONObject json = JSONObject.parseObject(o.toString());
    			author.append(json.getString("name"));
    			if (arr.size() > 1){
    				author.append(",");
    			}
    		}
    		return author.toString();
    	}
    }

```

跑了起来之后, elasticsearch 增加的数据如下:
![elasticsearch-test-guide](http://image.joylau.cn/blog/elasticsearch-test-guide.png)
![elasticsearch-test-data](http://image.joylau.cn/blog/elasticsearch-test-data.png)

现在数据有了,接下来就是使用各种方法了

## ElasticSearchTemplate 和 ElasticsearchRepository 的关系
ElasticSearchTemplate 是 spring date 对 elasticsearch 客户端 Java API 的封装,而 ElasticsearchRepository,是ElasticSearchTemplate更深层次的封装,可以使用注解,很类似以前 mybatis 的使用
ElasticSearchTemplate提供的方法更多,ElasticsearchRepository能用的方法其实全部都在而 ElasticSearchTemplate 都有实现
我们只要能熟悉调用的 ElasticSearchTemplate 里面的方法操作
ElasticsearchRepository都能够会操作

## ElasticSearchTemplate
一些很底层的方法，我们最常用的就是elasticsearchTemplate.queryForList(searchQuery, class);
而这里面最主要的就是构建searchQuery，一下总结几个最常用的searchQuery以备忘
searchQuery能构建好,其他的就很简单了

### queryStringQuery
单字符串全文查询

``` java 
    /**
     * 单字符串模糊查询，默认排序。将从所有字段中查找包含传来的word分词后字符串的数据集
     */
    @Test
    public void queryStringQuerySong(){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(queryStringQuery("Time")).withPageable(of(0,100)).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
    }
```

返回的结果如下

``` text
    {
      "query_string" : {
        "query" : "Time",
        "fields" : [ ],
        "use_dis_max" : true,
        "tie_breaker" : 0.0,
        "default_operator" : "or",
        "auto_generate_phrase_queries" : false,
        "max_determinized_states" : 10000,
        "enable_position_increments" : true,
        "fuzziness" : "AUTO",
        "fuzzy_prefix_length" : 0,
        "fuzzy_max_expansions" : 50,
        "phrase_slop" : 0,
        "escape" : false,
        "split_on_whitespace" : true,
        "boost" : 1.0
      }
    }
    {"album":"Time","author":"Cat naps","id":459733590,"name":"Time","picURL":"http://p1.music.126.net/9DmApLeDwutb4HpuhD_E-Q==/18624627464667106.jpg","playlistId":900228548,"time":86465}
    {"album":"Go Time","author":"Mark Petrie","id":29717271,"name":"Go Time","picURL":"http://p1.music.126.net/TJe468hZr_0ndQRfTAKdqA==/3233663697760186.jpg","playlistId":636015704,"time":136071}
    {"album":"Out of Time","author":"R.E.M.","id":20282663,"name":"Losing My Religion","picURL":"http://p1.music.126.net/wYtpqN8Yu2jamQwdM6ugGg==/6638851209090428.jpg","playlistId":772430182,"time":269270}
    {"album":"Time Flies... 1994-2009","author":"Oasis","id":17822660,"name":"Cigarettes & Alcohol","picURL":"http://p1.music.126.net/qDgXElJRtSsuqNwsTzW8lw==/667403558069001.jpg","playlistId":772430182,"time":291853}
    {"album":"Electric Warrior","author":"T. Rex","id":29848501,"name":"There Was A Time","picURL":"http://p1.music.126.net/dn1MwEBfBcL4l6isrnEwDw==/3246857839528733.jpg","playlistId":772430182,"time":60577}
    {"album":"Ride On Time","author":"山下達郎","id":22693846,"name":"DAYDREAM","picURL":"http://p1.music.126.net/GaQVveQiyTIqecs7hhoYpA==/749866930165154.jpg","playlistId":900228548,"time":273476}
    {"album":"The Blossom Chronicles","author":"Philter","id":21375446,"name":"Adventure Time","picURL":"http://p1.music.126.net/YjMS5_kM3u9PCUU0lcRK8g==/6657542907248762.jpg","playlistId":636015704,"time":207412}
    {"album":"Decimus","author":"Audio Machine","id":36586631,"name":"Ashes of Time","picURL":"http://p1.music.126.net/7InBepjNDGCzpzH8Feyw9A==/3395291908535260.jpg","playlistId":636015704,"time":190826}
    {"album":"In Time: The Best Of R.E.M. 1988-2003","author":"R.E.M.","id":20283068,"name":"Bad Day","picURL":"http://p1.music.126.net/aZXu5ulRJvH4dnoWPjxb3A==/18277181789089107.jpg","playlistId":772430182,"time":248111}
    {"album":"It's a Poppin' Time","author":"山下達郎","id":22693864,"name":"HEY THERE LONELY GIRL","picURL":"http://p1.music.126.net/PGZlyXk20_-5d6E3pDEKpg==/815837627833461.jpg","playlistId":900228548,"time":325956}
    {"album":"Shire Music Annual Selection - Myth","author":"Shire Music,Songs To Your Eyes,","id":34916751,"name":"Between Space And Time","picURL":"http://p1.music.126.net/CCqLd2ly2XuuSPz0IW0u-g==/3284241233077333.jpg","playlistId":636015704,"time":222456}
    {"album":"Double Live Doggie Style I","author":"X-Ray Dog","id":26246058,"name":"Time Will Tell","picURL":"http://p1.music.126.net/oYEIMWnAvpuRDTk4g_l-lg==/2503587976473913.jpg","playlistId":636015704,"time":202133}
    {"album":"The Ghost Of Tom Joad","author":"Bruce Springsteen","id":16657852,"name":"Straight Time (Album Version)","picURL":"http://p1.music.126.net/yK0V-aD3Myh4xorvwUtCrw==/17889054184179160.jpg","playlistId":772430182,"time":210651}
    {"album":"Epic Action & Adventure Vol. 6","author":"Epic Score","id":4054121,"name":"Time Will Remember Us","picURL":"http://p1.music.126.net/uN8AYI3sQEgoECuSYmi9Eg==/658607465082090.jpg","playlistId":636015704,"time":165000}

```

我们修改一下排序方式，按照id从大到小排序

``` java 
    /** 
     * 单字符串模糊查询，单字段排序。 
     */  
    @Test
    public void queryStringQueryWeightSong(){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(queryStringQuery("Time")).withPageable(of(0,100,new Sort(Sort.Direction.DESC,"id"))).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
    }
```

也可以使用注解,这么写

``` java
    public void queryStringQueryWeightSong(@PageableDefault(sort = "id", direction = Sort.Direction.DESC) Pageable pageable){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(queryStringQuery("Time")).withPageable(pageable).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
    }
```

返回的结果

``` text
    {
      "query_string" : {
        "query" : "Time",
        "fields" : [ ],
        "use_dis_max" : true,
        "tie_breaker" : 0.0,
        "default_operator" : "or",
        "auto_generate_phrase_queries" : false,
        "max_determinized_states" : 10000,
        "enable_position_increments" : true,
        "fuzziness" : "AUTO",
        "fuzzy_prefix_length" : 0,
        "fuzzy_max_expansions" : 50,
        "phrase_slop" : 0,
        "escape" : false,
        "split_on_whitespace" : true,
        "boost" : 1.0
      }
    }
    {"album":"Time","author":"Cat naps","id":459733590,"name":"Time","picURL":"http://p1.music.126.net/9DmApLeDwutb4HpuhD_E-Q==/18624627464667106.jpg","playlistId":900228548,"time":86465}
    {"album":"Decimus","author":"Audio Machine","id":36586631,"name":"Ashes of Time","picURL":"http://p1.music.126.net/7InBepjNDGCzpzH8Feyw9A==/3395291908535260.jpg","playlistId":636015704,"time":190826}
    {"album":"Shire Music Annual Selection - Myth","author":"Shire Music,Songs To Your Eyes,","id":34916751,"name":"Between Space And Time","picURL":"http://p1.music.126.net/CCqLd2ly2XuuSPz0IW0u-g==/3284241233077333.jpg","playlistId":636015704,"time":222456}
    {"album":"Electric Warrior","author":"T. Rex","id":29848501,"name":"There Was A Time","picURL":"http://p1.music.126.net/dn1MwEBfBcL4l6isrnEwDw==/3246857839528733.jpg","playlistId":772430182,"time":60577}
    {"album":"Go Time","author":"Mark Petrie","id":29717271,"name":"Go Time","picURL":"http://p1.music.126.net/TJe468hZr_0ndQRfTAKdqA==/3233663697760186.jpg","playlistId":636015704,"time":136071}
    {"album":"Double Live Doggie Style I","author":"X-Ray Dog","id":26246058,"name":"Time Will Tell","picURL":"http://p1.music.126.net/oYEIMWnAvpuRDTk4g_l-lg==/2503587976473913.jpg","playlistId":636015704,"time":202133}
    {"album":"It's a Poppin' Time","author":"山下達郎","id":22693864,"name":"HEY THERE LONELY GIRL","picURL":"http://p1.music.126.net/PGZlyXk20_-5d6E3pDEKpg==/815837627833461.jpg","playlistId":900228548,"time":325956}
    {"album":"Ride On Time","author":"山下達郎","id":22693846,"name":"DAYDREAM","picURL":"http://p1.music.126.net/GaQVveQiyTIqecs7hhoYpA==/749866930165154.jpg","playlistId":900228548,"time":273476}
    {"album":"The Blossom Chronicles","author":"Philter","id":21375446,"name":"Adventure Time","picURL":"http://p1.music.126.net/YjMS5_kM3u9PCUU0lcRK8g==/6657542907248762.jpg","playlistId":636015704,"time":207412}
    {"album":"In Time: The Best Of R.E.M. 1988-2003","author":"R.E.M.","id":20283068,"name":"Bad Day","picURL":"http://p1.music.126.net/aZXu5ulRJvH4dnoWPjxb3A==/18277181789089107.jpg","playlistId":772430182,"time":248111}
    {"album":"Out of Time","author":"R.E.M.","id":20282663,"name":"Losing My Religion","picURL":"http://p1.music.126.net/wYtpqN8Yu2jamQwdM6ugGg==/6638851209090428.jpg","playlistId":772430182,"time":269270}
    {"album":"Time Flies... 1994-2009","author":"Oasis","id":17822660,"name":"Cigarettes & Alcohol","picURL":"http://p1.music.126.net/qDgXElJRtSsuqNwsTzW8lw==/667403558069001.jpg","playlistId":772430182,"time":291853}
    {"album":"The Ghost Of Tom Joad","author":"Bruce Springsteen","id":16657852,"name":"Straight Time (Album Version)","picURL":"http://p1.music.126.net/yK0V-aD3Myh4xorvwUtCrw==/17889054184179160.jpg","playlistId":772430182,"time":210651}
    {"album":"Epic Action & Adventure Vol. 6","author":"Epic Score","id":4054121,"name":"Time Will Remember Us","picURL":"http://p1.music.126.net/uN8AYI3sQEgoECuSYmi9Eg==/658607465082090.jpg","playlistId":636015704,"time":165000}

```
### matchQuery
查询某个字段中模糊包含目标字符串，使用matchQuery

``` java 
    /** 
     * 单字段对某字符串模糊查询 
     */  
    @Test
    public void matchQuerySong(){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(matchQuery("name","Time")).withPageable(of(0,100)).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
    }
```

返回结果

``` text
    {
      "match" : {
        "name" : {
          "query" : "Time",
          "operator" : "OR",
          "prefix_length" : 0,
          "max_expansions" : 50,
          "fuzzy_transpositions" : true,
          "lenient" : false,
          "zero_terms_query" : "NONE",
          "boost" : 1.0
        }
      }
    }
    {"album":"Time","author":"Cat naps","id":459733590,"name":"Time","picURL":"http://p1.music.126.net/9DmApLeDwutb4HpuhD_E-Q==/18624627464667106.jpg","playlistId":900228548,"time":86465}
    {"album":"Go Time","author":"Mark Petrie","id":29717271,"name":"Go Time","picURL":"http://p1.music.126.net/TJe468hZr_0ndQRfTAKdqA==/3233663697760186.jpg","playlistId":636015704,"time":136071}
    {"album":"The Blossom Chronicles","author":"Philter","id":21375446,"name":"Adventure Time","picURL":"http://p1.music.126.net/YjMS5_kM3u9PCUU0lcRK8g==/6657542907248762.jpg","playlistId":636015704,"time":207412}
    {"album":"Shire Music Annual Selection - Myth","author":"Shire Music,Songs To Your Eyes,","id":34916751,"name":"Between Space And Time","picURL":"http://p1.music.126.net/CCqLd2ly2XuuSPz0IW0u-g==/3284241233077333.jpg","playlistId":636015704,"time":222456}
    {"album":"Electric Warrior","author":"T. Rex","id":29848501,"name":"There Was A Time","picURL":"http://p1.music.126.net/dn1MwEBfBcL4l6isrnEwDw==/3246857839528733.jpg","playlistId":772430182,"time":60577}
    {"album":"Double Live Doggie Style I","author":"X-Ray Dog","id":26246058,"name":"Time Will Tell","picURL":"http://p1.music.126.net/oYEIMWnAvpuRDTk4g_l-lg==/2503587976473913.jpg","playlistId":636015704,"time":202133}
    {"album":"Decimus","author":"Audio Machine","id":36586631,"name":"Ashes of Time","picURL":"http://p1.music.126.net/7InBepjNDGCzpzH8Feyw9A==/3395291908535260.jpg","playlistId":636015704,"time":190826}
    {"album":"The Ghost Of Tom Joad","author":"Bruce Springsteen","id":16657852,"name":"Straight Time (Album Version)","picURL":"http://p1.music.126.net/yK0V-aD3Myh4xorvwUtCrw==/17889054184179160.jpg","playlistId":772430182,"time":210651}
    {"album":"Epic Action & Adventure Vol. 6","author":"Epic Score","id":4054121,"name":"Time Will Remember Us","picURL":"http://p1.music.126.net/uN8AYI3sQEgoECuSYmi9Eg==/658607465082090.jpg","playlistId":636015704,"time":165000}

```
### matchPhraseQuery
PhraseMatch查询，短语匹配

``` java
    /** 
     * 单字段对某短语进行匹配查询，短语分词的顺序会影响结果 
     */  
    @Test
    public void phraseMatchSong(){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(matchPhraseQuery("name","Time")).withPageable(of(0,100)).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
    }
```

### termQuery
这个是最严格的匹配，属于低级查询，不进行分词的，参考这篇文章 http://www.cnblogs.com/muniaofeiyu/p/5616316.html

``` java 
    /** 
     * term匹配，即不分词匹配，你传来什么值就会拿你传的值去做完全匹配 
     */  
    @Test
    public void termQuerySong(){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(termQuery("name","Time")).withPageable(of(0,100)).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
    }
```

### multiMatchQuery
多个字段匹配某字符串,如果我们希望name，author两个字段去匹配某个字符串，只要任何一个字段包括该字符串即可，就可以使用multiMatchQuery。

``` java 
    /** 
     * 多字段匹配 
     */  
    @Test
    public void multiMatchQuerySong(){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(multiMatchQuery("time","name","author")).withPageable(of(0,100)).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
    }
```

### 完全包含查询
之前的查询中，当我们输入“我天”时，ES会把分词后所有包含“我”和“天”的都查询出来，如果我们希望必须是包含了两个字的才能被查询出来，那么我们就需要设置一下Operator。

``` java 
    /** 
     * 单字段包含所有输入 
     */  
    @Test
    public void matchQueryOperatorSong(){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(matchQuery("name","真的").operator(Operator.AND)).withPageable(of(0,100)).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
    }
```

无论是matchQuery，multiMatchQuery，queryStringQuery等，都可以设置operator。默认为Or，设置为And后，就会把符合包含所有输入的才查出来。
如果是and的话，譬如用户输入了5个词，但包含了4个，也是显示不出来的。我们可以通过设置精度来控制。

``` java 
    /** 
     * 单字段包含所有输入(按比例包含) 
     */  
    @Test
    public void matchQueryOperatorWithMinimumShouldMatchSong(){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(matchQuery("name","time").operator(Operator.AND).minimumShouldMatch("80%")).withPageable(of(0,100)).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
    }
```

minimumShouldMatch可以用在match查询中，设置最少匹配了多少百分比的能查询出来。

### 合并查询
即boolQuery，可以设置多个条件的查询方式。它的作用是用来组合多个Query，有四种方式来组合，must，mustnot，filter，should。
must代表返回的文档必须满足must子句的条件，会参与计算分值；
filter代表返回的文档必须满足filter子句的条件，但不会参与计算分值；
should代表返回的文档可能满足should子句的条件，也可能不满足，有多个should时满足任何一个就可以，通过minimum_should_match设置至少满足几个。
mustnot代表必须不满足子句的条件。
譬如我想查询name包含“XXX”，且userId=“2345098”，且time最好小于165000的结果。那么就可以使用boolQuery来组合。

``` java
    /** 
     * 多字段合并查询 
     */  
    @Test
    public void boolQuerySong(){
        SearchQuery searchQuery = new NativeSearchQueryBuilder().withQuery(boolQuery().must(termQuery("userId", "2345098"))
                .should(rangeQuery("time").lt(165000)).must(matchQuery("name", "time"))).build();
        System.out.println(searchQuery.getQuery().toString());
        List<Song> songList = songDAO.search(searchQuery).getContent();
        for (Song song : songList) {
            System.out.println(JSONObject.toJSONString(song));
        }
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