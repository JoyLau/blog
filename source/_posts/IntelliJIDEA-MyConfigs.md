---
title: IntelliJ IDEA 自用配置记录
date: 2018-06-25 16:57:59
description: 我自己在多个系统中都有使用 IDEA， IDEA登录账户的话是支持配置同步的。但是由于每个系统的环境变量配置，字体，快捷键等等不同,导致一套配置并不能很好的通用，于是我在此记录下我平时的一些配置，忘了的话翻出来看看，马上就能达到我要的配置
categories: [IntelliJ IDEA篇]
tags: [IntelliJ IDEA]
---

<!-- more -->
### 背景
我自己在多个系统中都有使用 IDEA， IDEA登录账户的话是支持配置同步的。但是由于每个系统的环境变量配置（JAVA_HOME,MAVEN_HOME,GIT,NODE,.....），文件目录结构，字体，快捷键等等不同,导致一套配置并不能很好的通用，于是我在此记录下我平时的一些配置，忘了的话翻出来看看，马上就能达到我要的配置

### 字体
1. UI 菜单字体
2. 编辑器字体 注意：在 Ubuntu 系统下中文字体显得很难看，这时候设置支持中文的第二字体
3. 控制台字体

### 插件
插件我使用的是 IDEA 的自动同步功能，在一台客户端下载过的插件都会自动同步，这个不需担心

### 编辑器变量颜色
进入设置： File | Settings | Editor | Color Scheme | Language Defaults， 开启 Semantic highlighting 功能

### 代码改动后目录颜色
File | Settings | Version Control， 开启 show directoris with ....

### 自动导包优化
File | Settings | Editor | General | Auto Import， 勾选 fly

### 设置 alt + /
File | Settings | Keymap | main menu | code | completion | basic 设为 alt + /
同时 取消 cyclic expand word 的 快捷键

### 自动提示忽略大小写
File | Settings | Editor | General | Code Completion，将 case sensitive completion 修改为NONE

### 编辑器设置多Tab页
File | Settings | Editor | General | Editor Tabs 去掉 show tabs in single row

### idea64.vmoptions 配置
16G 以上的机器： 
    -Xms512m
    -Xmx1500m
    -XX:ReservedCodeCacheSize=500m
    -XX:SoftRefLRUPolicyMSPerMB=100
添加编码 ：
    -Dfile.encoding=UTF-8

### idea.properties 配置
控制台打印日志的行数：默认为 1024，不限制的话：
    idea.cycle.buffer.size=disabled