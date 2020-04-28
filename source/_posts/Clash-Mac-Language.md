---
title: ClashX 在英文 Mac 系统中切换界面语言
date: 2020-04-28 15:00:31
description: 在网络上搜索关于 ClashX 的教程, 看到的截图都是中文的界面, 而我安装后的界面语言却是英文的, 就想着怎么能够切换下
categories: [Clash]
tags: [ClashX]
---

<!-- more -->
### 背景
在网络上搜索关于 ClashX 的教程, 看到的截图都是中文的界面, 而我安装后的界面语言却是英文的, 就想着怎么能够切换下
在软件的设置里, 没有找到设置语言的选项

### 操作
去作者的 Github 去看了下代码, 发现是有中英文的配置的
那么既然作者做了语言环境适配, 那么在安装包里肯定有语言文件

1. 在 `Applications` 右键 `ClashX` ,显示包内容
2. 进入 `Resources` 目录, 看到 `en.lproj` 和 `zh-Hans.lproj`
3. 将 `zh-Hans.lproj` 目录里的文件拷贝并覆盖掉 `en.lproj` 里的文件
4. 重启软件即可