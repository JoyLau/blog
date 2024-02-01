---
title: 群晖系列 --- 如何恢复群晖系统数据盘的数据
date: 2019-05-29 08:51:18
description: 之前有段时间折腾数据盘,把 mSATA 盘上的引导折腾没了,无法进入系统
categories: [群晖篇]
tags: [群晖]
---

<!-- more -->
### 背景
之前使用的是二合一的引导安装黑群晖系统,进入系统中发现一个 9G 的存储空间,顺手就把他删除了,重新建了个存储池,把 mSATA 盘上的引导折腾没了,无法进入系统  
在 PE 系统下发现无法读取数据盘的数据  
那么重做系统后如何恢复数据?

### 方法
使用计算机和 Ubuntu live CD 恢复其硬盘上存储的数据。
确保 Synology NAS 硬盘上运行的文件系统是 EXT4 或 Btrfs

### 做法
1. 准备一台具有足够数量硬盘插槽的计算机，用于安装从 Synology NAS 卸下的硬盘。
2. 从 Synology NAS 中卸下硬盘，然后将其安装到计算机中。对于 RAID 或 SHR 配置，必须同时在计算机中安装所有硬盘（不包括 Hot Spare 硬盘）。
3. 在 Windows 上创建可启动 U 盘中的说明准备 Ubuntu 环境。
4. 打开终端
5. 如果要从 RAID 或 SHR 配置恢复数据，请执行步骤 6 到 9；如果要从只有一个硬盘的基本存储类型恢复文件，请执行步骤 9。
6. 输入以下命令（sudo 执行 root 权限）。
    - Ubuntu@ubuntu:~$ sudo -i
7. 输入以下命令以安装 mdadm 和 lvm2两者都是 RAID 管理工具。必须安装 lvm2，否则 vgchange 无法正常工作。
    - root@ubuntu:~$ apt-get update
    - root@ubuntu:~$ apt-get install -y mdadm lvm2
8. 输入以下命令以装载从 Synology NAS 中卸下的所有硬盘。根据 Synology NAS 上的存储池配置，结果可能有所不同。
    - root@ubuntu:~$ mdadm -Asf && vgchange -ay
9. 输入以下命令以采用只读方式装载所有硬盘，从而可访问数据。在 ${device_path} 中输入设备路径，并在 ${mount_point} 中输入装载点。数据会放在装载点下。
    - $ mount ${device_path} ${mount_point} -o ro

### Ubuntu 启动盘制作
#### 要求
- 一个4GB或更大的 U 盘
- Microsoft Windows XP或更高版本
- Rufus，一款免费的开源工具
- 一个Ubuntu ISO 文件
#### 选择
![](//s3.joylau.cn:9000/blog/rufus-ubuntu.png)