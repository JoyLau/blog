---
title: CentOS fail2ban 加固 SSH， 防止暴力破解, 并进行钉钉通知
date: 2024-11-01 19:54:31
description: CentOS fail2ban 加固 SSH， 防止暴力破解
categories: [Linux篇]
tags: [Linux,CMD]
---

CentOS fail2ban 加固 SSH， 防止暴力破解, 并进行钉钉通知

<!-- more -->
## 说明

```shell
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo
yum install -y fail2ban


cat > /etc/fail2ban/action.d/dingding.conf << EOF
[Definition]
# 程序启动时执行
actionstart = 
actionstop = 
actioncheck =
# IP被封执行
actionban = curl -s -o /dev/null -X POST <api_url> -d 'token=<api_token>' -d 'secret=<api_secret>' -d 'text=<_ban_text>'
actionunban = curl -s -o /dev/null -X POST <api_url> -d 'token=<api_token>' -d 'secret=<api_secret>' -d 'text=<_unban_text>'
_ban_text = <ip> 暴力登录 [<local_ip>] 达到 <failures> 次. 已被封禁
_unban_text = <ip> 在 [<local_ip>] 上已被解禁

[Init]
api_url=https://api.xinac.net/dingtalk
# 此处配置钉钉群机器人的 token
api_token=xxx
# 此处配置钉钉群机器人的 secret
api_secret=xxx
# 本机 IP 地址
local_ip=<fq-hostname>
EOF


local_ip=$(ip -4 addr show ens192 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
sed -i "s/<fq-hostname>/$local_ip/g" /etc/fail2ban/action.d/dingding.conf


tee -a /etc/fail2ban/jail.conf > /dev/null <<EOL

[ssh-iptables]
enabled = true
filter = sshd
action = iptables[name=SSH, port=ssh, protocol=tcp]
         dingding
logpath = /var/log/secure
maxretry = 3
bantime = 300d
EOL

systemctl enable fail2ban

systemctl start fail2ban

```

注意这里我是过滤出 ens192 网卡的 IP， 具体根据实际情况来


## 其他命令
解封
```shell
fail2ban-client set ssh-iptables unbanip xxxxxx
```