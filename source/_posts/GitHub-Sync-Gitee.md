---
title: GitHub 仓库代码自动同步到 Gitee
date: 2021-08-05 17:55:09
description: GitHub 仓库代码自动同步到 Gitee
categories: [GitHub Action篇]
tags: [GitHub Action]
---
<!-- more -->
参考文章：https://neucrack.com/p/331

最后的脚本要改动下， 不然会报错


将 
`git push upstream --all --force --tags`
改为
`git push upstream --all --force`
`git push upstream --tags --force`





