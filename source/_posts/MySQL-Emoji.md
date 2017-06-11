---
title: 为网站添加emoji表情支持
date: 2017-3-21 08:35:04
description: "<center><img src='//image.joylau.cn/blog/emoji.jpg' alt='emoji'></center><br>普通的文字在平常聊天已经是远远不能满足人们的正常需求了，emoji小表情的流行貌似更能表达人们之间用文字无法传达的情感"
categories: [MySQL篇]
tags: [MySQL,emoji]
---
<!-- more -->

![emoji](//image.joylau.cn/blog/emoji.jpg)


## 准备
- MySQL5.5.3+
- mysql-connector-java5.1.13+


## 有异常
``` bash
    java.sql.SQLException: Incorrect string value: '\xF0\x9F\x92\x94' for colum n 'name' at row 1 
    at com.mysql.jdbc.SQLError.createSQLException(SQLError.java:1073) 
    at com.mysql.jdbc.MysqlIO.checkErrorPacket(MysqlIO.java:3593) 
    at com.mysql.jdbc.MysqlIO.checkErrorPacket(MysqlIO.java:3525) 
    at com.mysql.jdbc.MysqlIO.sendCommand(MysqlIO.java:1986) 
    at com.mysql.jdbc.MysqlIO.sqlQueryDirect(MysqlIO.java:2140) 
    at com.mysql.jdbc.ConnectionImpl.execSQL(ConnectionImpl.java:2620) 
    at com.mysql.jdbc.StatementImpl.executeUpdate(StatementImpl.java:1662) 
    at com.mysql.jdbc.StatementImpl.executeUpdate(StatementImpl.java:1581)
```


## 配置项
``` bash 
        
    [client]
    default-character-set = utf8mb4
    
    [mysql]
    default-character-set = utf8mb4
    
    [mysqld]
    character-set-client-handshake = FALSE
    character-set-server = utf8mb4
    collation-server = utf8mb4_unicode_ci
```

- 数据库字符集：`utf8mb4 -- UTF-8 Unicode`
- 排序规则：`utf8mb4_general_ci`


## 多样的浏览器兼容
``` javascript
    <link href="http://cdn.staticfile.org/emoji/0.2.2/emoji.css" rel="stylesheet" type="text/css" />
    <script src="http://cdn.staticfile.org/jquery/2.1.0/jquery.min.js"></script>
    <script src="http://cdn.staticfile.org/emoji/0.2.2/emoji.js"></script>
    
    
    
    var $text = $('.emojstext');
    var html = $text.html().trim().replace(/\n/g, '<br/>');
    $text.html(jEmoji.unifiedToHTML(html));
```