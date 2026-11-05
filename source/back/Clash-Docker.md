---
title: Docker 安装 Clash 并对外提供代理服务
date: 2020-05-02 11:00:31
description: Docker 安装 Clash 并对外提供代理服务
categories: [Clash]
tags: [Clash,Docker]
---

<!-- more -->
### 配置
1. 端口: `port: 7890 ; socks-port: 7891`
2. 运行局域网访问: `allow-lan: true`
3. 对外提供 rest 接口: `external-controller: 0.0.0.0:8080`
4. dashboard 路径: `external-ui: /ui`
5. 配置文件 yaml, 挂载到: `/root/.config/clash/config.yaml`

### 运行
```bash
    docker run -d --name clash-client --restart always -p 7890:7890 -p 7891:7891 -p 8080:8080 -v /path/config.yaml:/root/.config/clash/config.yaml -v /path/ui:/ui dreamacro/clash
```

### Dashboard
1. 使用官方的 Dashboard : https://github.com/Dreamacro/clash-dashboard/tree/gh-pages
2. 使用另一个第三方看起来很炫酷的 Dashboard: https://github.com/haishanh/yacd/tree/gh-pages

### 配置文件
既然对外提供服务, 最好加密, 包括 Dashboard 加密和 http, socks 代理加用户名密码认证

```yaml
    port: 7890
    socks-port: 7891
    allow-lan: true
    mode: Rule
    log-level: info
    external-controller: '0.0.0.0:9090'
    secret: 'passwd'
    external-ui: /ui
    authentication:
      - "user:passwd"
    Proxy:
    Proxy Group:
    Rule:
```

启动之后,便可以使用 Dashboard 来操作 Clash 了.