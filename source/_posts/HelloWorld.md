---
title: Hello World
date: 2017-1-01 12:59:47
description: "作为一名程序员，第一篇博客那必须是HelloWorld。</br>第一篇博客想介绍下自己搭建这个博客的用途，以及该博客搭建的框架及技术，最后说一下关于博客这块以后的建设。"
categories: [开始篇]
tags: [Hexo,Nodejs,Git,Bootstrap]
---
<!-- more -->

![HelloWorld](//image.joylau.cn/blog/world.jpg)


## 关于博客

### 搭建一个自己博客的想法

- 其实在老早以前自己就有搭建一个自己博客的想法，中途也搭建尝试自己动手操作过，但是好几次都半途而废了。
在这期间主要的原因是自己平时没有那么多的时间，这也许跟我自己的想法有关系，原先我认为搭建一个博客就类似于开发一套管理系统，要有前台页面，后台管理...
- 我本身是做Java后端开发的，虽然说在实际的项目中大部分都是Web项目，但是要我自己真正的写一套前台页面，对我来说真的是很难。
- 我也从网站找过很多的博客类模板，并自己动手开发过，花了不少的时间，时间越久，发现很多都是不符合自己的想法的。这时我意识到之前的想法错了，或者说过于陈旧了。

### WordPress
- 再后来自己动手搭过很出名的[WordPress](https://cn.wordpress.org/)博客系统，[WordPress](https://cn.wordpress.org/)是基于`PHP`开发的。
期间还研究了一段时间的`PHP`，搭好过后换着主题玩了一段时间，后来想二次开发一些自己的东西，但是无从下手啊.....于是这个就没再玩了...

### Solo
- [Solo](https://github.com/b3log/solo)这个词儿肯定很熟悉，当然了不是LOL里面的solo，这个一个完全开源的Java博客系统，在GitHub上找一下就知道，
Solo 是目前 GitHub 上关注度最高的 Java 开源博客系统，在GitHub上是start最多的。clone下来用着还真算不错。后来在里面发现一款主题，和我现在博客使用的很像。
顺藤摸瓜，于是有了现在的这套博客系统....

### Hexo
- Hexo 的中文官网：http://hexo.io/zh-cn/
- 官网的介绍是这样的：
> Hexo 是一个快速、简洁且高效的博客框架。Hexo 使用 Markdown（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页。
- 而我是这么理解的：
> 用Github + Hexo + Nodejs搭建的博客,把逼格一下提到了凡人不可企及的高度。
- 当我打开官网的文档查阅后，发现了这个很有意思的搭建方式，不需要花那么多的时间去做开发，直接专注的写好自己的技术博客就可以，而且还可以基于`Bootstrap`生成移动端和网页端都可以兼容的页面。
- 我觉得很有搞头，于是决定马上动手搭建起来......



## 动手干活

### 所需工具软件
- git : http://git-scm.com/
- Nodejs : http://nodejs.org/
- Hexo ： http://hexo.io/zh-cn/

### 搭建过程
- git和Nodejs的下载和安装过程就不说了


- Node.js 官方源默认是：http://registry.npmjs.org，  但是由于在国外，说不定你使用的时候就抽风无法下载任何软件。所以我们决定暂时使用淘宝提供的源，淘宝源官网：http://npm.taobao.org/， (然而比较坑爹的是公司的网络将与taobao相关的域名都和谐掉了)
  在 Git Bash 中我们执行下面这一句
  ``` bash
  alias cnpm="npm --registry=https://registry.npm.taobao.org \
  --cache=$HOME/.npm/.cache/cnpm \
  --disturl=https://npm.taobao.org/dist \
  --userconfig=$HOME/.cnpmrc"
  ```
  
- 接下来就是使用cnmp命令了，值得注意的是：cnmp这个命令是临时的，当窗口关闭下次再打开就不会再生效了，于是每次你都需要执行以下这个命令。
- 检测安装是否成功 `cnpm info express`,若成功会有一大串的信息提示。
- 安装Hexo
    ``` bash
        cnpm install -g hexo-cli
    ```
    
- 创建Hexo项目
    ``` bash
        //打开到hexo的根目录
        cd h:/hexo
        hexo init
        cnpm install
    ```
    
- 启动Hexo服务
    ``` bash
        hexo server
    ```
    

### 搭建完成
- 浏览器访问：http://localhost:4000/
- 搭建结束搭建完之后可以修改自定义的配置文件 `_config.yml` ，以及更换成自己想要的主题 `themes`。


### 文章置顶
- 编辑这个文件：`node_modules/hexo-generator-index/lib/generator.js`
- 覆盖原文件内容，采用下面内容：
    ``` javascript
        'use strict';
        var pagination = require('hexo-pagination');
        module.exports = function(locals){
          var config = this.config;
          var posts = locals.posts;
            posts.data = posts.data.sort(function(a, b) {
                if(a.top && b.top) { // 两篇文章top都有定义
                    if(a.top == b.top) return b.date - a.date; // 若top值一样则按照文章日期降序排
                    else return b.top - a.top; // 否则按照top值降序排
                }
                else if(a.top && !b.top) { // 以下是只有一篇文章top有定义，那么将有top的排在前面（这里用异或操作居然不行233）
                    return -1;
                }
                else if(!a.top && b.top) {
                    return 1;
                }
                else return b.date - a.date; // 都没定义按照文章日期降序排
            });
          var paginationDir = config.pagination_dir || 'page';
          return pagination('', posts, {
            perPage: config.index_generator.per_page,
            layout: ['index', 'archive'],
            format: paginationDir + '/%d/',
            data: {
              __index: true
            }
          });
        };
    ```
    
- 然后在文章头部的：Front-matter 位置加上一个：top: 1000 的内容。数值越大，越靠前

### 文章推送
- 安装git插件 ： npm install hexo-deployer-git --save
- 配置文件

``` xml
    deploy:
      type: git
      repository: https://github.com/JoyLau/blog-public.git
      branch: master
```

- 使用方式： hexo g -d ,会自动推送到上面配置的github地址,分支名为 master 默认的分支名为gh-page


## 博客建设

### 博客用途
- 整理一些在项目中用到的小知识或者技术点做一个总结及叙述，希望通过这些记录，能够将自己的学习成果归纳出来，与大家分享交流，同时能够对这些技术进行备忘，以便日后查询

### 以后建设
- 这个博客只用作技术记录。
- 自己打算再开一个专门记录生活的博客站，域名都起好了：http://life.joylau.cn  (**`已弃用`**，发现真心没那么多时间去搞很多东西)




