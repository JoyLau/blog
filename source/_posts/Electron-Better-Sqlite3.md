---
title: Electron ---- Better-Sqlite3 使用问题
date: 2020-06-10 09:33:34
description: Electron 使用 Better-Sqlite3 报错的问题记录
categories: [Electron篇]
tags: [Electron]
---

<!-- more -->

### 错误信息

```bash
     The module '/node_modules/better-sqlite3/build/better_sqlite3.node'
    was compiled against a different Node.js version using
    NODE_MODULE_VERSION 57. This version of Node.js requires
    NODE_MODULE_VERSION 64. Please try re-compiling or re-installing
    the module (for instance, using `npm rebuild` or `npm install`).
```


### 解决方法

`npm install --save-dev electron-rebuild`
使用electron-rebuild进行重新编译:

`node_modules/.bin/electron-rebuild -f -w better-sqlite3`


如果没有编译成功, 则查看是否安装了, node-gyp
因为在 electron-rebuild 项目的 README 里, 
看到这句话: 

```bash
    If you have a good node-gyp config but you see an error about a missing element on Windows like `Could not load the Visual C++ component "VCBuild.exe"`, try to launch electron-rebuild in an npm script:
```