---
title: MinIO 数据迁移简记
date: 2021-02-05 11:00:01
description: MinIO 数据迁移简记
categories: [MinIO篇]
tags: [MinIO]
---

<!-- more -->

## 步骤
1. 下载 minio/mc 项目
2. 分别添加源服务器和目标服务器： `./mc.exe config host add local http://10.55.3.131:9000 "AKIAIOSFODNN7EXAMPLE" "
   wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"`
3. 按桶进行迁移： `./mc.exe mirror local/blacklist new/blacklist`