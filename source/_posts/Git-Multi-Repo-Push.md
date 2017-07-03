---
title: 记录一次Git多仓库提交
date: 2017-7-3 09:10:02
description: "拿OSChina的码云和GitHub用来做的实验"
categories: [Git篇]
tags: [Git,GitHub]
---

<!-- more -->

## 实验步骤


- 新建一个项目
- 可先分别在码云和 GitHub 上建好仓库<可选>
- 将项目提交的码云上
- 项目提交到另一个仓库的时候重新 define remote <可选>
- 之后每次先提交到本地仓库，可以根据每次提交到本地仓库的不同，来选择定义的 remote 来分别提交
- 每次 pull 也可以选择仓库


## 遇到个问题

### 问题
- 在我新建好码云的仓库后，提交项目，遇到  Git Pull Failed: fatal: refusing to merge unrelated histories

### 原因
- 原因：git拒绝合并两个不相干的东西

### 解决
- 此时在命令行输入 ： git pull origin master --allow-unrelated-histories
- 要求我输入提交信息
- 输入完成后，按一下Esc,再输入:wq,然后回车就OK了
- 再回来提交就可以了
