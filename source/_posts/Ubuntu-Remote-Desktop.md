---
title: Ubuntu 优雅的远程桌面服务端配置
date: 2019-04-10 16:32:14
description: Ubuntu 自用远程桌面服务端配置
categories: [Ubuntu篇]
tags: [Ubuntu]
---
<!-- more -->

## 背景
上一篇文章记录了因为远程桌面连接把 Ubuntu 的 `/home` 弄坏了
好一番折腾。。。。
其实这个远程桌面我早就想重新配置了，今天我终于受不了它了，于是我觉得仔细研究一番找到适合我自己的方式来操作


## 以前的方式
之前我的远程配置是 `xrdp` + `tightvncserver`
然后我每次都是使用 Windows 上的 `mstsc` 来连接的
连接上后会出现 `xrpd` 的登录选项
每次我都选第一个 `sesman-Xvnc ` 然后输入用户名密码即可

可这样的连接方式有个很不好的方面，就是这种方式是多用户的，想回家继续没干完的事情
连接上发现是一个新的桌面
都不知道做到什么地方了

这也就算了

最大的问题远程操作操作这就没响应了，鼠标的指针变成了 × 号，所有的东西都不能点，而且第二天到公司桌面卡死不动，只能重启桌面或重启系统，很多打开软件和工具都会还原

这是我最不能忍的地方

## 决定改变
我决定不使用这种方式来进行远程，远程 `teamviewer` 是比较合适的选择，但是工作由于连接的终端太多，被检测商用，每次连接都是只有 1 min 的操作时间
很尴尬...

最后决定使用轻量级的 `vnc` 服务来解决这个问题，并且搭配 `xrdp` 的 `any vnc` 来使用 `mstsc` 远程连接

## 重新配置

### x11vnc
1. 卸载以前的 vnc 服务端

```bash
    sudo apt remove tigervncserver
    sudo apt remove tightvncserver
    systemcrl auto remove
```

2. 安装 `x11vnc` ,并进行配置

```bash
    sudo apt install x11vnc -y
    
    sudo x11vnc -storepasswd /etc/x11vnc.pass # 配置访问密码并存储
    
    vim  /lib/systemd/system/x11vnc.service # 创建系统服务
    
    # 服务配置
    [Unit]
    Description=Start x11vnc at startup.
    After=multi-user.target
    [Service]
    Type=simple
    ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared
    [Install]
    WantedBy=multi-user.target
    
    systemctl enable x11vnc.service
    systemctl start x11vnc.service
    
```

### 问题及解决
下载 vnc-view 新建一个连接发现连不上...
尴尬。。。
检查 `5900` 端口，是开放的

```bash
    joylau@joylau-work-192:~$ sudo netstat -tnlp | grep :5900
    tcp        0      0 0.0.0.0:5900            0.0.0.0:*               LISTEN      4022/vino-server
    tcp6       0      0 :::5900                 :::*                    LISTEN      4022/vino-server
```

但是使用的进程是 `vino-server` ，这是 Ubuntu 自带程序开启的服务
原来端口被占用了
关闭服务 ： 找到桌面共享，关闭 `允许其他人查看您的桌面`
重启 `x11vnc` 服务
连接成功

## 最后
现在有 4 中方式使用
1. 使用 `vnc-view` 使用是单用户的，类似 `teamviewer` 那样，2 边操作都能互相看见
2. 使用 `mstsc` , 连接到 `xrdp` 后，再选中 `any vnc` 使用 `vnc` 协议连接，效果和第一种是一样的，只不过不需要客户端了
4. 浏览器直接远程，这种最方便，下面有说明
4. 以前的那种使用方式， 多用户的，估计我是不会再用了

### 补充
第三种多用户方式连接，没连接一次就生成一个新的桌面，这个很烦，想连接回上次的桌面，可修改配置 `/etc/xrdp/xrdp.ini`

```bash
    [globals]
    
    bitmap_cache=yes 位图缓存
    
    bitmap_compression=yes 位图压缩
    
    port=3389 xrdp监听的端口（重要）
    
    crypt_level=low 加密程度（low为40位，high为128位，medium为双40位）
    
    channel_code=1
    
    max_bpp=24 XRDP最大连接数
    
    [xrdp1]
    
    name=sesman-Xvnc XRDP的连接模式
    
    lib=libvnc.so
    
    username=ask
    
    password=ask
    
    ip=127.0.0.1
    
    port=-1
```

修改 port 为 固定端口号或者 `ask-1`
下次连接不修改即可

注：再记录下 `sesman.ini` 的配置

```bash
    [Globals]
    
    ListenAddress=127.0.0.1 监听ip地址(默认即可)
    
    ListenPort=3350 监听端口(默认即可)
    
    EnableUserWindowManager=1 1为开启,可让用户自定义自己的启动脚本
    
    UserWindowManager=startwm.sh
    
    DefaultWindowManager=startwm.sh
    
    [Security]
    
    AllowRootLogin=1 允许root登陆
    
    MaxLoginRetry=4 最大重试次数
    
    TerminalServerUsers=tSUSErs 允许连接的用户组(如果不存在则默认全部用户允许连接)
    
    TerminalServerAdmins=tsadmins 允许连接的超级用户(如果不存在则默认全部用户允许连接)
    
    [Sessions]
    
    MaxSessions=10 每个用户最大会话数
    
    KillDisconnected=0 是否立即关闭断开的连接(如果为1,则断开连接后会自动注销)
    
    IdleTimeLimit=0 空闲会话时间限制(0为没有限制)
    
    DisconnectedTimeLimit=0 断开连接的存活时间(0为没有限制)
    
    [Logging]
    
    LogFile=./sesman.log 登陆日志文件
    
    LogLevel=DEBUG 登陆日志记录等级(级别分别为,core,error,warn,info,debug)
    
    EnableSyslog=0 是否开启日志
    
    SyslogLevel=DEBUG 系统日志记录等级
```

## 使用浏览器来远程桌面
像阿里云等云服务提供商一样直接在浏览器上进行远程操作

```bash
    docker run  -e REMOTE_HOST=192.168.10.192 -e REMOTE_PORT=5900 -p 8081:8081 -d --restart always --name novnc dougw/novnc
```

打开浏览器 http://host:8081/vnc.html

秀啊！！！
