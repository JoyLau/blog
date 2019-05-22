---
title: 重剑无锋,大巧不工 SpringBoot --- 实战项目 JoyMedia （ Node篇 ）
date: 2017-07-29 10:09:04
img: <center><img src='//image.joylau.cn/blog/joylau-media-node.png' alt='JoyMedia-Node'></center>
description: JoyMedia --- Node服务提供解析及 APIs
categories: [SpringBoot篇]
tags: [Node.js,SpringBoot]
---

<!-- more -->

## 前言
### 在线地址
- [JoyMusic](//music.joylau.cn)
### Node.js 的学习
- 入门是从这本书上开始的
- 结合Node中文网的文档开始探索开发

## 说明
- 利用 Node 来解析网易云音乐,其实质就是 跨站请求伪造 (CSRF),通过自己在本地代码中伪造网易云的请求头,来调用网易云的接口


## 分析
### 以获取歌曲评论来分析
- 我们打开其中一首音乐,抓包看一下

![JoyMedia - Node](//image.joylau.cn/blog/joylau-media-node-1.png)

- 绝大部分的请求都是 POST 的
- 我们找到其中关于评论的请求,如上图所示
- 链接中间的部分是歌曲的 id 值
- 在返回的 JSON 数据中包含了热评和最新评论
- 评论过多的话是分页来展示的
- 通过参数 limit 来显示评论数量, offset 来控制分页

![JoyMedia - Node](//image.joylau.cn/blog/joylau-media-node-2.png)

- 再来看,这是我本地浏览器中的 cookies 值,现在为止知道有个 csrf 值用来加密

![JoyMedia - Node](//image.joylau.cn/blog/joylau-media-node-3.png)

- 每个请求后面都会跟上csrf_token 值,其他的参数还有params 和 encSecKey
- 这些值的加密算法无非是2种,一种是前台 js 加密生成的,另一种是将参数传往后台,由后台加密完再传回来
- 想要测试一下很简单,将里面的值复制一下在 xhr 里找一下就知道了
- 推测是是 js 加密的,加密的 js 简直不能看,如下图

![JoyMedia - Node](//image.joylau.cn/blog/joylau-media-node-4.png)
- 看到很多请求后面都返回了 md5 那么 md5 加密是肯定有的
- 其实仔细看加密的参数,很多都能靠猜出来
- 本地需要创建一个私钥secKey，十六位，之后aes加密生成，在通过rsa吧secKey加密作为参数一起传回
- 那么下面贴出加密代码

``` javascript
    const modulus = '00e0b509f6259df8642dbc35662901477df22677ec152b5ff68ace615bb7b725152b3ab17a876aea8a5aa76d2e417629ec4ee341f56135fccf695280104e0312ecbda92557c93870114af6c9d05c4f7f0c3685b7a46bee255932575cce10b424d813cfe4875d3e82047b97ddef52741d546b8e289dc6935b3ece0462db0a22b8e7';
    const nonce = '0CoJUm6Qyw8W8jud';
    const pubKey = '010001';
    function createSecretKey(size) {
      const keys = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
      let key = "";
      for (let i = 0; i < size; i++) {
          let pos = Math.random() * keys.length;
          pos = Math.floor(pos);
          key = key + keys.charAt(pos)
      }
      return key
    }
    
    function aesEncrypt(text, secKey) {
      const _text = text;
      const lv = new Buffer('0102030405060708', "binary");
      const _secKey = new Buffer(secKey, "binary");
      const cipher = crypto.createCipheriv('AES-128-CBC', _secKey, lv);
      let encrypted = cipher.update(_text, 'utf8', 'base64');
      encrypted += cipher.final('base64');
      return encrypted
    }
    
    function zfill(str, size) {
        while (str.length < size) str = "0" + str;
        return str
    }
    
    function rsaEncrypt(text, pubKey, modulus) {
      const _text = text.split('').reverse().join('');
      const biText = bigInt(new Buffer(_text).toString('hex'), 16),
          biEx = bigInt(pubKey, 16),
          biMod = bigInt(modulus, 16),
          biRet = biText.modPow(biEx, biMod);
      return zfill(biRet.toString(16), 256)
    }
    
    function Encrypt(obj) {
      const text = JSON.stringify(obj);
      const secKey = createSecretKey(16);
      const encText = aesEncrypt(aesEncrypt(text, nonce), secKey);
      const encSecKey = rsaEncrypt(secKey, pubKey, modulus);
      return {
        params: encText,
        encSecKey: encSecKey
      }
    }
```


- 挺复杂的,很多我也是参考网络上其他人的加密方式


### 伪造网易云头部请求
- 这一步就很简单了,主要需要注意的就是 referer 的地址一定要是网易云的地址
- 其他的想 cookie 和 User-Agent 直接复制浏览器的即可
- 那我们构造一个 POST 的请求
- 需要都回到函数和错误返回回调函数
- 贴下代码

``` javascript
    const Encrypt = require('./crypto.js');
    const http = require('http');
    function createWebAPIRequest(host, path, method, data, cookie, callback, errorcallback) {
        let music_req = '';
        const cryptoreq = Encrypt(data);
        const http_client = http.request({
            hostname: host,
            method: method,
            path: path,
            headers: {
                'Accept': '*/*',
                'Accept-Language': 'zh-CN,zh;q=0.8,gl;q=0.6,zh-TW;q=0.4',
                'Connection': 'keep-alive',
                'Content-Type': 'application/x-www-form-urlencoded',
                'Referer': 'http://music.163.com',
                'Host': 'music.163.com',
                'Cookie': cookie,
                'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.152 Safari/537.36',
    
            },
        }, function (res) {
            res.on('error', function (err) {
                errorcallback(err)
            });
            res.setEncoding('utf8');
            if (res.statusCode !== 200) {
                createWebAPIRequest(host, path, method, data, cookie, callback);
    
            } else {
                res.on('data', function (chunk) {
                    music_req += chunk
                });
                res.on('end', function () {
                    if (music_req === '') {
                        createWebAPIRequest(host, path, method, data, cookie, callback);
                        return
                    }
                    if (res.headers['set-cookie']) {
                        callback(music_req, res.headers['set-cookie'])
                    } else {
                        callback(music_req)
                    }
                })
            }
        });
        http_client.write('params=' + cryptoreq.params + '&encSecKey=' + cryptoreq.encSecKey);
        http_client.end()
    }
```

- 那么再结合我们刚才分析的评论API, 发出该请求

``` javascript
    const express = require("express");
    const router = express();
    const { createWebAPIRequest } = require("../common");
    
    router.get("/", (req, res) => {
        const rid=req.query.id;
        const cookie = req.get('Cookie') ? req.get('Cookie') : '';
        const data = {
            "offset": req.query.offset || 0,
            "rid": rid,
            "limit": req.query.limit || 20,
            "csrf_token": ""
        };
        createWebAPIRequest(
            'music.163.com',
            `/weapi/v1/resource/comments/R_SO_4_${rid}/?csrf_token=`,
            'POST',
            data,
            cookie,
            music_req => {
                res.send(music_req)
            },
            err => res.status(502).send('fetch error')
        )
    });
    
    module.exports = router;
```

- 值得注意的是,这里我的 node 模板选择的 EJS 所使用的 js 语法格式也比较新,你需要将你 WebStorm 的 js 编译器的版本提升到ECMAScript 6,否则的话会报错,如下图所示:
![JoyMedia - Node](//image.joylau.cn/blog/joylau-media-node-5.png)


## 封装
- 我们写一个入口文件,可以直接运行期容器,以及提供 APIs
- 那么,这个就跟简单了

``` javascript
    const express = require('express');
    const http = require('http');
    const app = express();
    
    
    const port = 3000;
    
    const v = '/apis/v1';
    
    app.listen(port, () => {
        console.log(`server starting ${port}`)
    });
    
    /*APIs 列表*/
    app.use(express.static('public'));
    
    
    //推荐歌单
    app.use(v + "/personalized", require("./apis/personalized"));
    
    //歌单评论
    app.use(v + '/comment/playlist', require('./apis/comment_playlist'));
    
    //获取歌单内列表
    app.use(v + '/playlist/detail', require('./apis/playlist_detail'));
    
    //获取音乐详情
    app.use(v + '/song/detail', require('./apis/song_detail'));
    
    //单曲评论
    app.use(v + '/comment/music', require('./apis/comment_music'));
    
    //获取音乐 url
    app.use(v + '/music/url', require('./apis/musicUrl'));
    
    // 获取歌词
    app.use(v + '/lyric', require('./apis/lyric'))
    
    
    process.on('uncaughtException', function (err) {
        //打印出错误的调用栈方便调试
        console.log(err.stack);
    });
    
    
    module.exports = app;
```

- 引用 http 模块,开启 node 的默认3000 端口 
- 目前提供了上述注释里所写的 APIs
- 每一个 API 都会单独写一个模块,以在此调用
- 有一个地方值得注意的事
- node 是单线程的异步 IO,这使得他在高并发方面得到很快相应速度,但是也有缺点
- 当其中一个操作出错异常了,就会导致整个服务挂掉
- 我在此的处理方式是:监听全局异常,捕到异常后将错误的堆栈信息打印出来,这样使得后续的操作不得进行以至于使整个服务挂掉
- 当然,还有其他的方式来处理,可以通过引用相应的模块,来守护 node 的进程,简单的来说就是挂掉我就给你重启
- 我觉得第二种方式不是我想要的,我是采取的第一种方式
- 况且我还真想看看是什么错误引起的
- 最后发现都是网络原因引起的错误 🤣🤣🤣🤣😂😂😂😂😂

## 运行
- npm install
- node app.js

## 查看效果
![JoyMedia - Node](//image.joylau.cn/blog/joylau-media-node-7.png)

![JoyMedia - Node](//image.joylau.cn/blog/joylau-media-node-6.png)


>> 欢迎大家来听听试试看!😘 http://music.joylau.cn  (当前版本 v1.3)