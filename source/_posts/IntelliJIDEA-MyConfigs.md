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

### command + shift + / 块注释冲突
打开 macos 的设置， 键盘 | 快捷键 | App 快捷键 ， 取消勾选 所有应用程序的显示帮助菜单

### 自动提示忽略大小写
File | Settings | Editor | General | Code Completion，将 case sensitive completion 修改为NONE

### 编辑器设置多Tab页
File | Settings | Editor | General | Editor Tabs 去掉 show tabs in single row

### 提示 serialVersionUID 的生成
File | Settings | Editor | Inspections | Serialization issues | Serializable class without ’serialVersionUID’ 

### 显示内存占用
Preferences | Appearance & Behavior | Appearance | Show memory indicator

### 显示 Lambda 表达式的小图标
Preferences | Editor | General | Gutter Icons
找到 Lambda 并打上勾

### 编码时显示参数名的提示
Preferences | Editor | General | Code Completion
找到 Parameter Info
勾选 Show parameter name hints on completion
勾选 Show full method signatures

### 显示更多的参数名提示
Preferences | Editor | Inlay Hints | Java | Parameter Hints | Show parameters hints for:
勾选出自己想要显示的选项，我全都勾选了

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

### Mac OS 下 IDEA 文件位置
配置文件位置: /Users/joylau/Library/Preferences/IntelliJIdea201x.x
索引文件位置: /Users/joylau/Library/Caches/IntelliJIdea201x.x

### 新版 IDEA 新皮肤代码警告颜色修改
Editor -> Color Scheme -> General -> Errors and Warnings -> Warning 然后将背景色设置为 #5E5339

### 新版 IDEA 关闭预览和单击打开文件
在左侧 Project 面板，找到右上方的设置按钮， 去除勾选 **Enable Preview Tab** 和 **Open Files with Single Click**

### 新版（2023）IDEA 双击 shift 出现搜索结果慢
取消勾选配置：  
Advanced Settings -> Wait for all contributors to finish before showing results

### 删除以前版本的缓存文件
Help -> Delete Leftover IDE Directories...

### IntelliJ IDEA 2023.1.3 color schema 备份文件
更新了 2023.2 后，对编辑器的颜色不是很适应， 这里备份下我在 2023.1.3 下的配置， 后面可以继续使用
[IntelliJIDEA.2023.1.3.Color.Schema.Dark.icls](//s3.joylau.cn:9000/blog/IntelliJIDEA.2023.1.3.Color.Schema.Dark.icls)