---
title: Jenkins --- 使用脚本配置【丢弃旧的构建】
date: 2023-10-31 17:17:06
description: Jenkins使用脚本配置【丢弃旧的构建】
categories: [Jenkins篇]
tags: [Jenkins]
---


### 脚本
```groovy
    import hudson.tasks.LogRotator
    Jenkins.instance.allItems(Job).each { job ->
      println "$job.builds.number $job.name"
      if ( job.isBuildable() && job.supportsLogRotator()) {
        // 注释if所有任务统一设置策略，去掉注释后只更改没有配置策略的任务
        //if ( job.getProperty(BuildDiscarderProperty) == null) {
          job.setLogRotator(new LogRotator (-1, 3))
        //}
          //立马执行Rotate策略
          job.logRotate()
        println "$job.builds.number $job.name 磁盘回收已处理"
      } else { println "$job.name 未修改，已跳过" }
    }
    return;
```

LogRotator 有 2 个构造方法， 一个是 2 个参数的， 一个是 4 个参数的，构造参数分别为：

<!-- more -->

- daysToKeep: 保持构建的天数， 如果非空，构建记录将保存此天数
- numToKeep: 保持构建的最大个数， 如果非空，最多此数目的构建记录将被保存
- artifactDaysToKeep: 发布包保留天数，如果非空，比此早的发布包将被删除，但构建的日志、操作历史、报告等将被保留
- artifactNumToKeep: 发布包最大保留#个构建， 如果非空，最多此数目大构建将保留他们的发布包