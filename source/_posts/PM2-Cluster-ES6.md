---
title: PM2 集群模式使用 ES6 语法
date: 2019-10-27 11:14:03
description: 前面一篇介绍了 Nodejs 使用 ES6 的语法,本篇继续 PM2 使用 ES6 语法
categories: [PM2篇]
tags: [Nodejs]
---

<!-- more -->

1. fork 模式下
- 使用命令参数 `pm2 start app.js --node-args="--harmony"`
- json 文件添加配置: `"node_args" : "--harmony"`

2. cluster 模式下
使用上一篇的方法 `require("babel-register");`
在更改配置:

```json
    {
      "apps": [
        {
          "name": "my_name",
          "cwd": "./",
          "script": "bin/start",
          "instances" : "max",
          "exec_mode" : "cluster",
          "log_date_format": "YYYY-MM-DD HH:mm Z",
          "error_file": "./logs/error.log",
          "watch": ["routes"]
        }
      ]
    }
```
这里需要注意:
1. exec_mode 要改为 `cluster`, instances 为实例数, max 为 CPU 的核心数,
2. script 里配置的直接就是 js 文件,不需要加 node 命令(如 "script": "node bin/start") ,否则启动会报错,我踩过这个坑
