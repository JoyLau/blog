---
title: Ubuntu 最佳编程字体 Monaco 的优化显示
date: 2018-07-13 11:03:44
description: 自从入了 MBP 后就被其默认的字体显示效果吸引了，在编辑器里写代码更是舒服，于是想着把 Mac 下的字体也移植到 Ubuntu 下，但是显示效果并不是特别的好，尤其是粗体字的显示
categories: [Ubuntu篇]
tags: [Ubuntu]
---
<!-- more -->

## 背景
自从入了 MBP 后就被其默认的字体显示效果吸引了，在编辑器里写代码更是舒服，于是想着把 Mac 下的字体也移植到 Ubuntu 下，但是显示效果并不是特别的好，尤其是粗体字的显示

## 前后对比
左侧使用前，右侧使用后
<figure class="half"><img src="//s3.joylau.cn:9000/blog/Monaco1.png" width="50%"/><img src="//s3.joylau.cn:9000/blog/Monaco4.png" width="50%"/></figure>

<figure class="half"><img src="//s3.joylau.cn:9000/blog/Monaco2.png" width="50%"/><img src="//s3.joylau.cn:9000/blog/Monaco5.png" width="50%"/></figure>

<figure class="half"><img src="//s3.joylau.cn:9000/blog/Monaco3.png" width="50%"/><img src="//s3.joylau.cn:9000/blog/Monaco6.png" width="50%"/></figure>

## 使用步骤
1. 该字体为开源字体，字体地址： https://github.com/vjpr/monaco-bold
2. 复制到 `/usr/share/fonts`
3. `fc-cache -fv` 生成字体缓存

我的 1080P 分辨率，我的配置如下：
![MonacoB2](//s3.joylau.cn:9000/blog/Monaco7.png)

## 2018-07-18 14:22:05 更新
看到一篇关于 Ubuntu 字体渲染问题的文章: 修复 Ubuntu 中文字体渲染  https://i-meto.com/fix-chinese-font-display/