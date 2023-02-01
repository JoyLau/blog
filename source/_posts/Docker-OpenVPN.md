---
title: Docker OpenVPN 服务搭建记录
date: 2018-11-21 00:29:23
description: 出差在外或者在家工作都需要连接公司网络,没有 VPN 怎么能行
categories: [Docker篇]
tags: [Docker, OpenVPN]
---

<!-- more -->
## 背景

出差在外或者在家工作都需要连接公司网络,没有 VPN 怎么能行

## OpenVPN 服务端部署

1. 全局变量配置: OVPN_DATA="/home/joylau/ovpn-data"
2. `mkdir ${OVPN_DATA}` , `cd ${OVPN_DATA}`
3. 这里我使用的是 tcp, udp 的好像没映射, 我用起来有问题,后来换的 tcp 方式, `docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u tcp://公网 IP`
4. 初始化,这里的密码我们都设置为 123456, `docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki`
5. 创建用户 liufa , 不使用密码的话在最后面加上 nopass, 使用密码就键入密码,这里我们使用 123456, `docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full liufa`
6. 为用户 liufa 生成秘钥, `docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient liufa > ${OVPN_DATA}/liufa.ovpn`
7. 创建的文件中端口默认使用的是 1194, 而我用的是 6001,那我们还得修改下 liufa.ovpn 文件的端口
8. 运行容器,这里我的宿主机端口为 6001, `docker run --name openvpn -v ${OVPN_DATA}:/etc/openvpn -d -p 6001:1194 --privileged kylemanna/openvpn`


## OpenVPN 管理接口
服务端配置文件加入 management 0.0.0.0 5555

可以使用 telnet ip 5555 来使用管理接口, 输入 help 查看详细命令, 具体如下:

```shell
    Commands:
    auth-retry t           : Auth failure retry mode (none,interact,nointeract).
    bytecount n            : Show bytes in/out, update every n secs (0=off).
    echo [on|off] [N|all]  : Like log, but only show messages in echo buffer.
    exit|quit              : Close management session.
    forget-passwords       : Forget passwords entered so far.
    help                   : Print this message.
    hold [on|off|release]  : Set/show hold flag to on/off state, or
                             release current hold and start tunnel.
    kill cn                : Kill the client instance(s) having common name cn.
    kill IP:port           : Kill the client instance connecting from IP:port.
    load-stats             : Show global server load stats.
    log [on|off] [N|all]   : Turn on/off realtime log display
                             + show last N lines or 'all' for entire history.
    mute [n]               : Set log mute level to n, or show level if n is absent.
    needok type action     : Enter confirmation for NEED-OK request of 'type',
                             where action = 'ok' or 'cancel'.
    needstr type action    : Enter confirmation for NEED-STR request of 'type',
                             where action is reply string.
    net                    : (Windows only) Show network info and routing table.
    password type p        : Enter password p for a queried OpenVPN password.
    remote type [host port] : Override remote directive, type=ACCEPT|MOD|SKIP.
    proxy type [host port flags] : Enter dynamic proxy server info.
    pid                    : Show process ID of the current OpenVPN process.
    client-auth CID KID    : Authenticate client-id/key-id CID/KID (MULTILINE)
    client-auth-nt CID KID : Authenticate client-id/key-id CID/KID
    client-deny CID KID R [CR] : Deny auth client-id/key-id CID/KID with log reason
                                 text R and optional client reason text CR
    client-kill CID [M]    : Kill client instance CID with message M (def=RESTART)
    env-filter [level]     : Set env-var filter level
    client-pf CID          : Define packet filter for client CID (MULTILINE)
    rsa-sig                : Enter an RSA signature in response to >RSA_SIGN challenge
                             Enter signature base64 on subsequent lines followed by END
    certificate            : Enter a client certificate in response to >NEED-CERT challenge
                             Enter certificate base64 on subsequent lines followed by END
    signal s               : Send signal s to daemon,
                             s = SIGHUP|SIGTERM|SIGUSR1|SIGUSR2.
    state [on|off] [N|all] : Like log, but show state history.
    status [n]             : Show current daemon status info using format #n.
    test n                 : Produce n lines of output for testing/debugging.
    username type u        : Enter username u for a queried OpenVPN username.
    verb [n]               : Set log verbosity level to n, or show if n is absent.
    version                : Show current version number.
    END
    

```


## OpenVPN 客户端使用说明

