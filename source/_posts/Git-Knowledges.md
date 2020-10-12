---
title: Git 知识点小记
date: 2020-02-18 15:20:35
description: Git 知识点小记
categories: [Git篇]
tags: [Git]
---

<!-- more -->
## git 命令显示中文

直接在终端中执行下面的命令
git config --global core.quotepath false


## 文件回滚
1. 工作区尚未暂存的文件: git checkout -- 文件名
2. 已添加到暂存区: git reset HEAD 文件名 && git checkout -- 文件名
3. 已提交到本地库, 想要撤销提交,并恢复到之前的文件内容: git reset --hard HEAD^

其中: 
git reset 有三种参数:
- Soft：这个模式仅仅撤销 commit 记录而已，不影响本地的任何文件，即本地修改的文件内容还会存在,也不影响（index）缓存区的任何文件。
- Hard：不仅撤销 commit 记录，还将本地的文件指向 commit 前的版本，同时 index 也会指向 commit 前的版本。
- Mixed：回滚 index ，其余的保持不变。

另外 HEAD 后面加上 `~1` 代表回滚一次 commit 记录, `HEAD^` 代表全部 commit 记录

## git fetch 和 git pull
1. git fetch : 将本地仓库指向的 remote 提交记录更新为和远端一致,即最新,其他的不做任何改变
2. git pull : 将本地仓库和将本地仓库指向的 remote 都更新为最新, 相当于 fetch + merge

参看: https://blog.csdn.net/qq_37420939/article/details/89736567


## git merge 和 git rebase
merge 和 rebase 都是 git pull 时的策略

git rebase 有以下几种使用场景:

1. 合并本地的多次提交记录

合并最近的 4 次提交纪录

```bash

    git rebase -i HEAD~4
```

在 idea 中可以在 Version Control 中选择最早时间的提交记录, 然后选择 `Interactively Rebase from Here`
然后除了第一个为pick外，其他选择squash，点击start rebasing，接着输入提交信息就可以把多次commit合并为一次了

2. 分支合并,可以把本地未push的分叉提交历史整理成直线

## 将提交合并到其他分支上
有时候我们在某一个分支上提交了一些代码, 需要将这次提交合并到其他分支上, 这时的做法是:

这当前分支上使用 git log 查看需要进行合并的提交记录的 ID

切换到需要合并的分支上: `git checkout 分支名`

进行合并: `git cherry-pick commitId`

推送到到上游分支: `git push `