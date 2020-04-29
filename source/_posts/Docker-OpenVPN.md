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



