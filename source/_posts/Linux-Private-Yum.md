---
title: Yum 私服搭建记录
date: 2018-12-08 13:48:34
description: 有时我们的服务器网络并不允许连接互联网,这时候 yum 安装软件就有很多麻烦事情了
categories: [Linux篇]
tags: [Linux,YUM]
---

<!-- more -->
## 背景
有时我们的服务器网络并不允许连接互联网,这时候 yum 安装软件就有很多麻烦事情了, 我们也许会通过 yumdownloader 来从可以连接互联网的机器上下载好 rpm 安装包,
然后再拷贝到 服务器上.
命令 : `yumdownloader  --resolve mariadb-server` , 所有依赖下载到当前文件夹下

这样做会存在很多问题:
1. 虽然上述命令已经加上了 `--resolve` 来解决依赖,但是一些基础的依赖包仍然没有下载到,这时安装就有问题了
2. 下载的很多依赖包都有安装的先后顺序,包太多的话,根本无法搞清楚顺序

## rsync 同步科大的源
1. `yum install rsync`
2. `df -h` 查看磁盘上目录的存储的空间情况
3. 找到最大的磁盘的空间目录,最好准备好 50 GB 以上的空间
4. 新建目录如下:

``` bash
    mkdir -p ./yum_data/centos/7/os/x86_64
    mkdir -p ./yum_data/centos/7/extras/x86_64
    mkdir -p ./yum_data/centos/7/updates/x86_64
    mkdir -p ./yum_data/centos/7/epel/x86_64
```

5. 开始同步 base extras updates epel 源

``` bash
    cd yum_data
    rsync -av rsync://rsync.mirrors.ustc.edu.cn/centos/7/os/x86_64/ ./centos/7/os/x86_64/
    rsync -av rsync://rsync.mirrors.ustc.edu.cn/centos/7/extras/x86_64/ ./centos/7/extras/x86_64/
    rsync -av rsync://rsync.mirrors.ustc.edu.cn/centos/7/updates/x86_64/ ./7/updates/x86_64/
    rsync -av rsync://rsync.mirrors.ustc.edu.cn/epel/7/x86_64/ ./epel/7/x86_64/
```

6. 开始漫长的等待......
7. 等待全部同步完毕, `tar -czf yum_data.tar.gz ./yum_data` ,压缩目录
8. 压缩包拷贝到服务器上

## 配置本地 yum 源
1. 找到一个空间大的目录下,解压包: `tar -xvf yum_data.tar.gz`
2. 创建一个新的源配置: `touch /etc/yum.repos.d/private.repo`
3. 插入一下内容:

``` bash
    [local-base]
    name=Base Server Repository
    baseurl=file:///home/liufa/yum_data/centos/7/os/x86_64
    enabled=1
    gpgcheck=0
    priority=1
    [local-extras]
    name=Extras Repository
    baseurl=file:///home/liufa/yum_data/centos/7/extras/x86_64
    enabled=1
    gpgcheck=0
    priority=2
    [local-updates]
    name=Updates Server Repository
    baseurl=file:///home/liufa/yum_data/centos/7/updates/x86_64
    enabled=1
    gpgcheck=0
    priority=3
    [local-epel]
    name=Epel Server Repository
    baseurl=file:///home/liufa/yum_data/centos/7/epel/x86_64
    enabled=1
    gpgcheck=0
    priority=4
```

4. 禁用原来的 Base Extras Updates 源: `yum-config-manager --disable Base,Extras,Updates `
5. `yum clean all`
6. `yum makecache`
7. `yum repolist` 查看源信息


## 配置网络 yum 源
有时候我们搭建的私有 yum 还需要提供给其他的机器使用,这时候再做一个网络的 yum 即可,用 Apache 或者 Nginx 搭建个服务即可

1. `yum install nginx`
2. `vim /etc/nginx/nginx.conf` 修改

``` bash
        server {
            listen       80 default_server;
            listen       [::]:80 default_server;
            server_name  _;
            root         /home/liufa/yum_data;
    
            # Load configuration files for the default server block.
            include /etc/nginx/default.d/*.conf;
    
            location / {
            }
    
            error_page 404 /404.html;
                location = /40x.html {
            }
    
            error_page 500 502 503 504 /50x.html;
                location = /50x.html {
            }
        }
```

4. 这时 private.repo 里的 baseurl 全改为网络地址即可

## 403 权限问题
修改 nginx.conf 配置文件的 user 为 root