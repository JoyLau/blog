---
title: MacOS 10.15 版本里 Quick Look 插件无法使用的解决办法
date: 2020-03-18 09:55:40
img: <center><img src='//image.joylau.cn/blog/qlPlugin-not-work.png' alt='qlPlugin-not-work'></center>
description: 关于 MacOS 10.15 版本里 Quick Look 插件无法使用的解决办法
categories: [MacOS篇]
tags: [MacOS]
---

<!-- more -->
## 错误
MacOS 升级到 10.15 版本时,预览文件出现下面的提示

<center><img src='//image.joylau.cn/blog/qlPlugin-not-work.png' alt='qlPlugin-not-work'></center>

## 解决方式 1
删除 ~/Library/QuickLook 目录下的隔离属性 (quarantine attribute) 

运行下面命令查看属性:

```shell script
    xattr -r ~/Library/QuickLook
```

运行下列命令移除这些属性:

```shell script
    xattr -d -r com.apple.quarantine ~/Library/QuickLook
```


## 解决方式 2
1. 空格预览文件出现下列提示,点击 取消

<center><img src='//image.joylau.cn/blog/qlPlugin-not-work.png' alt='qlPlugin-not-work'></center>

2. 转到系统设置里

<center><img src='//image.joylau.cn/blog/qlPlugin-solution-1.png' alt='qlPlugin-solution-1'></center>

点击 "Allow Anyway"

3. 使用下列命令打开刚才需要预览的文件

```shell script
    qlmanage -p /path/to/any/file.js
```

4. 此时弹出提示,点击 "open"

<center><img src='//image.joylau.cn/blog/qlPlugin-solution-2.png' alt='qlPlugin-solution-2'></center>

5. 然后就可以预览该后缀名的所有文件了

<center><img src='//image.joylau.cn/blog/qlPlugin-solution-3.png' alt='qlPlugin-solution-3'></center>

6. 如果需要预览其他类型的文件,则将上述步骤重新操作一遍, 换个后缀名即可

### 最后推荐
推荐下自己使用的预览插件

```shell script
    brew cask reinstall qlcolorcode qlstephen qlmarkdown quicklook-json qlimagesize suspicious-package quicklookase qlvideo
```

需要注意的是 `qlcolorcode` 需要 `highlight` 库来显示高亮效果, 需要安装:  `brew install highlight`