---
title: 重剑无锋,大巧不工 SpringBoot --- 实战项目 JoyMedia （ MV篇 ）
date: 2017-08-20 10:09:04
description: '<center><video src="//s3.joylau.cn:9000/blog/joymusic-mv.mp4" loop="true" controls="controls" poster="//s3.joylau.cn:9000/blog/joymusic-mv-poster.png">您的浏览器版本太低，无法观看本视频</video></center>  <br>JoyMedia --- 观看海量 MV 视频'
categories: [SpringBoot篇]
tags: [Node.js,SpringBoot]
---

<!-- more -->

## 前言

### 效果展示

<center><video src="//s3.joylau.cn:9000/blog/joymusic-mv.mp4" loop="true" controls="controls" poster="//s3.joylau.cn:9000/blog/joymusic-mv-poster.png">您的浏览器版本太低，无法观看本视频</video></center>

### 在线地址
- [JoyMusic](//music.joylau.cn)


## 开始
### 需要准备
- 这次要解析的是 网易云音乐的 MV
- 需要准备的解析的有
- 获取 MV 信息列表
- 获取 MV 详细信息
- 获取 MV 播放地址
- 在线播放 MV
- 获取 MV 排行榜
- 获取最新 MV

### 说明
- 大部分解析提供的接口都和我以前2篇文章类似,之前的文章有分析过,这里就不再多说了
- 这里重点说明下 MV 的播放问题

### 关于 MV 的播放
- 解析 MV 详细信息,可获得 MV 的真实播放的 MP4 的地址
- 但是这个地址,网易云做了防盗链处理
- 什么是防盗链?
- 一般情况下,我的资源文件,比如 图片, css,js,视频,我们自己放到服务器上可以直接引用
- 同样的道理,别人可以访问你的服务器,也可以直接引用
- 那么,不想被别人引用怎么办呢?
- 这就引申出了防盗链的操作
- 最常见的防盗链的处理就是加上 referer识别,就是来源网址信息
- referer 其实是个错误的拼写,这个就是有历史原因了,以前的开发人员在定义这个属性的时候,把这个单词写错了,后来没有人注意到,一直使用到他作为标准
- 后来,也没有人去特意改他了,就这么用着吧
- 这个是简单防盗链处理
- 还有更复杂的,比如 js 加密路径信息,每次请求路径都会变化,这个就复杂了
- 很幸运,网易云的 MV 采用的就是 referer 的识别方式
- 那么就有相应的破解方法了

### 关于 referer
- MP4 的地址在浏览器地址栏直接粘过去是可以播放的,但是由其他网站跳进去的则不能访问,因为带进了 rerferer
- 那么,要做的就是去除 请求的 rerferer 
- 我找了很多资料也尝试了很多次,想在浏览器端把 rerferer 去除掉,基本是实现不了的,如果你实现在页面里单独请求 mp4 地址时不带referer, 请联系我
- 那么要做的就是在服务端操作了
- 在服务端操作很简单,就是伪造头信息进行请求

这个是带 referer 的请求,被网易云直接拒绝了

![joymusic-mv-referer](//s3.joylau.cn:9000/blog/joymusic-mv-referer.png)

这个是复制地址到地址栏,则可以直接播放

![joymusic-mv-no-referer](//s3.joylau.cn:9000/blog/joymusic-mv-no-referer.png)

## 服务单去除 referer
- 严格来说不能说去除 refere,我们需要将原本我们自己服务器的 referer 修改为网易云服务器的 referer
### Java 版
``` java
    public void playMV(HttpServletResponse res, String mvurl) throws IOException {
            if (StringUtils.isEmpty(mvurl)){
                return;
            }
            res.setContentType("video/mpeg4; charset=utf-8");
            URLConnection connection = new URL(mvurl).openConnection();
            connection.setRequestProperty("referer", "http://music.163.com/");
            connection.setRequestProperty("cookie", "appver=1.5.0.75771;");
            connection.connect();
            InputStream is = connection.getInputStream();
            OutputStream os = res.getOutputStream();
            byte bf[] = new byte[2048];
            int length;
            try {
                while ((length = is.read(bf)) > 0) {
                    os.write(bf, 0, length);
                }
            } catch (IOException e) {
                is.close();
                os.close();
                return;
            }
            is.close();
            os.close();
        }
```

解释: 
1. 首先我们请求的资源不是本地的资源,是存储在其他服务器上的,这里用到的是URL
2. 这里我们需要设置 referer 和 cookie,结合前面使用的 URL, 这里使用的是URLConnection
3. 后面的就很好理解了,相当于做了一个管道,将读取的文件流原封不动的通过Response返回给调用者
4. 不要忘了设置 setContentType 为 MP4 的格式

### nodejs 版
``` javascript
    const express = require("express");
    const router = express();
    const request = require("request");
    
    router.get("/", (req, res) => {
      const url = req.query.url;
      const headers = {
        "Referer": "http://music.163.com/",
        "Cookie": "appver=1.5.0.75771;",
        'Content-Type': 'video/mp4',
        'Location': url
      };
      const options = {
        header: headers,
        url: url
      };
      request(options).on('error', err => {
          res.send({ err })
        }).pipe(res)
    });
    
    module.exports = router;
```
解释:
和上面的 Java 版代码是一个意思,主要是 pipe 流管道将文件流返回给调用者

### 功能完成
- 那么这样解决了 MP4 地址防盗链的问题

### 缺点
- 不足之处也暴露了
- 首先这段代码必须部署到服务端
- 部署到服务端就需要服务器去拉去 MV 的流信息,这无疑给服务器增加过多的流量压力
- 其次,由于使用的流传输,这个 MP4 的播放是不支持快进操作的

## 有个简单的解决方式
- 在 html5 之后,想去除 referer 信息, a标签有个属性 rel 
- 将 `rel="noreferrer"` 即可在 a 标签的 href 的链接上去除 referer信息
- 这一属性已被我使用在播放器的右下角的一个小飞机的按钮上
- 点击小飞机按钮就可以直接看 MV 视频了,流量走的是网易云的CDN,不再试自己的服务器

![joymusic-mv-no-referer-href](//s3.joylau.cn:9000/blog/joymusic-mv-no-referer-href.png)

## 不完美
- 总感觉这个解决不够完美
- 如果你看到这篇文章能有更好的解决办法,请联系我

>> 欢迎大家来看看试试看!😘 http://music.joylau.cn  (当前版本 v1.4)