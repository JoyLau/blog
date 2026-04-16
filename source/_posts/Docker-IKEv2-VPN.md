---
title: Docker 搭建 IKEv2/IPSec EAP VPN 服务端
date: 2026-04-16 12:00:00
description: 记录下使用 Docker 搭建 StrongSwan IKEv2 EAP VPN 的过程，中间踩了不少坑
categories: [Docker篇]
tags: [Docker, VPN, StrongSwan, IKEv2]
---

## 说明

IKEv2 相比其他 VPN 协议的优势：
- Windows/macOS/iOS/Android 原生支持，无需安装额外客户端

### StrongSwan 配置方式说明

StrongSwan 在 Ubuntu/Debian 上有两种配置方式：

| 方式 | 配置文件 | 启动服务 | 安装的包 |
|------|----------|----------|----------|
| 传统方式 | `/etc/ipsec.conf` | `strongswan-starter.service` | `strongswan` 元包 |
| 现代方式 | `/etc/swanctl/swanctl.conf` | `strongswan.service` | `charon-systemd` + `strongswan-swanctl` |

这里需要注意的是：
    - **不要同时安装两种方式**，否则会有两个 systemd 服务冲突
    - 我这里使用的是**传统方式**（ipsec.conf 配置）
    - 传统方式配置更简单，文档资料更丰富，适合入门使用

<!-- more -->

## 环境

- 系统：Ubuntu 26.04
- Docker：已安装
- VPN 类型：IKEv2 EAP (MSCHAPv2)

## 宿主机内核要求

Docker 方式部署 StrongSwan 需要宿主机内核支持 XFRM（IPSec 协议栈），检查方法：

```bash
# 无报错即支持
ip xfrm state list
```

大部分现代 Linux 内核都支持，如果报错说明内核不支持，需要升级或更换内核。

## 项目目录结构

```
joyfay-strongswan/
├── Dockerfile
├── docker-compose.yml
└── config/
    ├── ipsec.conf          # VPN 配置
    ├── ipsec.secrets       # 用户账号
    └── certs/              # 证书目录
        ├── private/
        │   ├── ca.key      # CA 私钥
        │   └── server.key  # 服务器私钥
        ├── cacerts/
        │   └── ca.crt      # CA 证书
        └── certs/
            └── server.crt  # 服务器证书
```

## 在宿主机上生成证书

证书需要在部署前生成，我这里使用 Docker 镜像临时运行来生成，避免在宿主机安装额外工具。

### 创建证书目录

```bash
mkdir -p config/certs/{private,cacerts,certs}
```

### 使用 Docker 镜像生成证书

先替换 YOUR_PUBLIC_IP 为你的公网 IP

```bash
docker run --rm -v $(pwd)/config/certs:/certs joyfay/joyfay-strongswan:latest bash -c "

# CA 私钥
pki --gen --type rsa --size 4096 --outform pem > /certs/private/ca.key

# CA 证书（有效期 10 年）
pki --self --ca --lifetime 3650 \
    --in /certs/private/ca.key \
    --type rsa \
    --dn 'CN=JOYLAU CA' \
    --outform pem > /certs/cacerts/ca.crt

# 服务器私钥
pki --gen --type rsa --size 4096 --outform pem > /certs/private/server.key

# 服务器证书（有效期 5 年，替换 YOUR_PUBLIC_IP）
pki --pub --in /certs/private/server.key --type rsa \
    | pki --issue --lifetime 1825 \
        --cacert /certs/cacerts/ca.crt \
        --cakey /certs/private/ca.key \
        --dn 'CN=YOUR_PUBLIC_IP' \
        --san 'YOUR_PUBLIC_IP' \
        --outform pem > /certs/certs/server.crt

chmod 600 /certs/private/*.key
"

```

这里需要注意的是：
    - 服务器证书的 `CN` 和 `SAN` 必须使用公网 IP，客户端连接时会校验

## 配置文件

### ipsec.conf

替换 YOUR_PUBLIC_IP 为你的公网 IP

```bash
cat > config/ipsec.conf << 'EOF'
config setup
    charondebug="ike 2, knl 2, cfg 2"
    uniqueids=no

conn ikev2-eap
    keyexchange=ikev2
    ike=aes256-sha256-modp2048,aes128-sha256-modp2048,aes256-sha1-modp2048,aes256-sha256-ecp256!
    esp=aes256-sha256,aes128-sha256,aes256-sha1!
    left=%any
    leftid=YOUR_PUBLIC_IP
    leftcert=server.crt
    leftsendcert=always
    leftsubnet=192.168.1.0/24
    right=%any
    rightid=%any
    rightauth=eap-mschapv2
    rightsourceip=10.10.10.0/24
    rightdns=223.5.5.5,114.114.114.114
    eap_identity=%identity
    auto=add
EOF
```

这里需要注意的是：
    - `leftid` 使用公网 IP，必须与证书中的 CN 一致

关于 `leftsubnet` 的选择：
    - `0.0.0.0/0`：所有流量走 VPN，包括互联网流量
    - `192.168.1.0/24`：只推送内网路由，互联网流量走客户端本地网络
    - 如果要推送多个网段：`192.168.1.0/24,172.16.1.0/24`

我这里选择只推送内网路由，这样 VPN 客户端访问内网资源走 VPN，访问互联网走本地网络，不会影响日常上网。

### ipsec.secrets

```bash
cat > config/ipsec.secrets << 'EOF'
# 服务器证书私钥
: RSA server.key

# EAP 用户账号
"vpnuser1" : EAP "your_password"
"vpnuser2" : EAP "another_password"
EOF
```

