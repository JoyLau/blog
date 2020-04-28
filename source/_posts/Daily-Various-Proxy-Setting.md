---
title: 各种代理设置汇总记录
date: 2020-04-01 21:58:25
description: 以前博客多多少少写个一些常用工具的代理设置,这里做一个汇总,以后有更多工具使用代理直接在此处记录了
categories: [日常折腾篇]
tags: [Proxy]
---

<!-- more -->

### 背景
以前博客多多少少写个一些常用工具的代理设置,这里做一个汇总, 以后有更多工具使用代理直接在此处记录了

### 说明
如果代理有用户名密码的话, 使用

```bash
    http://username:password@127.0.0.1:1087
```

### Mac 终端代理设置
`export HTTP_PROXY=http://127.0.0.1:1087`

`export SOCKS5_PROXY=socks5://127.0.0.1:1086`

`export ALL_PROXY=socks5://127.0.0.1:1086`

我一般直接使用最后一种方式,简单粗暴

### HomeBrew 代理设置
同上, 因为 brew 走的 curl,代理设置通用

### Git 代理配置
需要全局 git 都走代理

`git config --global http.proxy 'socks5://127.0.0.1:1080'`
`git config --global https.proxy 'socks5://127.0.0.1:1080'`

取消

`git config --global --unset http.proxy`
`git config --global --unset https.proxy`

但是有时候我们并不需要所有的 git 仓库都走代理,可以去掉上述的命令中的 --global,然后到你需要走代理的那个 git 仓库下执行命令,或者添加配置:

单独配置 git 走代理
在 .git => config 文件中加入配置

```bash
    [https]
    	proxy = socks5://127.0.0.1:1080
    [http]
    	proxy = socks5://127.0.0.1:1080
```

### Linux 终端代理
同 **Mac 终端代理设置**

### Ubuntu 桌面版使用全局代理
以前我使用的是: http://blog.joylau.cn/2018/08/08/Git-Proxy-And-Ubuntu-Global-Proxy/
现在我使用的是: Clash

### Gradle 配置代理
配置 gradle.properties

```properties
    ## http
    systemProp.http.proxyHost=www.somehost.org
    systemProp.http.proxyPort=8080
    systemProp.http.proxyUser=userid
    systemProp.http.proxyPassword=password
    systemProp.http.nonProxyHosts=*.nonproxyrepos.com|localhost
    
    ## https
    systemProp.https.proxyHost=www.somehost.org
    systemProp.https.proxyPort=8080
    systemProp.https.proxyUser=userid
    systemProp.https.proxyPassword=password
    systemProp.https.nonProxyHosts=*.nonproxyrepos.com|localhost
```

### Docker 配置代理
在命令行使用 export HTTP_PROXY=xxxx:xx , 命令行里绝大部分命令都可以使用此代理联网,但是安装的 docker 不行,无法 pull 下来镜像文件,想要 pull 使用代理的话,需要添加代理的变量
vim /usr/lib/systemd/system/docker.service
添加

`Environment=HTTP_PROXY=http://xxxx:xxx`
`Environment=HTTPS_PROXY=http://xxxx:xxx`

保存

`systemctl deamon-reload`
`systemctl restart docker`


### npm 使用代理
npm 支持 http 代理，但是不支持 socks 代理

```bash
    npm config set proxy "http://localhost:1087"
    npm config set https-proxy "http://localhost:1087"
```

删除代理

```bash
    npm config delete proxy
    npm config delete https-proxy
```