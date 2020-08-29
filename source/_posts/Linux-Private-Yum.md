---
title: Yum 私服搭建记录
date: 2018-12-08 13:48:34
description: 有时我们的服务器网络并不允许连接互联网,这时候 yum 安装软件就有很多麻烦事情了
categories: [Linux篇]
tags: [Linux,YUM]
---

<!-- more -->
## 背景
有时我们的服务器网络并不允许连接互联网,这时候 yum 安装软件就有很多麻烦事情了, 我们也许会通过 yumdownloader 来从可以连接互联网的机器上下载好 rpm 安装包,
然后再拷贝到 服务器上.
命令 : `yumdownloader  --resolve mariadb-server` , 所有依赖下载到当前文件夹下

这样做会存在很多问题:
1. 虽然上述命令已经加上了 `--resolve` 来解决依赖,但是一些基础的依赖包仍然没有下载到,这时安装就有问题了
2. 下载的很多依赖包都有安装的先后顺序,包太多的话,根本无法搞清楚顺序

还可以使用 `yum install --downloadonly --downloaddir=/tmp/vsftps/ vsftpd` 来下载依赖和指定下载的位置
但是如果有一些基础依赖包已经安装过了，则不会下载， 这时可以使用 **reinstall** 来重新下载

`yum reinstall --downloadonly --downloaddir=/tmp/vsftps/ vsftpd`

## rsync 同步科大的源
1. `yum install rsync`
2. `df -h` 查看磁盘上目录的存储的空间情况
3. 找到最大的磁盘的空间目录,最好准备好 50 GB 以上的空间
4. 新建目录如下:

``` bash
    mkdir -p ./yum_data/centos/7/os/x86_64
    mkdir -p ./yum_data/centos/7/extras/x86_64
    mkdir -p ./yum_data/centos/7/updates/x86_64
    mkdir -p ./yum_data/centos/7/epel/x86_64
```

5. 开始同步 base extras updates epel 源

``` bash
    cd yum_data
    rsync -avh --progress rsync://rsync.mirrors.ustc.edu.cn/repo/centos/7/os/x86_64/ ./centos/7/os/x86_64/
    rsync -avh --progress rsync://rsync.mirrors.ustc.edu.cn/repo/centos/7/extras/x86_64/ ./centos/7/extras/x86_64/
    rsync -avh --progress rsync://rsync.mirrors.ustc.edu.cn/repo/centos/7/updates/x86_64/ ./centos/7/updates/x86_64/
    rsync -avh --progress rsync://rsync.mirrors.ustc.edu.cn/repo/epel/7/x86_64/ ./epel/7/x86_64/
```

6. 开始漫长的等待......
7. 等待全部同步完毕, `tar -czf yum_data.tar.gz ./yum_data` ,压缩目录
8. 压缩包拷贝到服务器上

## rsync 增量同步
使用参数 -u, 即

```bash
    rsync -avuh --progress rsync://rsync.mirrors.ustc.edu.cn/repo/centos/7/extras/x86_64/ ./centos/7/extras/x86_64/
```


## rsync 使用及配置解释
### 6 种用法
- rsync [OPTION]... SRC DEST
- rsync[OPTION]... SRC [USER@]HOST:DEST
- rsync [OPTION]... [USER@]HOST:SRC DEST
- rsync [OPTION]... [USER@]HOST::SRC DEST
- rsync [OPTION]... SRC [USER@]HOST::DEST
- rsync [OPTION]... rsync://[USER@]HOST[:PORT]/SRC [DEST]

1)拷贝本地文件。当SRC和DES路径信息都不包含有单个冒号":"分隔符时就启动这种工作模式。如：rsync -a /data /backup
2)使用一个远程shell程序(如rsh、ssh)来实现将本地机器的内容拷贝到远程机器。当DST路径地址包含单个冒号":"分隔符时启动该模式。如：rsync -avz *.c foo:src
3)使用一个远程shell程序(如rsh、ssh)来实现将远程机器的内容拷贝到本地机器。当SRC地址路径包含单个冒号":"分隔符时启动该模式。如：rsync -avz foo:src/bar /data
4)从远程rsync服务器中拷贝文件到本地机。当SRC路径信息包含"::"分隔符时启动该模式。如：rsync -av root@172.16.78.192::www /databack
5)从本地机器拷贝文件到远程rsync服务器中。当DST路径信息包含"::"分隔符时启动该模式。如：rsync -av /databack root@172.16.78.192::www
6)列远程机的文件列表。这类似于rsync传输，不过只要在命令中省略掉本地机信息即可。如：rsync -v rsync://172.16.78.192/www

