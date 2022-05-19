---
title: GitLab 升级步骤
date: 2021-05-19 22:55:47
description: 记录下本次 GitLab 的升级步骤
categories: [GitLab篇]
tags: [GitLab]
---
<!-- more -->

## 说明
公司内网的 GitLab 服务很久没升级了，记录下最近的升级步骤

## 现有部署情况

docker-compose.yml

``` yaml
    version: "3"
    services:
      gitlab:
        image: gitlab/gitlab-ce:15.4.2-ce.0
        container_name: gitlab
        ports:
          - 80:80
          - 443:443
          - 22:22
        volumes:
          - ./config:/etc/gitlab
          - ./log:/var/log/gitlab
          - ./data:/var/opt/gitlab
        restart: always
```

gitlab.rc 文件配置：

``` derby
    external_url 'http://192.168.1.41'
    #备份保存时间为 2 天, 单位为秒
    gitlab_rails['backup_keep_time'] = 172800
```

只配置了这 2 项， 其他均为默认配置

## 升级步骤
首先备份当前服务的数据， docker  exec 进入容器， 执行 

`gitlab-backup create`

耐心等待备份完成
后续出问题要恢复的话，执行
`gitlab-backup restore BACKUP=11493107454_2018_04_25_10.6.4-ce`

接下来开始升级，升级的思路是逐步升级到一个大版本开始和结束，一层层往上升级，这里官方给出的升级路线是：

`8.11.Z -> 8.12.0 -> 8.17.7 -> 9.5.10 -> 10.8.7 -> 11.11.8 -> 12.0.12 -> 12.1.17 -> 12.10.14 -> 13.0.14 -> 13.1.11 -> 13.8.8 -> 13.12.15 -> 14.0.12 -> 14.3.6 -> 14.9.5 -> 14.10.Z -> 15.0.Z -> 15.4.0 -> latest 15.Y.Z`

[官方文档](https://docs.gitlab.com/ee/update/#upgrading-gitlab)

还有个升级路径检测 [工具](https://gitlab-com.gitlab.io/support/toolbox/upgrade-path/)

根据上述路径， 我们只需要每次更改 image: gitlab/gitlab-ce:15.4.2-ce.0 的版本号，重启容器，等容器 Gitlab 正常提供服务，再重复步骤即可






