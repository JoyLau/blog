---
title: 群晖系列 --- 使用豆瓣的削刮器来检索视频的元数据
date: 2019-05-30 10:32:13
description: Video Station 自带的削刮器好像并不是很好用,很多电视剧都搜不到元数据,换了豆瓣的就比较好用了
categories: [群晖篇]
tags: [群晖]
---

<!-- more -->
### 背景
Video Station 自带的削刮器好像并不是很好用,很多电视剧都搜不到元数据,换了豆瓣的就比较好用了

### 安装方法：
1. 开启DSM的ssh，并登入
2. 执行一句话安装：

```bash
    sudo wget -N --no-check-certificate https://sh.9hut.cn/dsvp.sh && sudo bash dsvp.sh install
```

### 卸载方法：
1. 开启DSM的ssh，并登入
2. 执行一句话卸载：

```bash
    sudo wget -N --no-check-certificate https://sh.9hut.cn/dsvp.sh && sudo bash dsvp.sh uninstall
```
