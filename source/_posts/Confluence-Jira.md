---
title: 同步 Jira 的用户到 Confluence 中使用
date: 2022-06-16 17:23:17
description: 有时我们自建了 Jira 站点，又搭建了 Confluence 服务，想着不用再做一次用户的新增，可以使用 Jira 的用户到 Confluence 中使用
categories: [Confluence篇]
tags: [Confluence]
---

<!-- more -->

## 背景
有时我们自建了 Jira 站点，又搭建了 Confluence 服务，想着不用再做一次用户的新增，可以使用 Jira 的用户到 Confluence 中使用

## 操作

### 第一步 在 Jira 中配置用户服务器
![image-20221028183734308](http://112.29.246.234:6106/typora/2022-10/28/1666953454593.png)

其中 IP 地址指的是 confluence 服务所在的地址，相当于白名单地址的意思

### 第二步 配置 Confluence

配置 Confluence 的 **用户目录** 选项

![image-20221028184043190](http://112.29.246.234:6106/typora/2022-10/28/1666953643382.png)

点击 “测试并保存” 完成数据的同步