---
title: MacOS 修改 mac 地址
date: 2018-06-14 09:03:16
description: 公司的网络接入是需要 ip 地址和 mac 地址绑定在一起的，笔记接入的 WiFi 没绑定就无法上网，想着公司那么多电脑不用，就利用他们已经绑定好的 静态 IP 地址和 mac 地址来上网
categories: [MacOS篇]
tags: [MacOS]
---

<!-- more -->
公司的网络接入是需要 ip 地址和 mac 地址绑定在一起的，笔记接入的 WiFi 没绑定就无法上网，想着公司那么多电脑不用，就利用他们已经绑定好的 静态 IP 地址和 mac 地址来上网

1. 随机生成一个全新的MAC网卡地址

``` shell
    openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'
```

2. 断开airport无线网卡连接

``` shell
    sudo /System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -z
```

3. 修改 mac 地址

``` shell
    sudo ifconfig en0 ether xx:xx:xx:xx:xx:xx
```

xx:xx:xx:xx:xx:xx ＝输入你想要修改成的MAC地址来代替。

en0 ＝ 输入你想要修改成的网卡代替。一般 en0 就为无线网卡

4. 重新打开网络

``` shell
    networksetup -detectnewhardware
```