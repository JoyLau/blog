---
title: 替换 jar 包中的 class 文件
date: 2021-05-03 10:01:43
description: 替换 jar 包中的 class 文件
categories: [Java篇]
tags: [Java]
---
<!-- more -->

在test.jar 的同目录下新建一个与 NeedReplace 类的全路径相同的目录，执行以下命令
md com\lovedata\bigdata\jar
执行 java -jar 来进行替换
jar uvf test.jar com\lovedata\bigdata\jar\NeedReplace.class
