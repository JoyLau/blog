---
title: Git 使用 ss 代理和 Ubuntu 使用 ss 全局代理
date: 2018-08-07 16:12:53
description: 这一段时间 GitHub 在国内的访问又出问题,代码提交不上去,需要在 Git 上走代理了
categories: [Git篇]
tags: [Git,Ubuntu]
---

<!-- more -->
## 背景
这一段时间 GitHub 在国内的访问又出问题,代码提交不上去,需要在 Git 上走代理了

## Git 使用 ss 代理配置
1. 需要全局 git 都走代理

``` bash
    git config --global http.proxy 'socks5://127.0.0.1:1080'
    git config --global https.proxy 'socks5://127.0.0.1:1080'
```

取消

``` bash
    git config --global --unset http.proxy
    git config --global --unset https.proxy
```

但是有时候我们并不需要所有的 git 仓库都走代理,可以去掉上述的命令中的 `--global`,然后到你需要走代理的那个 git 仓库下执行命令,或者添加配置:

2. 单独配置 git 走代理
在 .git => config 文件中加入配置

``` bash
    [https]
    	proxy = socks5://127.0.0.1:1080
    [http]
    	proxy = socks5://127.0.0.1:1080
```

其实,也就是上述命令执行后添加的配置.配置后就可以愉快的 clone push 了.

## Ubuntu 使用全局代理
Windows 和 MacOS 下的 ss 全局代理很方便,点击切换下就可以了,而 Ubuntu 下需要多点操作:

1. 启动 shadowsocks-qt5，并连接上
2. 生成 pac 文件,如果有现成的 pac 文件,直接进入第四步
3. 生成 pac 文件

安装 pip 

``` shell
    $ sudo pip install genpac
    $ pip install -U genpac ## 安装或更新
```

创建 user-rules.txt 文件

``` shell
    mkdir vpnPAC
    cd vpnPAC
    touch user-rules.txt
```

生成 autoproxy.pac 文件

``` shell
    genpac --format=pac --pac-proxy="SOCKS5 127.0.0.1:1080" --output="autoproxy2.pac" --gfwlist-url="https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt" --user-rule-from="user-rules.txt"
```

github 上的 gfwlist.txt 文件可能读取不到,多试几次

4. 配置使用

![配置使用](http://image.joylau.cn/blog/ubuntu-global-proxy.png)