---
title: MacOS HomeBrew 更新遇到的问题解决
date: 2020-03-18 12:08:41
description: MacOS HomeBrew 更新遇到的问题解决
categories: [MacOS篇]
tags: [MacOS, brew]
---

<!-- more -->
## 问题
brew update 遇到错误, 错误信息如下:

```shell script
   Updating Homebrew...
   Warning: You are using macOS 10.15.
   We do not provide support for this pre-release version.
   You will encounter build failures with some formulae.
   Please create pull requests instead of asking for help on Homebrew's GitHub,
   Discourse, Twitter or IRC. You are responsible for resolving any issues you
   experience, as you are running this pre-release version.
```

## 解决方式
1. brew doctor

运行后发现源为科大的源, 于是切换回原来的官方的 brew 源

```shell script
   cd "$(brew --repo)"
   git remote set-url origin https://github.com/Homebrew/brew.git
```

有其他问题,建议按照提示一一解决掉  

2. brew update

更新成功

3. brew config

查看配置

