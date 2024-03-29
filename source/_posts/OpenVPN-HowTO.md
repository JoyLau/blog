---
title: OpenVPN HOWTO 文档翻译
date: 2020-05-27 11:53:31
description: OpenVPN HOWTO 官方文档翻译
categories: [OpenVPN篇]
tags: [OpenVPN]
---

<!-- more -->

## HOWTO

[OpenVPN](https://openvpn.net/)（OpenVPN官网所有内容需科学上网才能访问）是一个功能齐全的SSL VPN，它使用行业标准的SSL/TLS协议实现了OSI模型第2层（数据链路层）或第3层（网络层）的安全网络扩展。OpenVPN支持基于证书、智能卡以及用户名/密码等多种形式的灵活的客户端认证方法，并可以通过应用于VPN虚拟接口的防火墙规则为指定用户或用户组设置访问控制策略。

原文地址: <https://openvpn.net/community-resources/how-to/>

* [1.1. 安装OpenVPN](#11-安装openvpn)
* [1.2. 选择使用路由还是桥接](#12-选择使用路由还是桥接)
* [1.3. 设置私有子网](#13-设置私有子网)
* [1.4. 创建证书](#14-创建证书)
* [1.5. 创建配置文件](#15-创建配置文件)
* [1.6. 启动VPN并测试](#16-启动vpn并测试)
* [1.7. 系统启动时自动运行](#17-系统启动时自动运行)
* [1.8. 控制运行中的OpenVPN进程](#18-控制运行中的openvpn进程)
* [1.9. 服务器或客户端子网中的其他计算机互相访问](#19-服务器或客户端子网中的其他计算机互相访问)
   * [1.9.1. 防火墙规则](#191-防火墙规则)
* [1.10. 推送DHCP选项到客户端](#110-推送dhcp选项到客户端)
* [1.11. 为指定客户端配置规则和访问策略](#111-为指定客户端配置规则和访问策略)
* [1.12. 使用其他身份验证方式](#112-使用其他身份验证方式)
* [1.13. 使用客户端的智能卡实现双重认证](#113-使用客户端的智能卡实现双重认证)
* [1.14. 路由所有客户端流量通过VPN](#114-路由所有客户端流量通过vpn)
* [1.15. 在动态IP地址上运行OpenVPN服务器](#115-在动态ip地址上运行openvpn服务器)
* [1.16. 通过HTTP代理连接OpenVPN服务器](#116-通过http代理连接openvpn服务器)
* [1.17. 通过OpenVPN连接Samba网络共享服务器](#117-通过openvpn连接samba网络共享服务器)
* [1.18. 实现负载均衡/故障转移的配置](#118-实现负载均衡故障转移的配置)
* [1.19. 增强OpenVPN的安全性](#119-增强openvpn的安全性)
* [1.20. 撤销证书](#120-撤销证书)
* [1.21. 关于中间人攻击的重要注意事项](#121-关于中间人攻击的重要注意事项)

## 1.1. 安装OpenVPN

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#install)

可以[在这里](https://openvpn.net/index.php/open-source/downloads.html)下载OpenVPN源代码和Windows安装程序。最近的版本(2.2及以后版本)也发布了Debian和RPM包(.deb和.rpm)。详情查看[OpenVPN wiki](https://community.openvpn.net/openvpn)。出于安全考虑，建议下载完毕后检查一下文件的[签名信息](https://openvpn.net/index.php/open-source/documentation/sig.html)。OpenVPN可执行文件提供了服务器和客户端的所有功能，因此服务器和客户端都需要安装OpenVPN的可执行文件。

**Linux安装事项（使用RPM包管理工具）**

如果你使用的Linux发行版支持RPM包管理工具，例如：RedHat、CentOS、Fedora、SUSE等。最好使用这种方法来安装。最简单的方法就是找到一个可以在当前Linux发行版上使用的二进制RPM文件。你也可以使用如下命令创建(build)你自己的二进制RPM文件：

```shell
rpmbuild -tb openvpn-[version].tar.gz
```

有了`.rpm`格式的文件，就可以使用如下常规命令来安装它。

```shell
rpm -ivh openvpn-[details].rpm
```

或者升级现有的OpenVPN版本：

```shell
rpm -Uvh openvpn-[details].rpm
```

安装OpenVPN的RPM包，需要如下这些依赖软件包：

* openssl （SSL协议及相关内容的开源实现）
* lzo （无损压缩算法）
* pam （身份验证模块）

此外，如果自己创建(build)二进制RPM包，需要如下几个依赖：

* openssl-devel
* lzo-devel
* pam-devel

可以查看[openvpn.spec](https://openvpn.net/index.php/open-source/documentation/install.html#rpm)文件，该文件包含了在RedHat Linux 9上创建RPM包，或者在减少依赖的情况下创建RPM包的更多信息。

**Linux安装事项（非RPM）**

如果你使用的系统是Debian、Gentoo或其他不基于RPM的Linux发行版，你可以使用当前发行版指定的软件包管理机制，例如Debian的`apt-get`或者Gentoo的`emerge`。

```shell
apt-get install openvpn  # 使用apt-get安装OpenVPN
emerge openvpn  # 使用emerge安装OpenVPN
```

也可以使用常规的`./configure`方法在安装Linux上安装OpenVPN。首先，解压`.tar.gz`文件：

```shell
tar xfz openvpn-[version].tar.gz
```

然后跳转到OpenVPN的顶级目录（`top-level directory`实际上就是OpenVPN解压后的目录），输入：

```shell
./configure
make
make install
```

通过`./configure`方式进行OpenVPN的编译安装之前，仍然需要先安装OpenVPN的依赖软件包`openssl`、`lzo`、`pam`。

**Windows安装事项**

对Windows系统而言，可以直接在下载exe格式的可执行文件来安装OpenVPN。OpenVPN只能够在Windows XP及以上版本的系统中运行。还要注意，必须具备管理员权限才能够安装运行OpenVPN（该限制是Windows自身造成的，而不是OpenVPN）。安装OpenVPN之后，你可以用Windows后台服务的方式启动OpenVPN来绕过该限制；在这种情况下，非管理员用户也能够正常访问VPN。你可以点击查看[关于OpenVPN + Windows权限问题的更多讨论](http://openvpn.se/files/howto/openvpn-howto_run_openvpn_as_nonadmin.html)。

官方版的OpenVPN Windows安装程序自带[OpenVPN GUI](https://community.openvpn.net/openvpn/wiki/OpenVPN-GUI)，OpenVPN GUI允许用户通过一个托盘程序来管理OpenVPN连接。也可以使用其他的[GUI程序](https://community.openvpn.net/openvpn/wiki/OpenVPN-GUI)。

安装OpenVPN之后，OpenVPN将会与扩展名为`.ovpn`的文件进行关联。想要运行OpenVPN，可以：

* 右键点击OpenVPN配置文件`.ovpn`，在弹出的关联菜单中选择【Start OpenVPN on this configuration file】即可使用该配置文件启动OpenVPN。运行OpenVPN后，可以使用快捷键`F4`来退出程序。
* 以命令提示符的方式运行OpenVPN，例如：`openvpn myconfig.ovpn`。运行之后，同样可以使用快捷键`F4`来退出VPN。
* 在OpenVPN安装路径`/config`目录（一般默认为`C:\Program Files\OpenVPN\config`）中放置一个或多个`.ovpn`格式的配置文件，然后启动名为OpenVPN Service的Windows服务。你可以点击【开始】->【控制面板】->【管理工具】->【服务】，从而进入Windows服务管理界面。

**Mac OS X安装事项**

Angelo Laub和Dirk Theisen已经开发出了[OpenVPN GUI for OS X](https://tunnelblick.net/)。

**其他操作系统**

通常情况下，其他操作系统也可以使用`./configure`方法来安装OpenVPN，或者也可以自行查找一个适用于你的操作系统/发行版的OpenVPN接口或安装包。

```shell
./configure
make
make install
```

更多安装说明参阅[这里](https://openvpn.net/index.php/open-source/documentation/install.html?start=1)。

## 1.2. 选择使用路由还是桥接

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#vpntype)

查看“路由 VS. 以太网桥接”的[FAQ](https://community.openvpn.net/openvpn/wiki/FAQ#bridge1)。也可以查看OpenVPN[以太网桥接](https://openvpn.net/index.php/open-source/documentation/miscellaneous/76-ethernet-bridging.html)页面以了解关于桥接的更多事项和细节。

总的来说，对于大多数人而言，“路由模式”可能是更好的选择，因为它可以比“桥接模式”更高效更简单地搭建一个VPN（基于OpenVPN自带的配置）。路由模式还提供了更强大的对指定客户端的访问权限进行控制的能力。

推荐使用“路由模式”，除非你需要用到只有“桥接模式”才具备的某些功能特性，例如：

* VPN需要处理非IP协议，例如IPX。
* 在VPN网络中运行的应用程序需要用到网络广播(network broadcasts)，例如：局域网游戏。
* 你想要在没有Samba或WINS服务器的情况下，能够通过VPN浏览Windows文件共享。

## 1.3. 设置私有子网

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#numbering)

创建一个VPN需要借助私有子网将不同地方的成员连接在一起。

互联网号码分配机构(IANA)专为私有网络保留了以下三块IP地址空间(制定于RFC 1918规范中)：

* 10.0.0.0-10.255.255.255(10/8 prefix)
* 172.16.0.0-172.31.255.255(172.16/12 prefix)
* 192.168.0.0-192.168.255.255(192.168/16 prefix)

在VPN配置中使用这些地址。对选择IP地址并将IP地址冲突或子网冲突的发生概率降到最低而言，这一点非常重要。以下是需要避免的冲突类型：

* VPN中不同的网络场所使用相同的局域网子网编号所产生的冲突。
* 远程访问连接自身使用的私有子网与VPN的私有子网发生冲突。

简而言之，处于不同局域网的客户端和客户端之间，它们自身所在的局域网IP段不要发生冲突；客户端自身所在的局域网IP段也不要和VPN使用的局域网IP段发生冲突。

举个例子，假设你使用了流行的`192.168.0.0/24`作为VPN子网。现在，你尝试在一个网吧内连接VPN，该网吧的WIFI局域网使用了相同的子网。这将产生一个路由冲突，因为计算机不知道`192.168.0.1`是指本地WIFI的网关，还是指VPN上的相同地址。

再举个例子，假设你想通过VPN将多个网络场所连接在一起，但是每个网络场所都使用了`192.168.0.0/24`作为自己的局域网子网。如果不添加一个复杂的NAT翻译层，它们将无法工作。因为这些网络场所没有唯一的子网来标识它们自己，VPN不知道如何在多个网络场所之间路由数据包。

最佳的解决方案是避免使用`10.0.0.0/24`或者`192.168.0.0/24`作为VPN的私有子网。相反，你应该使用一些在你可能连接VPN的场所（例如咖啡厅、酒店、机场）不太可能使用的私有子网。最佳的候选者应该是在浩瀚的`10.0.0.0/8`网络块中间选择一个子网（例如：`10.66.77.0/24`）。

总的来说，为了避免跨多个网络场所的IP编号冲突，请始终使用唯一的局域网子网编号。

## 1.4. 创建证书

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#pki)

以下并非按照原文来的。

可以从发行版软件仓库直接安装，安装后操作如下：

`cd /usr/share/easy-rsa/2.0`

编辑`vars`文件：

```shell
# 密钥长度为2048，如果是1024可改为2048
export KEY_SIZE=2048

# CA证书有效时间3650天，根据需要修改
export CA_EXPIRE=3650

# 密钥有效时间3650天，根据需要修改
export KEY_EXPIRE=3650

export KEY_COUNTRY="CN"  # 国家
export KEY_PROVINCE="SC"  # 省份
export KEY_CITY="CD"  # 城市
export KEY_ORG="x"  # 组织机构
export KEY_EMAIL="x@x.com"  # 邮箱
export KEY_OU="x"  # 单位或部门

export KEY_NAME="OpenVPNServer"  # openvpn服务器的名称
```

`source ./vars`  # 初始化

`./clean-all`  # 清理keys

`./build-ca`  # 生成`ca.crt`和`ca.key`

`./build-key-server server`  # 生成`server.crt`，`server.csr`和`server.key`

`./build-dh`  # 生成`dh2048.pem`

`openvpn --genkey --secret ta.key`  # 生成`ta.key`

keys文件详解可[参考这里](http://www.williamlong.info/archives/3814.html)。

GitHub上的easy-rsa最新版本为easy-rsa3，生成证书命令有一些变化，如下操（有问题可官网查看或运行`./easyrsa help`）：

```shell
wget https://github.com/OpenVPN/easy-rsa/archive/master.zip
unzip master.zip
cd easy-rsa-master/easyrsa3
cp vars.example vars
```

编辑`vars`文件：

```shell
# 取消注释并修改对应内容
set_var EASYRSA_REQ_COUNTRY    "US"  # 国家
set_var EASYRSA_REQ_PROVINCE   "California"  # 省份
set_var EASYRSA_REQ_CITY       "San Francisco"  # 城市
set_var EASYRSA_REQ_ORG        "Copyleft Certificate Co"  # 组织机构
set_var EASYRSA_REQ_EMAIL      "me@example.net"  # 邮箱
set_var EASYRSA_REQ_OU         "My Organizational Unit"  # 单位或部门

set_var EASYRSA_KEY_SIZE       2048  # 密钥长度2048

set_var EASYRSA_CA_EXPIRE       3650  # CA有效期3650天

set_var EASYRSA_CERT_EXPIRE     3650  # CERT有效期3650天

# 客户端使用--ns-cert-type，取消下行注释并改值改为yes，（一般不推荐使用，而推荐使用--remote-cert-tls功能）
#set_var EASYRSA_NS_SUPPORT     "no"

# 其他内容可以根据自己需要修改
```

保存后继续运行，生成服务器端证书：

```shell
./easyrsa init-pki  # 初始化，会清空已有信息，并在当前目录创建PKI目录，用于存储一些中间变量及最终生成的证书
./easyrsa build-ca  # 创建根证书，会提示设置密码，用于ca对之后生成的server和client证书签名时使用，然后提示设置Common Name
./easyrsa gen-req server nopass  # 创建server证书和private key，nopass表示不加密private key，然后提示设置Common Name（使用与上一步不同的）
./easyrsa sign-req server server  # 给server证书签名，确认信息后输入yes，然后输入build-ca时设置的密码
./easyrsa gen-dh  # 创建Diffie-Hellman
```

OpenVPN服务端需要的文件如下：

`easyrsa3/pki/ca.crt`

`easyrsa3/pki/private/server.key`

`easyrsa3/pki/issued/server.crt`

`easyrsa3/pki/dh.pem`

`openvpn --genkey --secret ta.key`  # 生成`ta.key`的命令相同

生成客户端证书（如果客户端不使用证书认证，这一步就不需要了），在与上面生成服务端证书的easy-rsa不同的文件夹重新解压一次（网上查的资料说是在新目录重新生成，不知道可否直接在刚才的目录使用，未测试，如果要测试注意不要再次运行`./easyrsa init-pki`），进入新的`easy-rsa-master/easyrsa3`目录后同样设置一下`vars`文件，然后开始生成证书：

```shell
./easyrsa init-pki
./easyrsa gen-req client1 nopass  # 创建client1证书和private key，nopass表示不加密private key，然后提示设置Country Name（设置与上面不同的）
```

切换到前面生成CA的目录，运行：

```shell
./easyrsa import-req [上一步生成客户端证书的路径]/easyrsa3/pki/reqs/client1.req client1  # 导入req
./easyrsa sign-req client client1  # # 给client1证书签名，确认信息后输入yes，然后输入build-ca时设置的密码
```

文件位置如下：

`easyrsa3/pki/issued/client.crt`

`easyrsa3/pki/private/client.key`

**证书相关文件**

|文件名|谁需要|作用|是否需保密|
|-|-|-|-|
|ca.crt|服务器 + 所有客户端|根CA证书|NO|
|ca.key|密钥签名机|根CA密钥|YES|
|dh{n}.pem|服务器|迪菲·赫尔曼参数|NO|
|server.crt|服务器|服务器证书|NO|
|server.key|服务器|服务器密钥|YES|
|client1.crt|client1|Client1证书|NO|
|client1.key|client1|Client1密钥|YES|
|client2.crt|client2|Client2证书|NO|
|client2.key|client2|Client2密钥|YES|

关于证书、密钥安全性的问题可查看原文。

## 1.5. 创建配置文件

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#config)

**取得示例配置文件**

最好使用[OpenVPN示例配置文件](../2. 配置文件说明.html)作为配置起点。这些文件可以在下列地方找到：

* OpenVPN源代码版的`sample-config-files`目录。
* 如果通过RPM或DEB来安装OpenVPN，则为`/usr/share/doc/packages/openvpn`或`/usr/share/doc/openvpn`中的`sample-config-files`目录。
* Windows系统中的【开始】->【所有程序】->【OpenVPN】->【Shortcuts】->【OpenVPN Sample Configuration Files】，也就是OpenVPN安装路径`/sample-config`目录。

注意：在Linux、BSD或类Unix系统中，示例配置文件叫做`server.conf`和`client.conf`。在Windows中叫做`server.ovpn`和`client.ovpn`。

**编辑服务器端配置文件**

服务器端配置文件示例是OpenVPN服务器端配置的最佳起始点。

该示例配置将使用一个虚拟的TUN网络接口（路由模式），在UDP端口1194（OpenVPN的官方端口号）监听远程连接，并从子网`10.8.0.0/24`中为连接的客户端分配虚拟地址。

在使用示例配置文件之前，先编辑`ca`、`cert`、`key`、`dh`参数，将它们分别指向对应文件。

此时，服务器端配置文件是可用的，但可以进一步自定义该文件：

* 如果你使用的是[以太网桥接](https://openvpn.net/index.php/open-source/documentation/miscellaneous/76-ethernet-bridging.html)模式，必须使用`server-bridge`和`dev tap`指令来替代`server`和`dev tun`指令。
* 如果想让你的OpenVPN服务器监听一个TCP端口，而不是UDP端口，使用`proto tcp`替代`proto udp`（如果想同时监听UDP和TCP端口，必须启动两个单独的OpenVPN实例）。
* 如果你想使用`10.8.0.0/24`范围之外的虚拟IP地址，修改`server`指令。记住，虚拟IP地址范围必须是一个你当前网络未使用的私有范围。
* 如果你想让通过VPN连接的客户端和客户端之间能够互访，启用`client-to-client`指令（去掉注释）。默认情况下，客户端只能够访问服务器。
* 如果你正在使用Linux、BSD或类Unix操作系统，你可以使启用`user nobody`和`group nobody`指令来提高安全性。

如果想要在同一计算机上运行多个OpenVPN实例，每一个示例都应该使用不同的配置文件。可能存在下列情形：

* 每个示例使用不同的端口号（UDP和TCP协议使用不同的端口空间，因此你可以运行一个后台进程并同时监听UDP-1194和TCP-1194）。
* 如果你使用的是Windows系统，每个OpenVPN配置都需要有自己的TAP-Windows适配器。你可以通过【开始】->【所有程序】->【TAP-Windows】->【Add a new TAP-Windows virtual ethernet adapter】来添加一个额外的适配器。
* 如果你运行多个相同目录的OpenVPN实例，请确保编辑那些会创建输出文件的指令，以便于多个实例不会覆盖掉对方的输出文件。这些指令包括`log`、`log-append`、`status`和`ifconfig-pool-persist`。

**编辑客户端配置文件**

客户端配置示例文件（在Linux/BSD/Unix中为`client.conf`，在Windows中为`client.ovpn`）参照了服务器配置示例文件的默认指令设置。

* 与服务器配置文件类似，首先编辑`ca`、`cert`和`key`参数，使它们指向对应文件。注意，每个客户端都应该有自己的证书/密钥对。只有`ca`文件是OpenVPN和所有客户端通用的。
* 下一步，编辑`remote`指令，将其指向OpenVPN服务器的主机名/IP地址和端口号（如果OpenVPN服务器在防火墙或NAT网关之后的单网卡机器上运行，请使用网关的公网IP地址，和你在网关中配置的转发到OpenVPN服务器的端口号）。
* 最后，确保客户端配置文件和用于服务器配置的指令保持一致。主要检查dev（dev或tap）和proto（udp或tcp）指令是否一致。此外，如果服务器和客户端配置文件都使用了`comp-lzo`和`fragment`指令，也需要保持一致。

## 1.6. 启动VPN并测试

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#start)

**启动服务器**

首先，确保OpenVPN服务器能够正常连接网络。这意味着：

* 开启防火墙上的UDP-1194端口（或者你配置的其他端口）。
* 或者，创建一个端口转发规则，将防火墙/网关的UDP-1194端口转发到运行OpenVPN服务器的计算机上。

下一步，[确保TUN/TAP接口没有被防火墙屏蔽](https://community.openvpn.net/openvpn/wiki/FAQ#firewall)。

为了简化故障排除，最好使用命令行来初始化启动OpenVPN服务器（或者在Windows上右击.ovpn文件），而不是以后台进程或服务的方式启动：

```shell
openvpn [服务器配置文件]
```

正常的服务器启动应该像这样：

```shell
Sun Feb  6 20:46:38 2005 OpenVPN 2.0_rc12 i686-suse-linux [SSL] [LZO] [EPOLL] built on Feb  5 2005
Sun Feb  6 20:46:38 2005 Diffie-Hellman initialized with 1024 bit key
Sun Feb  6 20:46:38 2005 TLS-Auth MTU parms [ L:1542 D:138 EF:38 EB:0 ET:0 EL:0 ]
Sun Feb  6 20:46:38 2005 TUN/TAP device tun1 opened
Sun Feb  6 20:46:38 2005 /sbin/ifconfig tun1 10.8.0.1 pointopoint 10.8.0.2 mtu 1500
Sun Feb  6 20:46:38 2005 /sbin/route add -net 10.8.0.0 netmask 255.255.255.0 gw 10.8.0.2
Sun Feb  6 20:46:38 2005 Data Channel MTU parms [ L:1542 D:1450 EF:42 EB:23 ET:0 EL:0 AF:3/1 ]
Sun Feb  6 20:46:38 2005 UDPv4 link local (bound): [undef]:1194
Sun Feb  6 20:46:38 2005 UDPv4 link remote: [undef]
Sun Feb  6 20:46:38 2005 MULTI: multi_init called, r=256 v=256
Sun Feb  6 20:46:38 2005 IFCONFIG POOL: base=10.8.0.4 size=62
Sun Feb  6 20:46:38 2005 IFCONFIG POOL LIST
Sun Feb  6 20:46:38 2005 Initialization Sequence Completed
```

**启动客户端**

和服务器端配置一样，最好使用命令行来初始化启动OpenVPN客户端（在Windows上，也可以直接右击client.ovpn文件），而不是以后台进程或服务的方式来启动。

```shell
openvpn [客户端配置文件]
```

Windows上正常的客户端启动看起来与前面服务器端的输出非常相似，并且应该以`Initialization Sequence Completed`信息作为结尾。

尝试从客户端通过VPN发送`ping`命令。

如果你使用的是路由模式（例如：在服务器配置文件中设置`dev tun`），运行：

```shell
ping 10.8.0.1
```

如果使用桥接模式（例如：在服务器配置文件中设置`dev tap`），尝试ping一个服务器端的以太网子网中的IP地址。

如果能够`ping`成功，那么就连接成功了。

**故障排除**

如果`ping`失败或者无法完成OpenVPN客户端的初始化，这里列出了一个常见问题以及对应解决方案的清单：

1、得到错误信息：`TLS Error: TLS key negotiation failed to occur within 60 seconds (check your network connectivity)`。该错误表明客户端无法与服务器建立一个网络连接。

解决方案：

* 确保客户端配置中使用的服务器主机名/IP地址和端口号是正确的。
* 如果OpenVPN服务器所在计算机只有单个网卡，并处于受保护的局域网内，请确保服务器端的网关防火墙使用了正确的端口转发规则。举个例子，假设你的OpenVPN服务器在某个局域网内，IP为`192.168.4.4`，并在UDP端口1194上监听客户端连接。服务于子网`192.168.4.x`的NAT网关应该有一个端口转发规则，该规则将公网IP地址的UDP端口1194转发到`192.168.4.4`。
* 打开服务器防火墙，允许外部连接通过UDP-1194端口（或者在服务器配置文件中设置的其他端口）。

2、得到错误信息：`Initialization Sequence Completed with errors`。该错误发生在：(a)你的Windows系统没有一个正在运行的DHCP客户端服务，(b)或者你在XP SP2上使用了某些第三方的个人防火墙。

解决方案：

* 启动DHCP客户端服务器，并确保在XP SP2系统中使用的是一个工作正常的个人防火墙。

3、得到信息`Initialization Sequence Completed`但是`ping`测试失败。这通常意味着服务器或客户端的防火墙屏蔽了TUN/TAP接口，从而阻塞了VPN网络。

解决方案：

* 禁用客户端TUN/TAP接口上的防火墙（如果存在的话）。以Windows XP SP2为例，你可以进入【Windows安全中心】->【Windows 防火墙】->【高级】，并取消选中TAP-Windows适配器前面的复选框（从安全角度来说，禁止客户端防火墙屏蔽TUN/TAP接口通常是合理的，这是在告诉防火墙不要阻止可信的VPN流量）。此外，也需要确保服务器的TUN/TAP接口没有被防火墙屏蔽（不得不说的是，选择性地设置服务器端TUN/TAP接口的防火墙有助于提高一定的安全性，请参考访问策略部分）。
* 笔者注：也有可能本身已连通但是`ping`的主机防火墙阻止了ICMP，可以进行相关设置后再尝试

4、当采用UDP协议的配置启动时，出现连接中断，并且服务器日志文件显示下行：

```shell
TLS: Initial packet from x.x.x.x:x, sid=xxxxxxxx xxxxxxxx
```

但客户端的日志文件不会显示相同的信息。

解决方案：

* 你只有一个从客户端到服务器的单向连接。而从服务器到客户端的方向则被（通常是客户端这边的）防火墙阻挡了。该防火墙可能是运行于客户端的个人软件防火墙，或是客户端的NAT路由网关。请修改防火墙以允许从服务器到客户端的UDP数据包返回。

想了解更多额外的故障排除信息，请查看[FAQ](https://community.openvpn.net/openvpn/wiki/FAQ)。

## 1.7. 系统启动时自动运行

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#startup)

关于这个问题并没有所谓的标准答案，也就是说大多数系统都有不同的方式来配置在系统启动时自动运行后台进程/服务。想要默认就具备该功能设置的最佳方式就是以软件包的形式安装OpenVPN，例如通过Linux系统的RPM、DEB或者使用Windows安装程序。

**Linux系统**

如果在Linux上通过RPM或DEB软件包来安装OpenVPN，安装程序将创建一个`initscript`。执行该脚本，`initscript`将会扫描`/etc/openvpn`目录下`.conf`格式的配置文件，如果能够找到，将会为每个文件分别启动一个独立的OpenVPN后台进程。

**Windows系统**

Windows安装程序将会建立一个服务器包装器(Service Wrapper)，不过默认情况下其处于关闭状态。如果想激活它，请进入【控制面板】->【管理工具】->【服务】，然后右键点击"OpenVPN Service"，在弹出的关联菜单中单击【属性】，并将属性面板中的"启动类型"设为"自动"。OpenVPN服务将会在下次重启系统时自动运行。

启动后，OpenVPN服务包装器将会扫描OpenVPN安装路径`/config`文件夹下`.ovpn`格式的配置文件，然后为每个文件启动一个单独的OpenVPN进程。

## 1.8. 控制运行中的OpenVPN进程

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#control)

**运行于Linux/BSD/Unix**

* SIGUSR1  # 有条件的重新启动，设计用于没有root权限的重启
* SIGHUP  # 硬重启
* SIGUSR2  # 输出连接统计信息到日志文件或syslog中
* SIGTERM, SIGINT  # 退出

使用`writepid`指令将OpenVPN的后台进程PID写入到一个文件中，这样你就知道该向哪里发送信号（如果以`initscript`方式启动OpenVPN，该脚本可能已经通过openvpn命令行中的指令--writepid达到了该目的）。

**以GUI形式在Windows上运行**

请查看[OpenVPN GUI页面](https://community.openvpn.net/openvpn/wiki/OpenVPN-GUI)。

**运行于Windows命令提示符窗口**

在Windows中，可以通过右击一个OpenVPN配置文件（.ovpn文件），然后选择“Start OpenVPN on this config file”来启动OpenVPN。

一旦以这种方式运行，你可以使用如下几种按键命令：

* `F1`  # 有条件的重启(无需关闭/重新打开TAP适配器)
* `F2`  # 显示连接统计信息
* `F3`  # 硬重启
* `F4`  # 退出

**以Windows服务方式运行**

在Windows中，当OpenVPN以服务方式启动时，控制方式是：

* 通过服务控制管理器（控制面板->管理工具->服务），其中提供了启动/终止操作。
* 通过管理接口（详情参考下面）。

**修改使用中的OpenVPN配置**

虽然大多数配置更改必须重启服务器才能生效，但仍然有两个指令可以用于文件动态更新，并且能够直接生效而无需重启服务器进程。

* `client-config-dir`  # 该指令设置一个客户端配置文件夹，OpenVPN服务器将会在每个外部连接到来时扫描该目录中的文件，用以查找为当前连接指定的客户端配置文件（详情查看[手册页面](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html)）。该目录中的文件可以随时更新，而无需重启服务器。请注意，该目录中发生的更改只对新的连接起作用，不包括之前已经存在的连接。如果你想通过指定客户端的配置文件更改来直接影响当前正在连接的客户端（或者该连接已经断开，但它在服务器中的实例对象并没有超时），你可以通过管理接口来杀掉该客户端的实例对象（详见下方描述）。这将导致客户端重新连接并使用新的`client-config-dir`文件。
* `crl-verify`  # 该指令指定一个证书撤销列表(CRL)文件，相关描述请参考后面的撤销证书部分。该CRL文件能够在运行中被修改，并且修改可以直接对新的连接或那些正在重新建立SSL/TLS通道的现有连接（默认每小时重新建立一次通道）生效。如果你想杀掉一个证书已经添加到CRL中，但目前已连接的客户端，请使用管理接口（详见下方描述）。

**状态信息文件**

默认的server.conf文件有这样一行：

```shell
status openvpn-status.log
```

OpenVPN将每分钟输出一次当前客户端连接列表到文件openvpn-status.log中。

**使用管理接口**

[OpenVPN管理接口](https://openvpn.net/index.php/open-source/documentation/miscellaneous/79-management-interface.html)可以对正在运行的OpenVPN进程进行大量的控制操作。

你可以通过远程登录管理接口的端口来直接使用管理接口，或者使用连接到管理接口的[OpenVPN GUI](https://community.openvpn.net/openvpn/wiki/OpenVPN-GUI)来间接使用管理接口。

要启用一个服务器或客户端的管理接口，在配置文件中添加如下指令：

```shell
management localhost 7505
```

这将告诉OpenVPN专为管理接口客户端监听TCP端口7505（端口7505是随意的选择，也可以使用其他任何闲置的端口）。

OpenVPN运行后，可以使用`telnet`客户端连接管理接口。例如：

```shell
ai:~ # telnet localhost 7505
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
>INFO:OpenVPN Management Interface Version 1 -- type 'help' for more info
help
Management Interface for OpenVPN 2.4.4 x86_64-redhat-linux-gnu [Fedora EPEL patched] [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Sep 26 2017
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
pkcs11-id-count        : Get number of available PKCS#11 identities.
pkcs11-id-get index    : Get PKCS#11 identity at index.
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
exit
Connection closed by foreign host.
ai:~ #
```

## 1.9. 服务器或客户端子网中的其他计算机互相访问

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#scope)

VPN既然能够让服务器和客户端之间具备点对点的通信能力，那么扩展VPN的作用范围，从而使客户端能够访问服务器所在网络的其他计算机，而不仅仅是服务器自己，也是可能办得到的。

**包含基于桥接模式的VPN服务器端的多台计算机(dev tap)**

使用[以太网桥接](https://openvpn.net/index.php/open-source/documentation/miscellaneous/76-ethernet-bridging.html)的好处之一就是无需进行任何额外的配置就可以实现该目的。

**包含基于桥接模式的VPN客户端的多台计算机(dev tap)**

这需要更加复杂的设置（实际操作可能并不复杂，但详细解释就比较麻烦）：

* 必须将客户端的TAP接口与连接局域网的网卡进行桥接。
* 必须手动设置客户端TAP接口的IP/子网掩码。
* 必须配置客户端计算机使用桥接子网中的IP/子网掩码，这可能要通过[查询OpenVPN服务器的DHCP服务器](https://openvpn.net/index.php/open-source/documentation/install.html?start=1)来完成。

**包含基于路由模式的VPN服务器端的多台计算机(dev tun)**

假设服务器端所在局域网的网段为`10.66.0.0/24`，服务器IP地址为`10.66.0.5`，VPN IP地址池使用`10.8.0.0/24`作为OpenVPN服务器配置文件中`server`指令的传递参数。

首先，你必须声明，对于VPN客户端而言，`10.66.0.0/24`网段是可以通过VPN进行访问的。你可以通过在服务器端配置文件中简单地配置如下指令来实现该目的：

```shell
push "route 10.66.0.0 255.255.255.0"
```

下一步，必须在服务器端的局域网网关创建一个路由，从而将VPN的客户端网段`10.8.0.0/24`路由到OpenVPN服务器（只有OpenVPN服务器和局域网网关不在同一计算机才需要这样做）。

另外，确保已经在OpenVPN服务器所在计算机上启用了[IP](https://community.openvpn.net/openvpn/wiki/FAQ#ip-forward)和[TUN/TAP](https://community.openvpn.net/openvpn/wiki/FAQ#firewall)转发（参考下面内容）。

**包含基于路由模式的VPN客户端的多台计算机(dev tun)**

在典型的远程访问方案中，客户端都是作为单一的计算机连接到VPN。但是，假设客户端计算机是本地局域网的网关（例如一个家庭办公室），并且你想要让客户端局域网中的每台计算机都能够通过VPN。

假设你的客户端局域网网段为`192.168.4.0/24`，客户端IP地址为`192.168.4.10`，VPN客户端使用的证书的Common Name为`client2`。目标是建立一个客户端局域网的计算机和服务器局域网的计算机都能够通过VPN进行相互通讯。

在创建之前，下面是一些基本的前提条件：

* 客户端局域网网段（本例中是`192.168.4.0/24`）不能和VPN的服务器或任意客户端使用相同的网段。每一个以路由方式加入到VPN的子网网段都必须是唯一的。
* 该客户端的证书的Common Name必须是唯一的（本例中是`client2`），并且OpenVPN服务器配置文件不能使用`duplicate-cn`标记。

首先，确保该客户端所在计算机已经启用了IP和TUN/TAP转发。

各操作系统[开启IP和TUN/TAP转发的设置](https://community.openvpn.net/openvpn/wiki/265-how-do-i-enable-ip-forwarding)：

**Windows**（[官网IPEnableRouter相关文章`https://technet.microsoft.com/en-us/library/cc962461.aspx`](https://technet.microsoft.com/en-us/library/cc962461.aspx)）：

注册表编辑器`HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters`将`IPEnableRouter`的值改为`1`；运行`services.msc`将“Routing and Remote Access”设置为自动并启动；

检查：运行`ipconfig -all`，查看“Windows IP 配置”中显示`IP 路由已启用: 是`

**Linux**：

`echo 1 > /proc/sys/net/ipv4/ip_forward`

如果不想重启后失效，运行：

```shell
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p
```

运行`cat /proc/sys/net/ipv4/ip_forward`检查状态。

**OS X**：

`sudo sysctl -w net.inet.ip.forwarding=1`

下一步，需要在服务器端做一些必要的配置更改。如果当前的服务器配置文件没有引用一个客户端配置目录，添加一个：

```shell
client-config-dir ccd
```

在上面的指令中，`ccd`是一个已经在OpenVPN服务器运行的默认目录中预先创建好的文件夹的名称。在Linux中，运行的默认目录往往是`/etc/openvpn`；在Windows中，其通常是OpenVPN安装路径`/config`。当一个新的客户端连接到OpenVPN服务器，后台进程将会检查配置目录（这里是`ccd`）中是否存在一个与连接的客户端的Common Name匹配的文件（这里是`client2`）。如果找到了匹配的文件，OpenVPN将会读取该文件，作为附加的配置文件指令来处理，并应用于该名称的客户端。

下一步就是在`ccd`目录中创建一个名为`client2`的文件。该文件应该包含如下内容：

```shell
iroute 192.168.4.0 255.255.255.0
```

这将告诉OpenVPN服务器：子网网段`192.168.4.0/24`应该被路由到`client2`。

接着，在OpenVPN服务器配置文件（**不是**`ccd/client2`文件）中添加如下指令：

```shell
route 192.168.4.0 255.255.255.0
```

`route`语句控制从系统内核到OpenVPN服务器的路由，`iroute`控制从OpenVPN服务器到远程客户端的路由（不是太懂，照做就可以了）。

下一步，请考虑是否允许`client2`所在的子网（192.168.4.0/24）与OpenVPN服务器的其他客户端进行相互通讯。如果允许，在服务器配置文件中添加如下语句（笔者注：可以在`ccd`对应用户名加入，可以更精确控制使用范围）：

```shell
client-to-client
push "route 192.168.4.0 255.255.255.0"
```

OpenVPN服务器将向其他正在连接的客户端宣告`client2`子网的存在。

最后一步，这也是经常被忘记的一步：在服务器的局域网网关处添加一个路由，用以将`192.168.4.0/24`定向到OpenVPN服务器（如果OpenVPN服务器和局域网网关在同一计算机上，则无需这么做）。假设缺少了这一步，当你从`192.168.4.8`向服务器局域网的某台计算机发送`ping`命令时，这个外部ping命令很可能能够到达目标计算机，但是却不知道如何路由一个`ping`回复，因为它不知道如何达到`192.168.4.0/24`。主要的使用规则是：当全部的局域网都通过VPN时（并且OpenVPN服务器和局域网网关不在同一计算机），请确保在局域网网关处将所有的VPN子网都路由到VPN服务器所在计算机。

类似地，如果OpenVPN客户端和客户端局域网网关不在同一计算机上，请在客户端局域网网关处创建路由，以确保通过VPN的所有子网都能转向OpenVPN客户端所在计算机。

笔者注：上面的看得有点晕，简单介绍下**添加路由**的几种方式：

* 在网关添加路由。如在`10.66.0.0/24`网关处添加一条访问`192.168.4.0/24`时以`10.66.0.5`为网关，在`192.168.4.0/24`网关处添加一条访问`10.66.0.0/24`时以`192.168.4.10`为网关。
* 在其他终端上添加路由表。（服务器所在网段的）Windows如下添加：`route add 192.168.4.0 mask 255.255.255.0 10.66.0.5`，（客户端所在网段的）Windows如下添加：`route add 10.66.0.0 mask 255.255.255.0 192.168.4.10`，如果添加永久路由，使用`-p`参数。其它系统的自行网上找资料。
* （客户端所在网段的）Windows需要添加：`route add 10.8.0.0 mask 255.255.255.0 192.168.4.10`，才能被服务器（或服务器所在网段的其他电脑）访问到。
* 可以综合参考以上方式，来控制加入此互访网络的终端。

### 1.9.1. 防火墙规则

基于路由模式（`dev tun`）时，OpenVPN服务器上防火墙配置（主要是关于防火墙如何工作，熟悉的可以略过了）简要归纳（开放监听端口不在此赘述）：

假设环境如下：

服务端网段`10.66.0.0/24`下设备：OpenVPN服务器IP地址`10.66.0.5`,A服务器（Windows）IP地址`10.66.0.33`

OpenVPN虚拟IP网段`10.8.0.0/24`

客户端网段`192.168.4.0`下设备：OpenVPN客户端IP地址`192.168.4.10`,X终端（Windows）IP地址`192.168.4.66`

1、防火墙不添加任何设置：

只能客户端与服务器互相访问（两者正常情况都可以互相访问，下面不再单独说明，以下所有访问指的使用`ping`测试通过，测试时Windows系统注意关闭防火墙或者设置规则允许ICMP协议入站）

2、防火墙设置：

```shell
*filter
# 允许进tun接口目标为“10.8.0.0/24”的访问
-A FORWARD -o tun+ -d 10.8.0.0/24 -j ACCEPT  # “+”也可改为实际的“tun[n]”，如“tun0”、“tun1”...
# 允许源为“10.8.0.0/24”出tun接口的访问
-A FORWARD -i tun+ -s 10.8.0.0/24 -j ACCEPT
# 如果需要设置指定可以访问的服务器范围，删除上面一行,如下设置
-A FORWARD -i tun+ -s 10.8.0.0/24 -d 10.66.0.33 -j ACCEPT  # OpenVPN客户端不能访问到除10.66.0.33外其他的服务器（如果存在）
```

无其它设置时还是只能客户端与服务器互相访问，在A服务器添加路由表：`route add 10.8.0.0 mask 255.255.255.0 10.66.0.5`（或在服务器网关处添加类似路由，以下所有路由表都可以在网关处添加来替换该步骤，只不过作用范围不同，下面不再单独说明），
OpenVPN客户端和A服务器可以互相访问

3、防火墙设置：

```shell
*nat
# 添加下面一行，OpenVPN服务器可访问的地址，客户端也可以访问
-A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE
# 或如下设置指定网卡（若添指定了网卡，那么OpenVPN服务器自身通过该网卡不能访问的地址，客户端也不能访问）
-A POSTROUTING -o eth0 -s 10.8.0.0/24 -j MASQUERADE

*filter
-A FORWARD -o tun+ -d 10.8.0.0/24 -j ACCEPT
-A FORWARD -i tun+ -s 10.8.0.0/24 -j ACCEPT
```

无其它设置时OpenVPN客户端可以访问到A服务器，A服务器访问不到OpenVPN客户端，在A服务器添加路由表：`route add 10.8.0.0 mask 255.255.255.0 10.66.0.5`，OpenVPN客户端和A服务器可以互相访问

**小结**：

要客户端与服务器所在网段其他设备互相访问需要的防火墙设置为：

```shell
*nat
-A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE  # 可视实际情况（如配置了路由表或是网关配置了路由）选择不配置

*filter
-A FORWARD -o tun+ -d 10.8.0.0/24 -j ACCEPT
-A FORWARD -i tun+ -s 10.8.0.0/24 -j ACCEPT
-A FORWARD -i tun+ -s 10.8.0.0/24 -d 10.66.0.33 -j ACCEPT  # 此规则与上一行选一种来使用
```

firewalld对应命令：

```shell
firewall-cmd --zone=block --add-interface=tun+
firewall-cmd --permanent --zone=block --add-interface=tun+
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s 10.8.0.0/24 -j MASQUERADE
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -o tun+ -d 10.8.0.0/24 -j ACCEPT
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i tun+ -s 10.8.0.0/24 -j ACCEPT
firewall-cmd --direct --add-rule ipv4 filter FORWARD 0 -i tun+ -s 10.8.0.0/24 -m iprange --dst-range 10.66.0.33-10.66.0.50 -j ACCEPT  # 或是指定允许访问的范围
# --direct不能使用--permanent，即使没有报错，重启服务或服务器后，对应的命令也不会生效
```

如果对tun接口的所有流量都允许，可最简（最宽松的防火墙设置，不建议，可根据具体使用场景来综合考虑使用配置）为：

```shell
*nat
-A POSTROUTING -j MASQUERADE

*filter
-A FORWARD -o tun+ -j ACCEPT
-A FORWARD -i tun+ -j ACCEPT
```

以下内容假设服务器已按“包含基于路由模式的VPN客户端的多台计算机”步骤配置好服务器和客户端（除开OpenVPN服务器防火墙相关内容）：

4、防火墙设置：

```shell
*filter
-A FORWARD -o tun+ -d 10.8.0.0/24 -j ACCEPT
-A FORWARD -i tun+ -s 10.8.0.0/24 -j ACCEPT
-A FORWARD -o tun+ -d 192.168.4.0/24 -j ACCEPT
-A FORWARD -i tun+ -s 192.168.4.0/24 -j ACCEPT  # 同样可以加入类似“-d 10.66.0.33”对允许访问的服务器进行限制
```

无其它设置时还是只能客户端与服务器互相访问，在A服务器添加路由表：`route add 192.168.4.0 mask 255.255.255.0 10.66.0.5`，在X终端添加路由表：`route add 10.66.0.0 mask 255.255.255.0 192.168.4.10`，
OpenVPN客户端、X终端、OpenVPN服务器及A服务器可以互相访问

5、一些其他测试：

```shell
*filter
-A FORWARD -o tun+ -d 192.168.4.0/24 -j ACCEPT
-A FORWARD -i tun+ -s 192.168.4.0/24 -j ACCEPT
```

去掉了关于`10.8.0.0/24`的内容，只要添加好了路由表，各设备之间还是可以通过真实局域网IP地址来访问

如果想客户端在服务端的设备不加路由表的情况（单向）访问各服务器，加入：

```shell
-A POSTROUTING -s 192.168.4.0/24 -j MASQUERADE
```

同样如果对tun接口的所有流量都允许，可以简化为：

```shell
*filter
-A FORWARD -o tun+ -j ACCEPT
-A FORWARD -i tun+ -j ACCEPT
```

## 1.10. 推送DHCP选项到客户端

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#dhcp)

OpenVPN服务器能够推送诸如DNS、WINS服务器地址等DHCP选项参数到客户端（这里是一些值得注意的[附加说明](https://community.openvpn.net/openvpn/wiki/FAQ#dhcpcaveats)）。Windows客户端原生就能够接受被推送来的DHCP选项参数，但非Windows系统的客户端需要使用客户端的up脚本才能接受它们，`up`脚本能够解析`foreign_option_n`环境变量列表。请进入[手册页面](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html)或者[OpenVPN用户的邮件列表档案](https://openvpn.net/index.php/open-source/documentation/miscellaneous/61-mailing-lists.html)查看非Windows系统的`foreign_option_n`文档和脚本示例。

举个例子，假如你希望正在连接的客户端使用一个内部的DNS服务器`10.66.0.4`或`10.66.0.5`，和一个WINS服务器`10.66.0.8`，在OpenVPN服务器配置中添加下列语句：

```shell
push "dhcp-option DNS 10.66.0.4"
push "dhcp-option DNS 10.66.0.5"
push "dhcp-option WINS 10.66.0.8"
```

想要在Windows上测试该功能，在客户端连接OpenVPN服务器后，在命令提示符中运行如下命令：

```shell
ipconfig -all
```

其中，“TAP-Windows”部分应该显示服务器推送过来的DHCP选项参数。

## 1.11. 为指定客户端配置规则和访问策略

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#policy)

假设，创建了一个供企业使用的VPN，想要分别为3种不同级别的用户单独设置访问策略：

* 系统管理员 -- 允许访问网络内的所有终端
* 普通职工 -- 只允许访问Samba/Email服务器
* 承包商 -- 只允许访问特定的服务器

所要采取的基本方法是：

* 给不同级别的用户划分不同的虚拟IP地址范围
* 通过设置锁定客户端虚拟IP地址的防火墙规则来控制对计算机的访问。

本例中假设有大量的普通职工，只有1个系统管理员、2个承包商。IP配置方案将会把所有的普通职工放入一个IP地址池中，然后为系统管理员和承包商分配固定的IP地址。

注意：本例的前提条件之一就是有一个运行于OpenVPN服务器所在计算机上的软件防火墙，并具备自定义防火墙规则的能力。这里假定防火墙是Linux系统的iptables。

首先，根据用户级别创建一个虚拟IP地址映射：

|Class|Virtual IP Range|Allowed LAN Access|Common Names|
|-|-|-|-|
|普通职工|10.8.0.0/24|Samba/Email服务器为10.66.4.4|[数量众多]|
|系统管理员|10.8.1.0/24|10.66.4.0/24整个网段|sysadmin1|
|承包商|10.8.2.0/24|承包商服务器为10.66.4.12|contractor1, contracter2|

下一步，将上述映射转换到OpenVPN服务器配置中。首先确保已经遵循了[上述步骤](#19-服务器或客户端子网中的其他计算机互相访问)并将`10.66.4.0/24`网段分配给了所有的客户端（虽然配置允许客户端访问整个`10.66.4.0/24`网段，不过稍后将利用防火墙规则强制添加访问限制来实现上述表格中的访问策略）。

首先，为tun接口定义一个静态的单元编号，以便于稍后在防火墙规则中使用它：

```shell
dev tun0
```

在服务器配置文件中，定义普通职工的IP地址池：

```shell
server 10.8.0.0 255.255.255.0
```

为系统管理员和承包商的IP范围添加路由：

```shell
# 管理员的IP范围
route 10.8.1.0 255.255.255.0
# 承包商的IP范围
route 10.8.2.0 255.255.255.0
```

因为要为指定的系统管理员和承包商分配固定的IP地址，将使用一个客户端配置文件：

```shell
client-config-dir ccd
```

在`ccd`子目录中放置专用的配置文件，为每个非普通职工的VPN客户端定义固定的IP地址。

文件`ccd/sysadmin1`：

```shell
ifconfig-push 10.8.1.1 10.8.1.2
```

文件`ccd/contractor1`：

```shell
ifconfig-push 10.8.2.1 10.8.2.2
```

文件`ccd/contractor2`：

```shell
ifconfig-push 10.8.2.5 10.8.2.6
```

`ifconfig-push`中的每一对IP地址表示虚拟客户端和服务器的IP端点。它们必须从连续的`/30`子网网段中获取（这里是`/30`表示`xxx.xxx.xxx.xxx/30`，即子网掩码位数为30），以便于与Windows客户端和TAP-Windows驱动兼容。明确地说，每个端点的IP地址对的最后8位字节必须取自下面的集合：

```shell
[  1,  2] [  5,  6] [  9, 10] [ 13, 14] [ 17, 18]
[ 21, 22] [ 25, 26] [ 29, 30] [ 33, 34] [ 37, 38]
[ 41, 42] [ 45, 46] [ 49, 50] [ 53, 54] [ 57, 58]
[ 61, 62] [ 65, 66] [ 69, 70] [ 73, 74] [ 77, 78]
[ 81, 82] [ 85, 86] [ 89, 90] [ 93, 94] [ 97, 98]
[101,102] [105,106] [109,110] [113,114] [117,118]
[121,122] [125,126] [129,130] [133,134] [137,138]
[141,142] [145,146] [149,150] [153,154] [157,158]
[161,162] [165,166] [169,170] [173,174] [177,178]
[181,182] [185,186] [189,190] [193,194] [197,198]
[201,202] [205,206] [209,210] [213,214] [217,218]
[221,222] [225,226] [229,230] [233,234] [237,238]
[241,242] [245,246] [249,250] [253,254]
```

完成了OpenVPN的配置，最后一步是添加防火墙规则来完成访问策略。下例使用Linux系统iptables语法的防火墙规则：

```shell
# 普通职工规则
iptables -A FORWARD -i tun0 -s 10.8.0.0/24 -d 10.66.4.4 -j ACCEPT

# 系统管理员规则
iptables -A FORWARD -i tun0 -s 10.8.1.0/24 -d 10.66.4.0/24 -j ACCEPT

# 承包商规则
iptables -A FORWARD -i tun0 -s 10.8.2.0/24 -d 10.66.4.12 -j ACCEPT
```

## 1.12. 使用其他身份验证方式

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#auth)

OpenVPN 2.0及以上版本支持OpenVPN服务器安全地从客户端获取用户名和密码，并以该信息作为客户端身份验证的基础。

使用该身份验证方式，先在客户端配置中添加`auth-user-pass`指令。这使得OpenVPN客户端直接向用户询问用户名/密码，并通过安全的TLS隧道将其传递到服务器。

下一步，配置服务器以使用一个身份验证插件，该插件可以是一个脚本、共享的对象或者DLL文件。在每次客户端尝试连接时，OpenVPN服务器就会调用该插件，并将客户端输入的用户名/密码传递给它。身份验证插件通过返回一个表示失败(1)或成功(0)的值，从而控制OpenVPN是否允许该客户端连接。

**使用脚本插件**

通过在服务器端配置文件中添加`auth-user-pass-verify`指令，可以使用脚本插件。例如：

```shell
auth-user-pass-verify auth-pam.pl via-file
```

将使用名为`auth-pam.pl`的perl脚本来验证正在连接的客户端的用户名/密码。详情请查看[手册页面](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html)中关于`auth-user-pass-verify`的相关描述。

`auth-pam.pl`脚本文件位于OpenVPN源代码发行版的`sample-scripts`子目录中。在Linux服务器上，它将使用PAM认证模块对用户进行身份验证，从而实现shadow密码、RADIUS（远程用户拨入验证服务）或者LDAP（轻量级目录访问协议）验证。`auth-pam.pl`主要用于演示目的。对于实际的PAM验证，请使用下面描述的`openvpn-auth-pam`共享对象插件。

**使用共享对象或DLL插件**

共享对象或DLL插件通常是一个经过编译的C模块，它能够在运行时被OpenVPN服务器加载。如果在Linux系统中使用基于RPM的OpenVPN，`openvpn-auth-pam`插件应该已经创建好了。为了使用该插件，在服务器端配置文件中添加如下语句：

```shell
plugin /usr/share/openvpn/plugin/lib/openvpn-auth-pam.so login
```

这将告诉OpenVPN服务器使用login PAM模块来校验客户端输入的用户名/密码。

对于实际生产环境中，最好使用`openvpn-auth-pam`插件，因为相对使用`auth-pam.pl`脚本而言，它具有以下几个优点：

* 共享对象`openvpn-auth-pam`插件采用更加安全的拆分权限执行模式。这意味着OpenVPN服务器可以运行在使用`user nobody`、`group nobody`和`chroot`等指令来降低权限的情况下，并且能够进行身份验证，而不依赖于只有root用户才能读取的shadow密码文件。
* OpenVPN可以通过虚拟内存将用户名/密码传递给插件，而不是通过一个文件或环境变量，对于服务器计算机而言，具有更好的本地安全性。

如果想了解更多关于开发自己的插件以便与OpenVPN一起使用的信息，请参阅OpenVPN源代码发行版`plugin`子目录中的`README`文件。

在Linux中，为了构建`openvpn-auth-pam`插件，请转到OpenVPN源代码发行版的`plugin/auth-pam`目录，并运行`make`。

**使用用户名/密码认证作为唯一的客户端认证形式**

默认情况下，在服务器上使用`auth-user-pass-verify`或者用户名/密码验证插件将会启用双重身份验证，这使得待验证客户端的客户端证书和用户名/密码验证都必须通过。

也可以禁用客户端证书，而强制只使用用户名/密码验证（从安全角度来说，不鼓励这样做）。在服务器端加入：

```shell
client-cert-not-required
```

通常还需要这样设置：

```shell
username-as-common-name
```

这将告诉服务器优先使用用户名，就像它使用那些通过客户端证书认证的客户端的Common Name一样(也就是说，使用username作为Common Name，用法与之前使用Common Name时相同)。

注意：`client-cert-not-required`并不排除对服务器证书的需要，所以一个客户端连接到使用了`client-cert-not-required`指令的服务器，可以删除客户端配置文件中的`cert`和`key`指令，但不能删除`ca`指令，因为它对于客户端验证服务器端证书来说是必需的。

## 1.13. 使用客户端的智能卡实现双重认证

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#pkcs11)

## 1.14. 路由所有客户端流量通过VPN

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#redirect)

**概述**

默认情况下，当一个OpenVPN客户端处于活动状态时，只有往返于OpenVPN服务器的网络流量才会通过VPN。如一般的网页浏览操作，将绕过VPN，直接连接来完成。

在某些情况下，可能想让VPN客户端所有的网络流量均通过VPN，也包括一般的网络流量。虽然客户端的这种VPN配置将会耗费一些性能，但在客户端同时连接公共网络和VPN时，它给VPN管理员在安全策略上更多的控制能力。

**实施**

在服务器配置文件中添加如下指令：

```shell
push "redirect-gateway def1"
```

如果VPN安装在无线网络上，并且OpenVPN服务器和客户端均处于同一个无线子网中，请添加`local`标记：

```shell
push "redirect-gateway local def1"
```

推送`redirect-gateway`选项命令到客户端，将会导致源自客户端计算机的所有IP网络流量通过OpenVPN服务器。服务器需要进行配置，从而以某种方式处理这些流量，例如：通过NAT转化流量到internet，或者路由通过服务器所在网络场所的HTTP代理。在Linux系统中，你可以使用如下命令将VPN客户端的流量NAT转化到internet：

```shell
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
```

该命令假定VPN子网网段为`10.8.0.0/24`（取自OpenVPN服务器配置的server指令），本地以太网接口为eth0。

当启用了`redirect-gateway`指令，OpenVPN客户端将路由所有的DNS查询经过VPN，VPN服务器需要处理掉这些查询。在VPN活动期间，我们可以通过推送DNS服务器地址到正在连接的客户端上来完成该操作，从而代替常规的DNS服务器设置：

```shell
push "dhcp-option DNS 10.8.0.1"
```

这将配置Windows客户端（或带有额外的服务器端脚本的非Windows客户端）使用`10.8.0.1`作为它们的DNS服务器。任何客户端能够到达的地址都可能作为DNS服务器。

**注意事项**

通过VPN重定向所有网络流量并不是完全没有问题的提议。以下是一些典型的疑难问题：

* 多数连接internet的OpenVPN客户端计算机会定期与DHCP服务器进行交互，并更新它们的IP地址租约。`redirect-gateway`选项命令可能会阻止客户端连接到本地DHCP服务器（因为DHCP信息会被路由通过VPN），从而导致丢失IP地址租约。
* 关于推送DNS地址到Windows客户端[存在一些问题](https://community.openvpn.net/openvpn/wiki/FAQ#dhcpcaveats)。
* 客户端的Web浏览性能将会明显降低。

关于`redirect-gateway`指令的更多信息，请参考[手册页面](https://openvpn.net/index.php/open-source/documentation/manuals/65-openvpn-20x-manpage.html)。

## 1.15. 在动态IP地址上运行OpenVPN服务器

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#dynamic)

总结一句就是使用动态域名解析

## 1.16. 通过HTTP代理连接OpenVPN服务器

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#http)

OpenVPN支持以下列身份认证方式通过HTTP代理进行连接：

* 无需代理身份认证
* 基本(Basic)代理身份认证
* NTLM代理身份认证

首先，HTTP代理的用法要求你必须使用TCP协议作为隧道载体。所以，在客户端和服务器配置中均添加如下语句：

```shell
proto tcp
```

确保删除（或注释）配置文件中的所有`proto udp`指令行。

下一步，在客户端配置文件中添加`http-proxy`指令（请查看[手册页面](http://openvpn.net/man.html)了解该指令的详细描述信息）。

例如，假设客户端局域网有一台`192.168.4.1`的HTTP代理服务器，并监听在`1080`端口。在客户端配置中添加如下语句：

假设HTTP代理要求基本的身份认证：

```shell
http-proxy 192.168.4.1 1080 stdin basic
```

假设HTTP代理要求NTLM身份认证：

```shell
http-proxy 192.168.4.1 1080 stdin ntlm
```

上面的两个身份认证示例将会使OpenVPN提示从标准输入界面输入用户名/密码。如果希望将这些用户凭据放入一个文件中来代替上述输入操作，使用一个文件名来替换语句中的stdin，该文件的第1行应该放用户名，第2行放密码。

## 1.17. 通过OpenVPN连接Samba网络共享服务器

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#samba)

本示例演示OpenVPN是如何通过基于路由的`dev tun`隧道连接到一个Samba共享服务器的。如果使用的是以太网桥接模式(`dev tap`)，你可能不需要遵循下列操作，因为OpenVPN客户端可以在网络邻居中看到服务器端局域网中的计算机。

在本例中假设：

* 服务器端局域网使用子网网段`10.66.0.0/24`
* VPN IP地址池使用`10.8.0.0/24`（作为OpenVPN服务器配置文件中的server指令参数）
* Samba服务器的IP地址为`10.66.0.4`
* Samba服务器已进行配置，从本地局域网能够正常访问

如果Samba和OpenVPN服务器运行于不同的计算机，请确保已经遵循并实现了[扩大OpenVPN使用范围，包含服务器或客户端子网中的其他计算机](#19-服务器或客户端子网中的其他计算机互相访问)。

下一步，编辑Samba配置文件(`smb.conf`)。确保`hosts allow`指令允许来自`10.8.0.0/24`网段的OpenVPN客户端进行连接。例如：

```shell
hosts allow = 10.66.0.0/24 10.8.0.0/24 127.0.0.1
```

如果Samba和OpenVPN服务器运行于同一台计算机，可以编辑`smb.conf`文件中的`interfaces`指令，也监听TUN接口网段`10.8.0.0/24`：

```shell
interfaces  = 10.66.0.0/24 10.8.0.0/24
```

如果Samba和OpenVPN服务器运行于同一台计算机，使用文件夹名称：

```shell
\\10.8.0.1\\sharename
```

如果Samba和OpenVPN服务器位于不同的计算机，使用文件夹名称：

```shell
\\10.66.0.4\sharename
```

例如，从命令提示符窗口中运行：

```shell
net use z: \\10.66.0.4\sharename /USER:myusername
```

## 1.18. 实现负载均衡/故障转移的配置

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#loadbalance)

**客户端配置**

OpenVPN客户端配置可以用于实现负载均衡和故障转移功能的多台服务器。例如：

```shell
remote server1.mydomain
remote server2.mydomain
remote server3.mydomain
```

这将指示OpenVPN客户端按照顺序尝试与server1、server2、server3进行连接。如果现有的连接被中断，OpenVPN客户端将会重新尝试连接最近连接过的服务器；如果连接失败，客户端将会尝试与列表中的下一个服务器进行连接（测试大致会尝试半分钟至1分钟左右后，连接下一个服务器）。也可以指示OpenVPN客户端在启动时随机连接列表中的一个服务器，以便于客户端负载能够均等概率地覆盖服务器池。

```shell
remote-random
```

如果也希望在DNS解析失败时，让OpenVPN客户端移至列表中的下一个服务器，添加如下命令：

```shell
resolv-retry 60
```

参数`60`告诉OpenVPN客户端，在移至下一个服务器之前，尝试解析每个`remote`的DNS名称60秒（即60秒内都无法解析成功，就移至下一个服务器）。

服务器列表还可以引用运行于同一计算机上的多个OpenVPN服务器进程（每个进程监听不同的端口），例如：

```shell
remote smp-server1.mydomain 8000
remote smp-server1.mydomain 8001
remote smp-server2.mydomain 8000
remote smp-server2.mydomain 8001
```

如果服务器有多个处理器，每台计算机运行多个OpenVPN后台进程有利于提高性能表现。

OpenVPN也支持`remote`指令引用在域名配置中拥有多个A记录的DNS名称。在这种情况下，在每次域名被解析时，OpenVPN客户端将会随机选择一个A记录。

**服务器端配置**

除了每个服务器使用不同的虚拟IP地址池之外，为集群中的每个服务器使用相同的配置文件，是在服务器端实现负载均衡/故障转移配置的最简单方法。例如：

server1：

```shell
server 10.8.0.0 255.255.255.0
```

server2：

```shell
server 10.8.1.0 255.255.255.0
```

server3：

```shell
server 10.8.2.0 255.255.255.0
```

## 1.19. 增强OpenVPN的安全性

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#security)

一个经常被重复提及的网络安全准则就是：不要过分相信一个单一的安全组件，否则它的失败将导致灾难性的安全漏洞。OpenVPN提供多种机制来添加额外的安全层，以避免这样的结果。

**tls-auth**

`tls-auth`指令为所有的SSL/TLS握手数据包添加一个额外的HMAC签名，以验证数据的完整性。无需进一步处理，没有正确的HMAC签名的任何UDP数据包将会被丢弃。`tls-auth` HMAC签名提供了上面所说的额外安全级别，而不是通过SSL/TLS来提供。它可以防御：

* Dos攻击或者UDP端口淹没攻击。
* 确定服务器UDP端口监听状态的端口扫描。
* SSL/TLS实现的缓冲区溢出漏洞。
* 启动来自未经授权机器的SSL/TLS握手（虽然这样的握手最终会验证失败，但`tls-auth`可以更早地断开）。

除了使用标准的RSA证书/密钥之外，使用`tls-auth`还需要生成一个共享的密钥：

```shell
openvpn --genkey --secret ta.key
```

该命令将生成一个OpenVPN静态密钥，并将其写入到`ta.key`文件中。该密钥应该通过已有的安全通道拷贝到服务器和所有的客户端。它应该与RSA的`.key`和`.crt`文件放在同一目录。

在服务器配置中，添加：

```shell
tls-auth ta.key 0
```

在客户端配置中，添加：

```shell
tls-auth ta.key 1
```

**proto udp**

虽然OpenVPN允许使用TCP或者UDP协议作为VPN的连接载体，但UDP协议能够比TCP提供更好的Dos攻击和端口扫描防护：

```shell
proto udp
```

**user/group（仅限于非Windows系统）**

OpenVPN经过非常仔细的设计，以允许在初始化后丢弃掉root权限，该特性可以在Linux/BSD/Solaris系统中一直使用。

对于攻击者而言，没有root权限，运行中的OpenVPN服务器进程就不是一个有吸引力的目标。

```shell
user nobody
group nobody
```

**非特权模式（仅限于Linux系统）**

在Linux系统中，OpenVPN可以完全没有特权地正常运行。虽然配置上会稍稍麻烦一点，但却能带来最佳的安全性。

为了使用这种配置来运行，OpenVPN必须配置为使用`iproute`接口，这可以通过为`configure`脚本指定`--enable-iproute2`参数来完成。系统也需要有`sudo`软件包。

该配置使用Linux自身的能力来更改tun设备的权限，以便于非特权的用户也可以访问它。为了执行`iproute`，也需要使用`sudo`，从而使得接口属性和路由表可以被修改。

OpenVPN配置：

* 重写并覆盖位于`/usr/local/sbin/unpriv-ip`的以下脚本文件：

```shell
#!/bin/sh
sudo /sbin/ip $*
```

* 执行`visudo`，添加如下命令以允许用户"user1"执行`/sbin/ip`：

```shell
user1 ALL=(ALL)  NOPASSWD: /sbin/ip
```

也可以通过如下命令启用一个用户组：

```shell
%users ALL=(ALL)  NOPASSWD: /sbin/ip
```

* 在OpenVPN配置中添加如下语句：

```shell
dev tunX/tapX
iproute /usr/local/sbin/unpriv-ip
```

注意：必须选择常量X（一般用数字标记，例如：tunX实际为tun0），并且不能同时指定tun或tap。

* 使用root添加持久化接口，允许用户或用户组来管理它，下面的命令会创建`tunX`，并且允许user1和用户组访问它：

```shell
openvpn --mktun --dev tunX --type tun --user user1 --group users
```

* 在非特权用户的上下文环境中运行OpenVPN。

可以通过核查脚本文件`/usr/local/sbin/unpriv-ip`的参数来添加进一步的安全约束。

**chroot（仅限于非Windows系统）**

`chroot`指令允许将OpenVPN后台进程锁定到所谓的`chroot jail`（chroot监狱）中，除了该指令参数给出的指定目录外，`chroot jail`中的进程无法访问主机系统的文件系统的任何部分。例如：

```shell
chroot jail
```

将导致OpenVPN进程在初始化时转到jail子目录，然后将它的根文件系统调整为该目录，进程将无法访问jail和它的子目录树以外的任何文件。从安全角度来说，这很重要，因为即使攻击者能够使用代码插入攻击入侵服务器，攻击也会被锁定在服务器的大部分文件系统之外。

注意事项：由于chroot调整了文件系统（仅从后台进程的角度来看），因此有必要将OpenVPN初始化后可能用到的文件放入jail目录中，例如：

* 文件`crl-verify`
* 或者目录`client-config-dir`

**更大的RSA密钥**

我们可以通过文件`easy-rsa/vars`中的`KEY_SIZE`变量来控制RSA密钥的大小，该变量必须在所有密钥生成之前进行设置。如果默认设置为`1024`，可以合理地提高到`2048`，这对VPN隧道的性能没有什么负面影响，除了稍稍减缓每个客户端每小时一次的SSL/TLS重新协商握手速度，和大幅减慢使用脚本`easy-rsa/build-dh`生成迪菲赫尔曼参数的一次性过程之外。

**更大的对象密钥**

默认情况下，OpenVPN使用128位对称加密算法`Blowfish`。

OpenVPN自动支持OpenSSL库支持的任何加密算法，同样支持使用更大密钥长度的加密算法。例如，通过在服务器和客户端配置文件中均添加如下语句来使用256位版本的AES（Advanced Encryption Standard，高级加密标准）：

```shell
cipher AES-256-CBC
```

**将根密钥（`ca.key`）保留在一台没有网络连接的计算机上**

使用X509 PKI（OpenVPN也使用）的安全好处之一就是，根CA密钥（`ca.key`）不需要放在当前OpenVPN服务器所在计算机上。在一个高度安全的环境中，可以特别指定一台计算机用于密钥签名，让该计算机受到良好的保护，并断开所有的网络。必要时，可以使用软盘（这个可能已经绝迹了吧）来回移动该密钥文件。这些措施使得攻击者想要窃取根密钥变得非常困难（对于密钥签名计算机的物理盗窃除外）。

## 1.20. 撤销证书

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#revoke)

**撤销一个证书**就是让一个已签名的证书作废，以便其无法再用于身份认证。

想要撤销一个证书的典型原因包括：

* 与证书关联的私钥被泄露或被窃取。
* 加密私钥的用户忘记了密码。
* 你想要终止某个VPN用户的访问。

例如撤销证书`client2`，该证书是前面的操作指南的“[生成密钥](#14-创建证书)”部分生成的。

首先，打开shell或命令提示符窗口，转到之前“生成密钥”部分操作过的`easy-rsa`目录。在Linux/BSD/Unix系统中：

```shell
. ./vars
./revoke-full client2
```

在Windows系统中：

```shell
vars
revoke-full client2
```

可以看到类似这样的输出：

```shell
Using configuration from /root/openvpn/20/openvpn/tmp/easy-rsa/openssl.cnf
DEBUG[load_index]: unique_subject = "yes"
Revoking Certificate 04.
Data Base Updated
Using configuration from /root/openvpn/20/openvpn/tmp/easy-rsa/openssl.cnf
DEBUG[load_index]: unique_subject = "yes"
client2.crt: /C=KG/ST=NA/O=OpenVPN-TEST/CN=client2/emailAddress=me@myhost.mydomain
error 23 at 0 depth lookup:certificate revoked
```

注意最后一行的`error 23`表明已被撤销的证书的证书校验失败（即撤销成功）。

`revoke-full`脚本将会在`keys`子目录中生成一个叫做`crl.pem`的CRL（证书撤销列表）文件。该文件应该被复制到一个OpenVPN服务器可以访问的目录，然后在服务器配置中启用CRL验证：

```shell
crl-verify crl.pem
```

现在，所有正在连接的客户端的证书会与CRL进行比对校验，任何正匹配都将导致该连接被丢失。

**CRL注意事项**

* 当OpenVPN使用`crl-verify`选项命令后，任何新的客户端连接或者现有客户端重新建立SSL/TLS连接（默认每小时一次）都将使得CRL文件被重新读取。这意味着，即使OpenVPN服务器后台进程正在运行，你也可以更新你的CRL文件，新的CRL文件将会对新连接的客户端直接生效。如果一个刚刚撤销了证书的客户端早已经连接到服务器，你可以通过一个信号（SIGUSR1或者SIGHUP）来重启服务器，并刷新所有的客户端，或者你可以远程登录[管理接口](https://openvpn.net/management.html)，明确杀掉服务器上指定的客户端实例对象，而不干扰其他客户端。

* 虽然OpenVPN服务器和客户端都可以使用`crl-verify`指令，但通常不必将CRL文件分发到客户端，除非服务器证书已被撤销。客户端不需要知道其他哪些客户端的证书已被撤销，因为[客户端不应该直接接受来自其他客户端的连接](#121-关于中间人攻击的重要注意事项)。

* CRL文件无需保密，并且应该设为所有用户可读，以便于OpenVPN进程在没有root权限的情况下能够读取该文件。

* 如果使用`chroot`指令，请确保在`chroot`目录放置一份CRL文件的拷贝，因为不像OpenVPN读取的其他大多数文件，CRL将会在执行`chroot`调用之后被读取，而不是在此之前。

* 需要撤销证书的一个常见原因是，用户使用密码加密了自己的私钥，然后忘记了密码。通过撤销原来的证书，用户也可以使用原来的`Common Name`来生成新的证书/密钥对。

## 1.21. 关于中间人攻击的重要注意事项

[英文原文](https://openvpn.net/index.php/open-source/documentation/howto.html#secnotes)

如果客户端不验证他们正在连接的服务器的证书，可能的“中间人”攻击。

为了避免授权客户端通过冒充的服务器尝试连接到另一个客户端的可能的中间人攻击，务必强制客户端进行某种类型的服务器证书验证。目前有五种不同的方式来完成这一点，按优先顺序排列：

* **OpenVPN 2.1 及以上版本**使用指定的密钥用法和扩展密钥用法来创建服务器证书。RFC3280确定了应该为TLS连接提供下列属性：

|模式|密钥用法|扩展密钥用法|
|-|-|-|
|客户端|数字签名|TLS Web客户端认证|
|客户端|密钥协议|TLS Web客户端认证|
|客户端|数字签名，密钥协议|TLS Web客户端认证|
|服务器|数字签名，密钥加密|TLS Web服务器认证|
|服务器|数字签名，密钥协议|TLS Web服务器认证|

可以使用`build-key-server`脚本来创建服务器证书（详情请查看[easy-rsa](https://openvpn.net/easyrsa.html)文档）。通过设置正确的属性，指定证书作为一个服务器端证书。在客户端配置中添加如下语句：

```shell
remote-cert-tls server
```

* **OpenVPN 2.0 及以下版本**使用`build-key-server`脚本来创建服务器证书（详情请查看[easy-rsa](https://openvpn.net/easyrsa.html)文档）。通过设置`nsCertType=server`，指定该证书作为服务器端证书。在客户端配置中添加如下语句： 

```shell
ns-cert-type server
```

这将阻止客户端连接任何没有在证书中指定`nsCertType=server`的服务器，即使该证书已经通过OpenVPN配置文件中的`ca`文件进行了签名。

* 在客户端使用`tls-remote`指令，根据服务器证书的`Common Name`来判断接受或拒绝该服务器连接。

* 使用`tls-verify`脚本或插件，根据服务器证书的嵌入式X509附属条目中的自定义测试来判断接受/拒绝该服务器连接。

* 使用一个CA给服务器证书签名，使用另一个不同的CA给客户端证书签名。客户端配置的ca指令应该引用为服务器签名的CA文件，而服务器配置的ca指令应该引用为客户端签名的CA文件。




