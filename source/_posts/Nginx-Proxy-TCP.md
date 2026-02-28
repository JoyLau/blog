---
title: Nginx 反向代理 TCP 端口
date: 2021-10-10 10:16:40
description: Nginx 反向代理 TCP 端口
categories: [Nginx篇]
tags: [Nginx]
---

<!-- more -->

```shell
stream {

    upstream rabbit {
    server 172.30.241.82:5672;
    }
    
    server{
    listen 45672;
    proxy_pass rabbit;
    }
}
```


stream 放到和 http 同一级

别忘了开启防火墙端口

```firewall-cmd --zone=public --add-port=45672/tcp --permanent```
```firewall-cmd --reload ```

如果提示错误 `unknown directive "stream"`
则需要加载相应的模块

在 nginx.conf 配置

```shell
load_module /usr/lib64/nginx/modules/ngx_stream_module.so;
```


这里是我用的包
[Modules](//s3.joylau.cn:9000/blog/nginx-steam-modules.zip)


使用源码编译包 
#### 下载源码
地址 ：https://nginx.org/en/download.html

#### 启动一个 docker 容器用来编译打包 
`docker run -it -v /tmp/nginx-1.18.0/:/data centos:7.4.1708 bash`

#### 安装编译工具等 

```bash
yum -y install gcc gcc-c++ pcre pcre-devel zlib zlib-devel openssl openssl-devel
```

```bash
yum groupinstall 'Development Tools'
```

### 配置，编译，安装
```shell
./configure --prefix=/usr/local/nginx  --with-http_stub_status_module --with-http_ssl_module --with-stream

make

make install
```

然后直接拷贝编译好的 nginx 二进制文件用就行

### 解决域名解析缓存的问题
如果反向代理的域名是动态域名，当解析发生变化后，Nginx 不会重新解析（只在启动或 reload 时解析一次域名）
解决方式  
将域名改为变量形式，Nginx 才会按照 resolver 的 valid 时间定期重新解析  

```nginx
stream {
    resolver 223.5.5.5 8.8.8.8 valid=10s ipv6=off;
    resolver_timeout 2s;

    server {
        listen xxx udp;
        set $backend "域名:端口";
        proxy_pass $backend;
    }
}
```

Nginx 的 resolver 不是定时主动轮询，而是按需触发 + 缓存过期机制：

有新请求进来 → 检查 DNS 缓存是否过期（valid=10s）→ 已过期则重新查询 → 建立连接

没有请求进来，Nginx 永远不会主动发 DNS 查询。 valid=10s 只是缓存有效期，不是轮询间隔。

验证方法

手动模拟 UDP 请求触发解析：

终端：抓包
`tcpdump -i any port 53`

客户端: 连接
如果 IP 变化后希望尽快生效，将 valid 调小（如 valid=5s），确保每次请求间隔超过该值即可。
