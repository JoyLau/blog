---
title: JS数组去重最简单方法
date: 2017-3-14 14:22:51
description: 最简单的JS数组去重复方法
categories: [JavaScript篇]
tags: [JavaScript]
---
<!-- more -->
``` javascript
    let arr = [1, 1, 2, 2]
    arr = Array.prototype.slice.call(new Set(arr))
    alert(arr)
    //output: 1, 2
```