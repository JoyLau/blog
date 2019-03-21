---
title: Docker 容器挂载宿主机上的目录时出现 Permission denied
date: 2019-03-21 16:27:48
description: 解决 Docker 容器挂载宿主机上的目录时出现 Permission denied 的错误
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->

### 问题
启动 docker 容器时挂载容器以前存在的数据文件时出现了 Permission denied 的错误

### 解决
1. 首先以为是挂载的文件夹有读写数据的权限问题 `chmod -R 777 xxxx` , 没有解决，依然报错
2. 再分析是文件目录的所属者的问题： `chown -R gname:uname xxxx` , 没有解决，依然报错
3. 这时我们进入容器之后 使用 ll 查看挂载的目录的所属者，发现组名和户名跟宿主机的组名和用户名不一致
4. 原因在于，操作系统判断用户组和用户其实并不是根据名称来的，而是根据名称对应的 id 来的
5. 查看用户组和用户名对象的 id, 可查看 `/etc/passwd`
6. 此时，我们需要将宿主机的用户组用户的 ID 和 容器内挂在目录所需的用户组和用户的 ID 对应起来，写一直即可
7. 举个例子
8. redis 镜像产生的数据文件在 `/var/lib/redis` 中，并且该目录的用户组和用户都为 `redis`， 此时我们查看容器的 `redis:redis` 的 id , 假如是 `102:103`
9. 此时我们宿主机挂载目录是 `/opt/docker/redis/data` ,我们改变这个目录的所属者 `chown -R 102:103 /opt/docker/redis/data`
10. 不要管 `102:103` 在宿主机系统中有没有该用户组和用户
11. 再次进入容器就可以看到 `/var/lib/redis` 目录的所属者是正确的了

### mysql 和 mariaDB 的问题
这样的情况也发生在 mysql 和 mariaDB 上
按照上述的方法似乎没有奏效，确切的说奏效一半
因为 `/var/lib/mysql` 目录中文件夹可以看到，文件却没有权限看到
类似这样

```shell
    190321 06:02:13 mysqld_safe Logging to '/var/lib/mysql/d240623581db.err'.
    190321 06:02:13 mysqld_safe Starting mysqld daemon with databases from /var/lib/mysql
    chown: /var/lib/mysql/60689c28e4a1.err: Permission denied
    chown: /var/lib/mysql/60689c28e4a1.pid: Permission denied
    chown: /var/lib/mysql/aria_log.00000001: Permission denied
    chown: /var/lib/mysql/aria_log_control: Permission denied
    chown: /var/lib/mysql/ib_buffer_pool: Permission denied
    chown: /var/lib/mysql/ibdata1: Permission denied
    chown: /var/lib/mysql/ib_logfile0: Permission denied
    chown: /var/lib/mysql/ib_logfile1: Permission denied
    chown: /var/lib/mysql/ibtmp1: Permission denied
    chown: /var/lib/mysql/multi-master.info: Permission denied
    chown: /var/lib/mysql/mysql: Permission denied
    chown: /var/lib/mysql/mysql-bin.000001: Permission denied
    chown: /var/lib/mysql/mysql-bin.000002: Permission denied
    chown: /var/lib/mysql/mysql-bin.000003: Permission denied
    chown: /var/lib/mysql/mysql-bin.000004: Permission denied
    chown: /var/lib/mysql/mysql-bin.000005: Permission denied
    chown: /var/lib/mysql/mysql-bin.000006: Permission denied
    chown: /var/lib/mysql/mysql-bin.000007: Permission denied
    chown: /var/lib/mysql/mysql-bin.000008: Permission denied
    chown: /var/lib/mysql/mysql-bin.000009: Permission denied
    chown: /var/lib/mysql/mysql-bin.index: Permission denied
    chown: /var/lib/mysql/owncloud: Permission denied
    chown: /var/lib/mysql/performance_schema: Permission denied
    chown: /var/lib/mysql: Permission denied
    chown: /var/lib/mysql: Permission denied
    190321 06:02:14 mysqld_safe Logging to '/var/lib/mysql/d240623581db.err'.
    190321 06:02:14 mysqld_safe Starting mysqld daemon with databases from /var/lib/mysql
    chown: /var/lib/mysql/60689c28e4a1.err: Permission denied
    chown: /var/lib/mysql/60689c28e4a1.pid: Permission denied
    chown: /var/lib/mysql/aria_log.00000001: Permission denied
    chown: /var/lib/mysql/aria_log_control: Permission denied
    chown: /var/lib/mysql/ib_buffer_pool: Permission denied
    chown: /var/lib/mysql/ibdata1: Permission denied
    chown: /var/lib/mysql/ib_logfile0: Permission denied
    chown: /var/lib/mysql/ib_logfile1: Permission denied
    chown: /var/lib/mysql/ibtmp1: Permission denied
    chown: /var/lib/mysql/multi-master.info: Permission denied
    chown: /var/lib/mysql/mysql: Permission denied
    chown: /var/lib/mysql/mysql-bin.000001: Permission denied
    chown: /var/lib/mysql/mysql-bin.000002: Permission denied
    chown: /var/lib/mysql/mysql-bin.000003: Permission denied
    chown: /var/lib/mysql/mysql-bin.000004: Permission denied
    chown: /var/lib/mysql/mysql-bin.000005: Permission denied
    chown: /var/lib/mysql/mysql-bin.000006: Permission denied
    chown: /var/lib/mysql/mysql-bin.000007: Permission denied
    chown: /var/lib/mysql/mysql-bin.000008: Permission denied
    chown: /var/lib/mysql/mysql-bin.000009: Permission denied
    chown: /var/lib/mysql/mysql-bin.index: Permission denied
    chown: /var/lib/mysql/owncloud: Permission denied
    chown: /var/lib/mysql/performance_schema: Permission denied
    chown: /var/lib/mysql: Permission denied
    chown: /var/lib/mysql: Permission denied
```


原因分析是：
SELinux 造成的
有以下 4 中解决方法：
1. `setenforce 0` : 临时关闭 
2. `vi /etc/selinux/config` ： 将 `SELINUX=enforcing` 改为 `SELINUX=disabled` ，重启
3. 在docker run 中加入 `--privileged=true` 给容器加上特定权限
4. 修改 SELinux 规则 `chcon -t mysqld_db_t  -R /opt/docker/mysql/data`