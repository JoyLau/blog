---
title: MySQL 数据库数据定时备份并上传至 minIO
date: 2021-05-20 14:01:47
description: MySQL 数据库数据定时备份并上传至 minIO
categories: [MySQL篇]
tags: [MySQL,MinIO]
---
<!-- more -->

1. 下载 minIO 客户端

http://dl.minio.org.cn/client/mc/release/linux-amd64/mc

拷贝到 MySQL 服务器的 /usr/bin 目录下并授权

`chmod +x /usr/bin/mc`

2. 配置 mc 客户端

`mc config host add minio http://10.55.3.132:9000 "AKIAIOSFODNN7EXAMPLE" "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"`

文档地址： https://docs.min.io/minio/baremetal/reference/minio-cli/minio-mc.html

3. 添加备份脚本

mysql-backup.sh

```shell
#!/bin/sh

# 创建桶 mysql-backup
mc mb minio/mysql-backup

docker exec  mysql-slave-1 mysqldump -h 10.55.3.123 -u root -pKaiyuan@2020  etc | mc pipe --attr "Artist=mysql" minio/mysql-backup/etc-`date "+%Y-%m-%d_%H-%M-%S"`.sql

# 删除 10 天前的备份
mc rm --older-than=10d --force --recursive minio/mysql-backup/
```

`chmod +x mysql-backup.sh`

4. 添加定时任务

```shell
    crontab -e
    
    30 4 * * * /root/backup-mysql.sh>/root/backup-mysql.log 2>&1 &

```