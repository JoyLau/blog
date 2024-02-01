---
title: Jenkins --- 集成钉钉发送通知
date: 2021-07-30 17:25:37
description: Jenkins 集成钉钉发送通知
categories: [Jenkins篇]
tags: [Jenkins]
---
<!-- more -->

### 安装插件 
插件地址： https://jenkinsci.github.io/dingtalk-plugin/

### 流水线配置
使用语法：

```groovy
    def description = sh(returnStdout: true, script: 'mvn -q -N -Dexec.executable="echo"  -Dexec.args=\'${project.description}\'  org.codehaus.mojo:exec-maven-plugin:3.0.0:exec').trim()
    dingtalk (
        robot: 'id',
        type: 'ACTION_CARD',
        title: 'Jenkins 流水线构建提醒',
        text: [
                '![](http://nas.joylau.cn:5016/1920x1080?' + UUID.randomUUID().toString() + ')',
                '### Jenkins 流水线构建结果',
                '- 项目描述：' + description,
                '- 分支名：' + env.BRANCH_NAME,
                '- 构建状态：失败',
                '- 构建时间：' + currentBuild.durationString
             ],
        )
```

### 效果
![Jenkins-Dingtalk](//s3.joylau.cn:9000/blog/Jenkins-Dingtalk.png)