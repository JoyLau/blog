---
title: Linux菜鸟到熟悉 --- 闲置笔记本安装 Centos
date: 2018-5-17 16:29:58
description: 家里以前的废旧笔记本突发奇想的想利用起来，由于我自己已经有很好的笔记本配置了，以前的闲置的笔记本打算装个 Centos 做开发使用
categories: [Linux篇]
tags: [Linux,CMD]
---

<!-- more -->
## 说明
1. 以前的笔记本是 windows7 的操作系统
2. 6GB 内存
3. 还剩 96G 硬盘
4. 打算安装 Centos 7.2

## 材料
1. U 盘一个（>= 8G）
2. centos 镜像文件
3. 刻录软件 UltraISO （官网直接下载试用版的即可）

## 安装过程
1. 在 windows 系统下压缩出磁盘空间或者直接格式化一个盘出来用来装 centos ，注意盘的格式 要为fat32
2. UltraISO 烧录镜像到U盘，U盘会被磁盘格式会改变且会被格式化
3. 重启系统，以U盘启动
4. 指定U盘安装
5. 安装配置
6. 等待进入系统

## 注意事项
1. 在 U 盘启动的时候，在安装界面上会有三个选项，选择第一个 Install Centos，按tab键进行配置
2. 找到U盘位置的方法： `vmlinuz initrd=initrd.img linux dd`
3. 这个时候很容易找到 U 的device，记下来(我当时U的device是 sdb4)，重启机器，在进入上一步的步骤
4. 这时，将参数改为 ： `vmlinuz initrd=initrd.img inst.stage2=hd:/dev/sdb4` 接下来等待即可
5. 选择安装位置，下方一定要选择自定义分区
6. 分区策略就选默认的，创建新的分区，分区的大小就按照默认分配的就好，不需要改变

## WiFi 问题
因为笔记本自带了 wifi 模块，想着不要用网线扯来扯去的，直接用wifi连接网络就好了啊
一切都没想象的那么简单....

因为我之前安装的时候选择了最小化安装，进去系统后什么都没有，一起都用通过命令行来解决
第一次我是根据这篇文章的步骤来的 http://www.jb51.net/article/100300.htm
中间遇到了很多问题 network 服务不可用；systemctl restart network 也起不来，一直报错；ping 域名不通，ping ip 不通；ifconfig 命令不存在....总之一大堆问题
问题一个个解决，最后终于连上家里的wifi
后来重启了下，一切回到解放前
我去....
一顿惆怅
后来我装了个gnome图形界面，连上了wifi
在切换命令行使用，不使用图形界面，现在一切完好，而且内存占用空间大幅减少

## WiFi 连接命令
1. 设置NetworkManager自动启动
    chkconfig NetworkManager on
2. 安装NetworkManager-wifi
    yum -y install NetworkManager-wifi
3. 开启WiFi
    nmcli r wifi on
4. 测试（扫描信号）
    nmcli dev wifi
5. 连接
    nmcli dev wifi connect password

## 切换命令行和图形界面

``` shell
    systemctl set-default multi-user.target  //设置成命令模式
    systemctl set-default graphical.target  //设置成图形模式
```

## 关闭盖子不睡眠
vim /etc/systemd/logind.conf  

HandlePowerKey　　　　  按下电源键后会触发的行为  
HandleSleepKey　　 　　 按下挂起键后会触发的行为  
HandleHibernateKey  　　按下休眠键后会触发的行为  
HandleLidSwitch　　 　　关闭笔记本盖子后会触发的行为

只需要把HandleLidSwitch选项设置为 HandleLidSwitch=lock 

设置完成保存后运行 systemctl restart systemd-logind 命令才生效

## 恢复 Windows 启动项

windows 7、8/10 安装centos7双系统后，默认会将mbr改写成为grub2，而默认的centos7不识别windows 的ntfs分区，所以启动项没有windows。 
可以用3条命令，即可将windows添加到grub2的启动项。

``` bash
    yum -y install epel-release
    yum -y install ntfs-3g
    grub2-mkconfig -o /boot/grub2/grub.cfg
```

重启