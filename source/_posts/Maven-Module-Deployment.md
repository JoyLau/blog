---
title: Maven --- 多模块项目选择性部署
date: 2025-10-14 17:23:30
description: 在实际开发中，我们经常需要只部署多模块项目中的特定模块。以下是几种实用的 Maven 部署技巧
categories: [Maven篇]
tags: [Maven]
---


在实际开发中，我们经常需要只部署多模块项目中的特定模块。以下是几种实用的 Maven 部署技巧：


<!-- more -->

## 场景一：只部署父项目

```bash
mvn deploy -N
```

或
```bash
mvn deploy -pl .`
```

参数说明：

-N：非递归模式，只处理当前项目

-pl .：明确指定当前目录项目


## 场景二：部署父项目和指定子模块

```bash
mvn deploy -pl .,im-common,im-client
```

参数说明：
- -pl：指定项目列表，逗号分隔
- .：代表当前父项目

其他实用参数
- -am：同时构建依赖模块
- !module：排除特定模块


使用 Maven 的 -pl 参数可以精准控制部署范围，避免不必要的模块构建，提高效率。