---
title: Knife4j 文件上传接口不显示文件选项的解决方法
date: 2021-09-30 10:14:25
description: Knife4j 文件上传接口不显示文件选项的解决方法
categories: [SpringBoot篇]
tags: [SpringBoot]
---

<!-- more -->

加入注解 ```@RequestPart```

```@RequestParam("file") @RequestPart("file") MultipartFile multipartFile```