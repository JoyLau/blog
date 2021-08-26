---
title: Docker 搭建 DNS 服务器并配置转发
date: 2021-08-26 18:10:38
description: Docker 搭建 DNS 服务器并配置转发
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
## 启动脚本

```yaml
    version: "3"
    services:
      dns-server:
        image: sameersbn/bind:9.16.1-20200524
        container_name: dns-server
        restart: always
        volumes:
          - ./data:/data
        ports:
          - 53:53/udp
          - 53:53/tcp
          - 10000:10000
        environment:
          - ROOT_PASSWORD=Kaiyuan@2020
          - WEBMIN_INIT_SSL_ENABLED=false

```

## 配置
先将界面语言切换为中文

### 配置自定义域名
1. 创建一个主区域
2. 域名 / 网络 这一栏填写根域名
3. 在 地址 记录里添加二级域名， 名称填写二级域名，地址填 IP 地址
4. 点击右上角的刷新按钮应用配置

### 配置转发
1. 点击 “转发和传输”, 添加一个上级的 DNS 服务器地址： 223.5.5.5
2. 在配置运行查询的权限， 进入 “默认区域”， “默认的区域设置”， “允许查询自…	” 选择 “列出的 ”， 填入 "any", 返回保存
3. 使用 `dig @dns-ip baidu.com` 调试结果
4. 如果还遇到问题，进入 “DNSSEC Verification” 将 “DNSSEC response validation enabled?” 和 “DNSSEC enabled?” 都选择 “否”， 返回保存即可