![](https://img.shields.io/badge/author-joylau-green.svg)	![](https://img.shields.io/badge/date-2018--11--20-yellow.svg)	![](https://img.shields.io/badge/version-1.0-blue.svg)

### Windows
1. 安装 openVPN windows 客户端，地址：https://swupdate.openvpn.org/community/releases/openvpn-install-2.4.6-I602.exe , 该地址需要梯子
2. 启动客户端，右键，选择 import file, 导入 ovpn 文件，文件请 联系管理员发给你
3. 右键 connect,如果弹出框提示输入密码，输入默认密码 123456 ，等待连接成功即可

### Linux 
1. 安装 openvpn：`sudo yum install openvpn` 或者 `sudo apt install openvpn`
2. 找到 ovpn 文件所在目录： `sudo openvpn --config ./liufa.ovpn`, 看到成功信息时即连接成功
3. `--daemon` 参数以守护进程运行
4. 或者写个 service 文件以守护进程并且开机启动运行

#### GUI 客户端 [2020-04-29更新]
可以使用开源客户端工具： [pritunl-client-electron](https://client.pritunl.com/#features)
安装方法：
Ubuntu 16.04:

```bash
    sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
    deb http://repo.pritunl.com/stable/apt xenial main
    EOF
    
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
    sudo apt-get update
    sudo apt-get install pritunl-client-electron
```

注意 apt 安装需要科学上网来设置代理

或者从 GitHub 上下载软件包： https://github.com/pritunl/pritunl-client-electron/releases

### MacOS
1. 安装 Tunnelblick，地址：https://tunnelblick.net/
2. 导入 ovpn文件
3. 状态栏上点击连接VPN


## 路由设置
连接上 VPN 后,默认所有流量都走的 VPN,但事实上我们并不想这么做

### Windows 上路由手动配置

- ⽐如公司内网的网段为 192.168.10.0 网段,我们先删除 2 个 0.0.0.0 的路由: `route delete 0.0.0.0 `
- 然后添加 0.0.0.0 到本机的网段 `route add 0.0.0.0 mask 255.255.255.0 本机内网网关` 
- 再指定 10 网段走 VPN 通道 `route add 192.168.10.0 mask 255.255.255.0 VPN 网关`
- 以上路由添加默认是临时的,重启失效,⽤久保存可加 -p 参数

### OpenVPN 服务端配置
修改配置文件 `openvpn.conf`
在 

``` bash
    ### Route Configurations Below
    route 192.168.254.0 255.255.255.0
```

下面添加路由即可， 客户端连接时会收到服务端推送的路由

### OpenVPN 客户端设置
很多时候我们希望自己的客户端能够自定义路由，而且更该服务端的配置并不是一个相对较好的做法

找到我们的 ovpn 配置文件 

到最后一行

`redirect-gateway def1`
即是我们全部流量走 VPN 的配置

#### route-nopull
客户端加入这个参数后,OpenVPN 连接后不会添加路由,也就是不会有任何网络请求走 OpenVPN

#### vpn_gateway
当客户端加入 `route-nopull` 后,所有出去的访问都不从 OpenVPN 出去,但可通过添加 vpn_gateway 参数使部分IP访问走 OpenVPN 出去

```bash
    route 192.168.255.0 255.255.255.0 vpn_gateway
    route 192.168.10.0 255.255.255.0 vpn_gateway
```

#### net_gateway
和 `vpn_gateway` 相反,他表示在默认出去的访问全部走 OpenVPN 时,强行指定部分 IP 访问不通过 OpenVPN 出去

```bash
    max-routes 1000 # 表示可以添加路由的条数,默认只允许添加100条路由,如果少于100条路由可不加这个参数
    route 172.121.0.0 255.255.0.0 net_gateway
```

## 客户端互相访问
1. 配置 client-to-client
2. 192.168.255.0 的路由要能够走VPN通道, 可以配置 `redirect-gateway def1` 或者 `route-nopull  route 192.168.255.0 255.255.255.0 vpn_gateway`


### OpenVPN 服务端配置静态 ip
1. 配置文件配置 `ifconfig-pool-persist /etc/openvpn/ipp.txt 0`

ipp.txt 文件的格式

```text
    user1,192.168.255.10
    user2,192.168.255.11
    user3,192.168.255.12
```

经自己测试， 该方式配置静态 IP 没生效，实际得到的 IP 会大 2 位


2. 配置文件配置 `client-config-dir ccd`

然后在 ccd 目录下以用户名为文件名命名，写入内容： `ifconfig-push 192.168.255.10 255.255.255.0` 来为单个用户配置 IP



