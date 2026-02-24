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

```nginx
stream {
    resolver 223.5.5.5 8.8.8.8 valid=30s ipv6=off;

    server {
        listen xxx udp;
        proxy_pass xxxx.com:xxx;
    }
}
```

- 每 30 秒重新解析一次
- DNS 更新后可自动生效
- 无需 reload nginx