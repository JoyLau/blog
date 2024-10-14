---
title: Windows Server 远程桌面授权模式尚未配置，由于此计算机已超过其授权宽限期，远程桌面服务将停止工作
date: 2024-10-14 10:45:08
categories: [Windows篇]
tags: [windows]
---

> 本方式仅供临时测试使用，生成环境请勿使用
<!-- more -->
### 配置重置
运行 regedit 进入注册表  

进入 **HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\RCM\GracePeriod**  

删除 **GracePeriod** 这个配置项后重启电脑  

如果删除没有权限的话，需要设置权限，设置当前登录用户完全的权限控制， 再设置进入高级里将所有者设置为当前的登录用户然后检查名称，再勾选运用到下级容器  


