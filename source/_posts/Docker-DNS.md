---
title: Docker 配置容器 DNS 服务
date: 2024-07-26 17:53:40
description: Docker 配置容器 DNS 服务
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
## 配置
```json
{
  "log-opts": {
    "max-size": "100m"
  },
  "data-root": "/data/docker-data",
  "dns": ["192.168.1.17","223.5.5.5"]
}
```

配置上面的 dns 配置，对所有的容器生效

我在本地用 docker 部署了一个 webmin 服务，其中 bind 可以用来做DNS 服务
启动docker 容器后发现，不能通过 192.168.1.17 来解析域名
解决办法是 webmin 的服务使用 host 网络即可

```yaml
version: "3"
services:
  dns-server:
    image: sameersbn/bind:9.16.1-20200524
    container_name: dns-server
    restart: always
    volumes:
      - ./data:/data
    network_mode: "host"
    #ports:
    #  - 53:53/udp
    #  - 10000:10000
    environment:
      - ROOT_PASSWORD=xxxx
      - WEBMIN_INIT_SSL_ENABLED=false
```

### 更新一个更简单的
```yaml
version: "3"
services:
  dns-server:
    image: cytopia/bind:stable-manifest-linux-arm64
    container_name: dns-server
    restart: always
    ports:
      - 53:53/udp
    volumes:
      - ./named.conf.local:/etc/bind/named.conf.local:ro
      - ./custom-hosts:/etc/bind/custom-hosts:ro
    environment:
      - DEBUG=1
      - DEBUG_ENTRYPOINT=2
      - DOCKER_LOGS=1
      - ALLOW_QUERY=any
      - ALLOW_RECURSION=none
      # 下面的配置会追加了 .rpz.触发名变成了 package.zksd.com.rpz. 不能使用
      #- DNS_A=im.jiangs.jy.gov.cn=10.110.100.137,package.zksd.com=170.168.113.71
```


named.conf.local:

```text
zone "zksd.com" {
    type master;
    file "/etc/bind/custom-hosts/db.zksd.com";
};

zone "jiangs.jy.gov.cn" {
    type master;
    file "/etc/bind/custom-hosts/db.jiangs.jy.gov.cn";
};
```

db.zksd.com:

```text
$TTL 3600
@   IN SOA ns.local. admin.local. ( 2026110601 3600 600 86400 3600 )
@   IN NS  ns.local.

package                     IN A 170.168.113.71
shengju                     IN A 170.168.113.71

```

这个服务的作用是：封闭内网，只解析这几个域名，彻底不查上游

如果需要 只想覆盖这几个名字，其余域名仍要能正常解析
需要配置环境变量

`- ALLOW_RECURSION=any          # 递归开着，未覆盖的名字才会转发到 10.1.8.8`
`- DNS_FORWARDER=10.1.8.8`


**named.conf.local**（zone 名＝完整 FQDN）

```text
zone "package.zksd.com" {
    type master;
    file "/etc/bind/custom-hosts/db.package.zksd.com";
};
zone "im.jiangs.jy.gov.cn" {
    type master;
    file "/etc/bind/custom-hosts/db.im.jiangs.jy.gov.cn";
};
```

**db.package.zksd.com**（@ 就是 zone 顶点 package.zksd.com）

```text
$TTL 3600
@   IN SOA ns.local. admin.local. ( 2026110601 3600 600 86400 3600 )
@   IN NS  ns.local.
@   IN A   170.168.113.71
```