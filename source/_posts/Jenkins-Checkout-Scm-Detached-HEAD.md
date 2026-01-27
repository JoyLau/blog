---
title: Jenkins --- checkout scm 拉取代码会导致 Git 处于“分离头指针” （detached HEAD）状态的解决方案
date: 2026-01-27 11:05:00
description: jenkins checkout scm 会导致处于“分离头指针”状态，继而 springboot 的 Git-Commit-Id-Plugin插件生成的 git.properties 的分支名称为提交的hash 值
categories: [Jenkins篇]
tags: [Jenkins]
---

### 情况说明
jenkins checkout scm 会导致处于“分离头指针”状态，继而 springboot 的 Git-Commit-Id-Plugin插件生成的 git.properties 的分支名称为提交的hash 值  
Jenkins 在 Pipeline 里执行  checkout scm， 它 checkout 的不是 origin/main、origin/dev，而是一个 具体提交的 hash  
Git 就进入了 Detached HEAD（分离头指针） 状态  

### 解决思路 
不要让构建时的 Git 仓库处于 detached HEAD 状态  
或者显式告诉插件当前分支是谁  
不用改 git-commit-id-plugin 插件的配置

<!-- more -->

### 解决方案一
Jenkins checkout 后重新切回分支  

```shell
stage('Checkout') {
    steps {
        checkout scm
        sh '''
          git checkout -B ${BRANCH_NAME} origin/${BRANCH_NAME}
        '''
    }
}
```

### 解决方案二（推荐）
使用 Jenkins Git 插件的 LocalBranch  

```shell
checkout([
  $class: 'GitSCM',
  branches: [[name: "*/${BRANCH_NAME}"]],
  userRemoteConfigs: scm.userRemoteConfigs,
  extensions: [
    [$class: 'LocalBranch', localBranch: "${BRANCH_NAME}"]
  ]
])

```