### 参数解释
``` bash
-v, --verbose 详细模式输出
-q, --quiet 精简输出模式
-c, --checksum 打开校验开关，强制对文件传输进行校验
-a, --archive 归档模式，表示以递归方式传输文件，并保持所有文件属性，等于-rlptgoD
-r, --recursive 对子目录以递归模式处理
-R, --relative 使用相对路径信息
-b, --backup 创建备份，也就是对于目的已经存在有同样的文件名时，将老的文件重新命名为~filename。可以使用--suffix选项来指定不同的备份文件前缀。
--backup-dir 将备份文件(如~filename)存放在在目录下。
-suffix=SUFFIX 定义备份文件前缀
-u, --update 仅仅进行更新，也就是跳过所有已经存在于DST，并且文件时间晚于要备份的文件。(不覆盖更新的文件)
-l, --links 保留软链结
-L, --copy-links 想对待常规文件一样处理软链结
--copy-unsafe-links 仅仅拷贝指向SRC路径目录树以外的链结
--safe-links 忽略指向SRC路径目录树以外的链结
-H, --hard-links 保留硬链结
-p, --perms 保持文件权限
-o, --owner 保持文件属主信息
-g, --group 保持文件属组信息
-D, --devices 保持设备文件信息
-t, --times 保持文件时间信息
-S, --sparse 对稀疏文件进行特殊处理以节省DST的空间
-n, --dry-run现实哪些文件将被传输
-W, --whole-file 拷贝文件，不进行增量检测
-x, --one-file-system 不要跨越文件系统边界
-B, --block-size=SIZE 检验算法使用的块尺寸，默认是700字节
-e, --rsh=COMMAND 指定使用rsh、ssh方式进行数据同步
--rsync-path=PATH 指定远程服务器上的rsync命令所在路径信息
-C, --cvs-exclude 使用和CVS一样的方法自动忽略文件，用来排除那些不希望传输的文件
--existing 仅仅更新那些已经存在于DST的文件，而不备份那些新创建的文件
--delete 删除那些DST中SRC没有的文件
--delete-excluded 同样删除接收端那些被该选项指定排除的文件
--delete-after 传输结束以后再删除
--ignore-errors 及时出现IO错误也进行删除
--max-delete=NUM 最多删除NUM个文件
--partial 保留那些因故没有完全传输的文件，以是加快随后的再次传输
--force 强制删除目录，即使不为空
--numeric-ids 不将数字的用户和组ID匹配为用户名和组名
--timeout=TIME IP超时时间，单位为秒
-I, --ignore-times 不跳过那些有同样的时间和长度的文件
--size-only 当决定是否要备份文件时，仅仅察看文件大小而不考虑文件时间
--modify-window=NUM 决定文件是否时间相同时使用的时间戳窗口，默认为0
-T --temp-dir=DIR 在DIR中创建临时文件
--compare-dest=DIR 同样比较DIR中的文件来决定是否需要备份
-P 等同于 --partial
--progress 显示备份过程
-z, --compress 对备份的文件在传输时进行压缩处理
--exclude=PATTERN 指定排除不需要传输的文件模式
--include=PATTERN 指定不排除而需要传输的文件模式
--exclude-from=FILE 排除FILE中指定模式的文件
--include-from=FILE 不排除FILE指定模式匹配的文件
--version 打印版本信息
--address 绑定到特定的地址
--config=FILE 指定其他的配置文件，不使用默认的rsyncd.conf文件
--port=PORT 指定其他的rsync服务端口
--blocking-io 对远程shell使用阻塞IO
-stats 给出某些文件的传输状态
--progress 在传输时现实传输过程
--log-format=formAT 指定日志文件格式
--password-file=FILE 从FILE中得到密码
--bwlimit=KBPS 限制I/O带宽，KBytes per second
-h, --help 显示帮助信息
```


## 配置本地 yum 源
1. 找到一个空间大的目录下,解压包: `tar -xvf yum_data.tar.gz`
2. 创建一个新的源配置: `touch /etc/yum.repos.d/private.repo`
3. 插入一下内容:

``` bash
    [local-base]
    name=Base Server Repository
    baseurl=file:///home/liufa/yum_data/centos/7/os/x86_64
    enabled=1
    gpgcheck=0
    priority=1
    [local-extras]
    name=Extras Repository
    baseurl=file:///home/liufa/yum_data/centos/7/extras/x86_64
    enabled=1
    gpgcheck=0
    priority=2
    [local-updates]
    name=Updates Server Repository
    baseurl=file:///home/liufa/yum_data/centos/7/updates/x86_64
    enabled=1
    gpgcheck=0
    priority=3
    [local-epel]
    name=Epel Server Repository
    baseurl=file:///home/liufa/yum_data/centos/7/epel/x86_64
    enabled=1
    gpgcheck=0
    priority=4
```

4. 禁用原来的 Base Extras Updates 源: `yum-config-manager --disable Base,Extras,Updates `
5. `yum clean all`
6. `yum makecache`
7. `yum repolist` 查看源信息


## 配置网络 yum 源
有时候我们搭建的私有 yum 还需要提供给其他的机器使用,这时候再做一个网络的 yum 即可,用 Apache 或者 Nginx 搭建个服务即可

1. `yum install nginx`
2. `vim /etc/nginx/nginx.conf` 修改

``` bash
        server {
            listen       80 default_server;
            listen       [::]:80 default_server;
            server_name  _;
            root         /home/liufa/yum_data;
    
            # Load configuration files for the default server block.
            include /etc/nginx/default.d/*.conf;
    
            location / {
            }
    
            error_page 404 /404.html;
                location = /40x.html {
            }
    
            error_page 500 502 503 504 /50x.html;
                location = /50x.html {
            }
        }
```

4. 这时 private.repo 里的 baseurl 全改为网络地址即可

## 403 权限问题
修改 nginx.conf 配置文件的 user 为 root