---
title: git pull 和 git push 记住用户名密码
date: 2019-09-03 17:14:14
description: git pull 和 git push 记住用户名密码
categories: [Git篇]
tags: [Git]
---

<!-- more -->

## 执行
执行 `git config credential.helper store`

或者在 .gitconfig 添加

``` text
    [credential]
    helper = store
```

