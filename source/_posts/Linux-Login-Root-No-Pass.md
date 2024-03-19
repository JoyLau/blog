---
title: Linux 普通用户免密码切换至 root
date: 2024-03-19 17:17:04
description: Linux 普通用户免密码切换至 root
categories: [Linux篇]
tags: [linux]
---

<!-- more -->

### 步骤
1. 修改 `/etc/sudoers` 文件, 没有权限的话执行 `chmod u+w /etc/sudoers`, 修改完成后还原权限 `chmod u-w /etc/sudoers`
2. 添加一行 `username   ALL=(ALL)     NOPASSWD:ALL`
3. 普通用户下输入 `sudo -s` 或者 `sudo su -` 命令就可以直接免密切换到 root 账户