---
title: $(...).autocomplete is not a function 问题的解决
date: 2018-08-09 10:04:52
description: 因项目需求,需要一个自动提示的功能,想到之前有 jquery 的 jQuery-Autocomplete 插件,于是就直接拿来用了,但是使用情况却不是如此
categories: [前端篇]
tags: [Jquery]
---

<!-- more -->
### 背景
因项目需求,需要一个自动提示的功能,想到之前有 jquery 的 jQuery-Autocomplete 插件,于是就直接拿来用了,
直接在github 上找到了一个 starts 最多的项目 [jQuery-Autocomplete](https://github.com/devbridge/jQuery-Autocomplete.git)
看了下插件的 API 可配置项很多,有一个 appendTo 配置,是我想要的,于是就决定使用这个差价

直接把 插件下载下来 放到项目中去,直接 $(...).autocomplete is not a function
......


项目中我写的只是其中的一个模块,页面的代码是纯 html 页面写的,然后通过 panel 引入 html 代码片段
很奇怪,为什么插件无法加载

于是就就把官方的demo跑了一下,没有问题

又怀疑是 jQuery 版本的问题,
官方的demo jQuery 版本是 1.8.2,项目使用的是1.11.1,
于是又在官方的 demo 下替换jQuery的版本
发现使用没有问题


又怀疑是插件的版本过高,于是再 GitHub 的 release 上找了个2014年发布的1.2.2的版本,这已经是能找到的最低版本了
发现还是不行

这就奇怪了,我之前也引入过其他的插件,正常使用都没有问题,偏偏使用这个有问题
于是想着插件的引入方式有问题,打开一看,jQuery插件的引入方式都是大同小异的
本人前端不擅长,也不知道怎么改.....

于是又在 GitHub上找了其他的插件,有的能用,但是没有我想要的功能....

一直这么来来回回的测试,已经晚上 10 点了.....
从吃完晚饭一直研究到现在还是没有解决
心里好气啊!!!!!
空调一关,直接回家了!!!!

### 解决
今天早上来又差了点资料,找到了个不太靠谱,但又想尝试了下的方法
[TypeError: $(...).autocomplete is not a function](https://blog.verysu.com/article/328)

试一下吧,没想到真的可以

发一张对比图

![query-Load-Plugins](http://image.joylau.cn/blog/Jquery-Load-Plugins.md.png)