添加更多用户只需追加新行即可，格式为 `"用户名" : EAP "密码"`。

## Dockerfile

```dockerfile
FROM ubuntu:26.04

LABEL maintainer="joylau"
LABEL description="StrongSwan IKEv2 VPN Server"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    strongswan-starter \
    strongswan-pki \
    libcharon-extra-plugins \
    libstrongswan-extra-plugins \
    iptables \
    iproute2 \
    iputils-ping \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/ipsec.d/private \
    /etc/ipsec.d/cacerts \
    /etc/ipsec.d/certs

# 创建启动脚本（使用 iptables-legacy）
RUN printf '#!/bin/bash\n\
iptables-legacy -t nat -A POSTROUTING -s 10.10.10.0/24 -j MASQUERADE\n\
iptables-legacy -I FORWARD -s 10.10.10.0/24 -j ACCEPT\n\
iptables-legacy -I FORWARD -d 10.10.10.0/24 -j ACCEPT\n\
ipsec start --nofork\n' > /start.sh && chmod +x /start.sh

EXPOSE 500/udp 4500/udp

CMD ["/start.sh"]
```

这里需要重点说明的是启动脚本中使用 `iptables-legacy` 而不是普通 `iptables`：

Ubuntu 26.04 默认使用 **nftables** 作为防火墙后端，但 strongSwan 与 nftables 存在兼容性问题，在某些场景下 NAT 规则可能无法正确生效，导致 VPN 客户端无法访问网络。

`iptables-legacy` 使用传统的 iptables/xtables 后端，与 strongSwan 的兼容性更好，可以确保 NAT 规则正确生效。

启动脚本做的事情：
    - 配置 NAT 规则，让 VPN 客户端的流量可以正常转发
    - 允许 VPN 网段 `10.10.10.0/24` 的 FORWARD 流量
    - 启动 strongSwan 服务

## docker-compose.yml

```yaml
version: "3"
services:
  strongswan:
    image: joyfay/joyfay-strongswan:latest
    container_name: joyfay-strongswan
    restart: unless-stopped
    privileged: true
    # 或者使用 capabilities 替代 privileged（更安全）
    # cap_add:
    #   - NET_ADMIN
    #   - SYS_MODULE
    ports:
      - "500:500/udp"
      - "4500:4500/udp"
    volumes:
      - ./config/ipsec.conf:/etc/ipsec.conf:ro
      - ./config/ipsec.secrets:/etc/ipsec.secrets:ro
      - ./config/certs:/etc/ipsec.d:ro
      - /lib/modules:/lib/modules:ro
    sysctls:
      - net.ipv4.ip_forward=1
    environment:
      - TZ=Asia/Shanghai
```

这里需要注意的是：
    - `privileged: true` 或 `cap_add: NET_ADMIN` 是必需的，否则容器无法配置 iptables
    - `/lib/modules` 挂载是为了让容器可以使用宿主机的内核模块
    - `sysctls` 配置开启 IP 转发
    - 端口 500 用于 IKE 协商，端口 4500 用于 NAT-T（NAT 环境下的 IPSec）

生产环境建议使用 `cap_add` 替代 `privileged`，权限更精确：


## 项目开源
该项目已开源至: https://github.com/JoyLau/joyfay-strongswan

### 验证服务状态

```bash
# 进入容器查看 IPSec 状态
docker exec -it joyfay-strongswan ipsec statusall
```

## 防火墙配置

宿主机需要开放 UDP 500 和 4500 端口：

如果服务器在 NAT 环境下（云服务器），还需要在云平台的安全组中开放这两个端口。

## 客户端配置

| 配置项 | 值 |
|--------|-----|
| 服务器地址 | YOUR_PUBLIC_IP |
| VPN 类型 | IKEv2 |
| 认证方式 | EAP (用户名/密码) |
| 用户名 | 见 ipsec.secrets |
| 密码 | 见 ipsec.secrets |

客户端需要导入 CA 证书 (`config/certs/cacerts/ca.crt`)

### Windows 配置步骤

1. 导入 CA 证书：双击 `ca.crt`，安装到"受信任的根证书颁发机构"
2. 打开"设置" → "网络和 Internet" → "VPN"
3. 添加 VPN 连接：
   - VPN 提供商：Windows（内置）
   - 连接名称：VPN
   - 服务器名称：YOUR_PUBLIC_IP
   - VPN 类型：IKEv2
   - 登录信息类型：用户名和密码

### macOS 配置步骤

1. 导入 CA 证书：双击 `ca.crt`，添加到"系统"钥匙串，设置为"始终信任"
2. 打开"系统偏好设置" → "网络"
3. 添加 VPN 连接：
   - 接口：VPN
   - VPN 类型：IKEv2
   - 服务名称：VPN
4. 配置服务器地址和认证信息

### iOS 配置步骤

1. 导入 CA 证书：邮件发送 `ca.crt`，安装后在"设置" → "通用" → "关于本机" → "证书信任设置"中启用信任
2. 打开"设置" → "通用" → "VPN 与设备管理" → "VPN"
3. 添加 VPN 配置，类型选择 IKEv2

### Android 配置步骤

1. 导入 CA 证书："设置" → "安全" → "安装证书" → "CA 证书"
2. 打开"设置" → "网络和 Internet" → "VPN"
3. 添加 VPN 配置，类型选择 IKEv2/IPSec MSCHAPv2