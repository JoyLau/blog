---
title: Docker OpenVPN 服务搭建记录
date: 2018-11-21 00:29:23
description: 出差在外或者在家工作都需要连接公司网络,没有 VPN 怎么能行
categories: [Docker篇]
tags: [Docker, OpenVPN]
---

<!-- more -->
## OpenVPN 服务端部署

1. 全局变量配置: OVPN_DATA="/home/joylau/ovpn-data"
2. mkdir ${OVPN_DATA} , cd ${OVPN_DATA}
3. 这里我使用的是 tcp, udp 的好像没映射, 我用起来有问题,后来换的 tcp 方式, docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u tcp://公网 IP
4. 初始化,这里的密码我们都设置为 123456, docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
5. 创建用户 liufa , 不使用密码的话在最后面加上 nopass, 使用密码就键入密码,这里我们使用 123456, docker run -v ${OVPN_DATA}:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full liufa nopass
6. 为用户 liufa 生成秘钥, docker run -v ${OVPN_DATA}:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient liufa > ${OVPN_DATA}/liufa.ovpn
7. 运行容器,这里我的宿主机端口为 6001,docker run --name openvpn -v ${OVPN_DATA}:/etc/openvpn -d -p 6001:1194 --privileged kylemanna/openvpn



## OpenVPN 客户端使用说明

![](https://img.shields.io/badge/author-joylau-green.svg)	![](https://img.shields.io/badge/date-2018--11--20-yellow.svg)	![](https://img.shields.io/badge/version-1.0-blue.svg)

### Windows
1. 安装 openVPN windows 客户端，地址：https://swupdate.openvpn.org/community/releases/openvpn-install-2.4.6-I602.exe , 该地址需要梯子
2. 启动客户端，右键，选择 import file, 导入 ovpn 文件，文件请 联系管理员发给你
3. 右键 connect,如果弹出框提示输入密码，输入默认密码 123456 ，等待连接成功即可

### Linux 
1. 安装 openvpn：`sudo yum install openvpn` 或者 `sudo apt install openvpn`
2. 找到 ovpn 文件所在目录： `sudo openvpn --config ./liufa.ovpn`, 看到成功信息时即连接成功
3. 可以用 nohup 以守护进程运行

### MacOS
1. 安装 Tunnelblick，地址：https://tunnelblick.net/
2. 导入 ovpn文件
3. 状态栏上点击连接VPN


## 注意
- 连接上 VPN 后,默认所有流量都⾛的 VPN,但事实上我们并不想这么做. 
-⽐如公司内⽹的⽹段为 192.168.10.0⽹段,我们先删除 2 个 0.0.0.0 的路由: route delete 0.0.0.0 
- 然后添加 0.0.0.0 到本机的⽹段 route add 0.0.0.0 mask 255.255.255.0 本机内⽹⽹段 
-再指定 10 ⽹段⾛ VPN 通道 route add 192.168.10.0 mask 255.255.255.0 VPN ⽹段 
-以上路由添加默认是临时的,重启失效,⽤久保存可加 -p 参数



