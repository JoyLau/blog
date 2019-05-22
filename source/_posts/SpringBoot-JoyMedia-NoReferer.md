---
title: 重剑无锋,大巧不工 SpringBoot --- 实战项目 JoyMedia （ NoReferer篇 ）
date: 2017-08-29 11:13:24
img: <center><img src="//image.joylau.cn/blog/joymusic-mv-noreferer.png" alt="JoyMusic-NoReferer"></center>
description: JoyMedia --- 解决上篇文章 MV 防盗链加上 referer 认证的问题<br>同时加上下滑看 MV 评论时,将视频缩小化到右下角,一边看 MV 一边看热评两不误
categories: [SpringBoot篇]
tags: [Node.js,SpringBoot]
---

<!-- more -->

## 前言

### 效果展示

<center>
![JoyMusic-NoReferer](//image.joylau.cn/blog/joymusic-mv-noreferer.png)
![JoyMusic-NoReferer](//image.joylau.cn/blog/joymusic-mv-video-small.gif)
![JoyMusic-NoReferer](//image.joylau.cn/blog/joymusic-mv-video-url.gif)
</center>

### 在线地址
- [JoyMusic](//music.joylau.cn)

### 问题说明
- 为什么解析的 MV 地址无法直接播放，在上一篇文章上我也说明了
- 相应的解决办法我在上一篇文章上也说明了
- 这样的方法有很明显的缺点，在上一篇文章也说明了
- 这个方法只能实现播放的功能，但是距离完美或者说好的展示效果来说，并不满意
- 我自己就很不满意


## 开始动手

### 先说下我是怎么解决的
- 解决的方法还是一样：去除referer
- 同时去除了原来使用的jPlayer播放器，因为这个播放器在移动设备下的表现并不是很好，现在改为浏览器自带的视频播放空控件
- 这个东西就没有什么兼容性了，只要IE10 以上支持HTML5 的都可以观看
- 正如上面我截图所示的那样，我使用的是 Safari 浏览器，表现效果还是很好的
- 同时也加入了一些比较棒的小功能：比如下滑看评论的时候，会出现小视频框在右下角
- 我个人是比较喜欢看评论的，一些音乐或者 MV 页面打开后并不是先听或者先看，都是翻到下面看看评论
- 这也正是我喜欢网易云音乐的原因之一，网易云音乐的评论大部分都很精彩，有时候听歌不如看评论


### 现在是怎么在页面上去除referer的？
- 动态生成一个iframe,我本身是比较反对使用iframe的，因为以前使用的extjs使用的多了，都用吐了，而且性能还不是很好
- 但是在这里它可就起了大作用了
- iframe 里的页面就放一个`<video>`
- iframe 的宽度高度及video的宽度高度都要调节好，其实这一步花了我不少时间，因为并不是所有的MV宽高的比例是一样的
- iframe 的src不能直接写MV的MP4地址，因为那样的话就没有作用了
- 在src里写js脚本动态生成html页面，页面里面包括的之前提到的video
- 使用这种方法就可将网站的referer去除掉
- 这就类似于直接在浏览器的地址栏上输入MP4的地址然后播放
- 在前一篇的文章分析中，我们知道，这种方法是可以播放的

## 编写代码
### 动态渲染iframe：
``` javascript
    return '<iframe \
    				style="border 1px solid #ff0000" \
    				scrolling="no" \
    				frameborder="no" \
    				allowtransparency="true" ' +
    			/*-- Adding style attribute --*/
    			objectToHtmlAttributes( iframeAttributes ) +
    			'id="' + id + '" ' +
    			'	src="javascript:\'\
    			<!doctype html>\
    			<html>\
    			<head>\
    			<meta http-equiv=\\\'Content-Type\\\'; content=\\\'text/html\\\'; charset=\\\'utf-8\\\'>\
    			<style>*{margin:0;padding:0;border:0;}</style>\
    			</head>' +
    			/*-- Function to adapt iframe's size to content's size --*/
    			'<script>\
    				 function resizeWindow() {\
    					var elems  = document.getElementsByTagName(\\\'*\\\'),\
    						width  = parent.document.getElementById(\\\'panel-c\\\').offsetWidth-7,\
    						height = 0,\
    						first  = document.body.firstChild,\
    						elem;\
    					if (first.offsetHeight && first.offsetWidth) {\
    						width = first.offsetWidth;\
    						height = first.offsetHeight;\
    					} else {\
    						for (var i in elems) {\
    											elem = elems[i];\
    											if (!elem.offsetWidth) {\
    												continue;\
    											}\
    											width  = Math.max(elem.offsetWidth, width);\
    											height = Math.max(elem.offsetHeight, height);\
    						}\
    					}\
    					var ifr = parent.document.getElementById(\\\'' + id + '\\\');\
    					ifr.height = height;\
    					ifr.width  = width;\
    				};\
                 </script>' +
    			'<body onload=\\\'resizeWindow()\\\'>\' + decodeURIComponent(\'' +
    			/*-- Content --*/
    			encodeURIComponent(html) +
    		'\') +\'</body></html>\'"></iframe>';
```

注意这里的反斜杠不要去掉，是用来转义的，代码的样式虽然丑了点，但是并不影响使用

- 这里面有个方法是`encodeURIComponent(html)`，这个是转义了video里面的url链接
- 在iframe的body加载完成后会调用`resizeWindow()`函数自适应下iframe的宽高
- `html`里面写的就是要放入iframe的body里的代码，这里我们放的肯定是video
- 于是，可以将上述代码封装成一个函数，在父页面是直接调用
- 封装的时候我们还可以传一些参数，比如上面的iframe的初始的宽高，style，scrolling，frameborder等等


### 扩展一下
- 这个方式使用的是video
- 那么`<img>`呢？现在有些网站的图片也是经过了防盗链处理，这种方法也是可以实现去掉referer，直接访问图片的额

>> 欢迎大家来看看试试看!😘 http://music.joylau.cn  (当前版本 v1.5)