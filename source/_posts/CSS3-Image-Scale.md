---
title: 当鼠标移入图片上慢慢放大的效果
date: 2017-10-13 15:07:54
cover: http://image.joylau.cn/blog/image-scale.gif
description: " "
categories: [前端篇]
tags: [CSS3]
---

<!-- more -->
- 今天在浏览网站时，http://ai.baidu.com/ ，看到一个CSS3的效果:将鼠标放到图片上，图片会稍稍方大一点，当时很好奇是怎么做的
- 当即百度了一下，有人用js做的，有人用css做的，首先js做的肯定不够好，一看效果就是css3的效果
- 于是自己查看了下 这块 div 的效果
- 将压缩的css展开来
- 原来是这样的：


``` css 
    # 鼠标移上去各浏览器的延时效果
    .solution-img {
        height: 100%;
        -webkit-transform-origin: 50% 50%;
        -moz-transform-origin: 50% 50%;
        -ms-transform-origin: 50% 50%;
        transform-origin: 50% 50%;
        -webkit-transition: -webkit-transform .2s;
        transition: -webkit-transform .2s;
        -moz-transition: transform .2s,-moz-transform .2s;
        transition: transform .2s;
        transition: transform .2s,-webkit-transform .2s,-moz-transform .2s
    }
    
    # 鼠标移上去各浏览器的放大倍数
    .solution-item:hover .solution-img {
        -webkit-transform: scale(1.1);
        -moz-transform: scale(1.1);
        -ms-transform: scale(1.1);
        transform: scale(1.1)
    }
```
