---
title: Office for Mac 2019 切换显示语言
date: 2020-10-12 11:36:26
cover: https://pic4.zhimg.com/v2-f10a8fd2e6852595707a23bc0bf58871_r.jpg
description: Office for Mac 2019 切换显示语言
categories: [日常折腾篇]
tags: [日常折腾]
---

<!-- more -->
### 背景
最近因为工作原因不得不在 Mac 上安装了 Office 套件

但是有一个问题, 我的 Mac 的系统语言是英文的, 安装完 Office 后, 整个操作都是英文的, 蒙蔽了....

### 解决
#### 方式一
打开终端:

```shell
    defaults write com.microsoft.Word AppleLanguages '("zh_CN")'
    defaults write com.microsoft.Excel AppleLanguages '("zh_CN")'
    defaults write com.microsoft.Powerpoint AppleLanguages '("zh_CN")'
```

切换回英文的话, 修改 zh_CH 为 en 即可

#### 方式二
在系统设置里面修改特定APP的语言

![IMage](https://pic4.zhimg.com/v2-f10a8fd2e6852595707a23bc0bf58871_r.jpg)

注: 转自知乎
