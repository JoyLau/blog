---
title: 以非 root 用户身份管理 Docker
date: 2018-07-05 16:51:49
description: docker 安装完成后，其他用户只能使用 sudo 访问它。docker 守护进程始终以 root 用户身份运行，这样每次在使用命令时都需要在前面加上sudo,这很不方便。
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
### 背景

docker 安装完成后，其他用户只能使用 sudo 访问它。docker 守护进程始终以 root 用户身份运行，这样每次在使用命令时都需要在前面加上sudo,这很不方便。
有没有什么方式能够解决？
官方文档地址： https://docs.docker.com/install/linux/linux-postinstall/


### 解决
docker 守护进程绑定至 Unix 套接字，而不是 TCP 端口。默认情况下，该 Unix 套接字由用户 root 所有，而其他用户只能使用 sudo 访问它。docker 守护进程始终以 root 用户身份运行。

在使用 docker 命令时，如果您不想使用 sudo，请创建名为 docker 的 Unix 组并向其中添加用户。docker 守护进程启动时，它将使 Unix 套接字的所有权可由 docker 组进行读取/写入。

>>> 警告： docker 组将授予等同于 root 用户的特权。如需有关此操作如何影响系统安全性的详细信息，请参阅 Docker 守护进程攻击面。


如需创建 docker 组并添加您的用户，请执行下列操作：

1. 创建 docker 组。

``` shell
     $ sudo groupadd docker
```

 
向 docker 组中添加您的用户。

``` shell
    $ sudo usermod -aG docker $USER
```

注销并重新登录，以便对您的组成员资格进行重新评估。

如果在虚拟机上进行测试，可能必须重启此虚拟机才能使更改生效。

在桌面 Linux 环境（例如，X Windows）中，彻底从您的会话中注销，然后重新登录。

验证您是否可以在不使用 sudo 的情况下运行 docker 命令。

``` shell
    $ docker run hello-world
```


此命令将下载一个测试镜像并在容器中运行它。容器运行时，它将输出一条参考消息并退出。


经过实测，Ubuntu通过源添加安装最新版 Docker 时，已经自动添加了 docker 组，只需要将 当前用户添加到组里面在重新登录就可以了。