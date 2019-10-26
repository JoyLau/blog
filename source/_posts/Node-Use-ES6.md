---
title: NodeJs 使用 ES6 语法
date: 2019-10-26 15:44:30
description: Nodejs 本身并没有完全支持 ES6 的语法,想 import , export 都无法使用,这里简单一种简单的方式在 nodejs 里使用 es6 语法
categories: [Node篇]
tags: [Nodejs]
---

<!-- more -->

1. package.json 添加 

```json
    "babel": {
        "presets": [
          "es2015"
        ]
      },
    "devDependencies": {
        "babel-cli": "^6.26.0",
        "babel-preset-es2015": "^6.24.1",
        "babel-register": "^6.26.0"
      }
```

2. npm install

3. 有 2 种方法可配置
- 第一种: 启动命令改为: `./node_modules/.bin/babel-node app.js`
- 第二种: 在 app.js 头部里添加 `require("babel-register");`