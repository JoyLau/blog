---
title: Linux菜鸟到熟悉 --- 常用命令备忘
date: 2017-2-23 14:09:11
description: 记下自己常用的实用的命令，以便快速查询和备忘
categories: [Linux篇]
tags: [Linux,CMD]
---

<!-- more -->

    ``` bash
        ////////////////////////////////////////////////////////////////////
        //                          _ooOoo_                               //
        //                         o8888888o                              //
        //                         88" . "88                              //
        //                         (| ^_^ |)                              //
        //                         O\  =  /O                              //
        //                      ____/`---'\____                           //
        //                    .'  \\|     |//  `.                         //
        //                   /  \\|||  :  |||//  \                        //
        //                  /  _||||| -:- |||||-  \                       //
        //                  |   | \\\  -  /// |   |                       //
        //                  | \_|  ''\---/''  |   |                       //
        //                  \  .-\__  `-`  ___/-. /                       //
        //                ___`. .'  /--.--\  `. . ___                     //
        //              ."" '<  `.___\_<|>_/___.'  >'"".                  //
        //            | | :  `- \`.;`\ _ /`;.`/ - ` : | |                 //
        //            \  \ `-.   \_ __\ /__ _/   .-` /  /                 //
        //      ========`-.____`-.___\_____/___.-`____.-'========         //
        //                           `=---='                              //
        //      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        //
        //                    佛祖保佑       永无BUG                        //
        ////////////////////////////////////////////////////////////////////
    ```
    
### 说明
- 有一些命令是centos7特有的，在低版本的可能无法使用
    
    
    
    
### 防火墙
- 查看防火墙状态：  `systemctl status firewalld`
- 开启防火墙 ：  `systemctl start  firewalld`
- 停止防火墙：  `systemctl disable firewalld`
- 重启防火墙：  `systemctl restart firewalld.service`
- 开启80端口：  `firewall-cmd --zone=public --add-port=80/tcp --permanent`
- 禁用防火墙：  `systemctl stop firewalld`
- 查看防火墙开放的端口号：  `firewall-cmd --list-ports`




### Tomcat
- 查看tomcat运行状态：`ps -ef |grep tomcat`
- 看到tomcat的pid之后：`kill -9 pid ` 可以强制杀死tomcat的进程


### 系统信息
- 查看cpu及内存使用情况：`top`(停止刷新 `-q`)
- 查看内存使用情况 ：`free`


### 文件操作
- 删除文件里机器子文件夹的内容：`rm -rf /var/lib/mysql`
- 查找某个文件所在目录：`find / -name filename`



### 压缩与解压缩
- 解压zip压缩文件：`unzip file.zip`，相反的，压缩文件 zip file （需安装`yum install unzip zip`,），解压到指定目录可加参数-d,如：`unzip file.zip -d /root/`
- 将 test.txt 文件压缩为 test.zip，`zip test.zip test.txt`,当然也可以指定压缩包的目录，例如 /root/test.zip ,后面的test.txt也可以换成文件夹
- linux下是不支持直接解压rar压缩文件，建议将要传输的文件压缩成zip文件
- `yum install p7zip` 安装7z解压，支持更多压缩格式（卸载`yum remove p7zip`）


### 快速删除文件夹/文件
- 有时我们的文件夹里有很多文件，默认的删除方式是递归删除，文件夹深了及文件多了，删除会非常的慢，这时候：
- 先建立一个空目录 
  `mkdir /data/blank`
- 用rsync删除目标目录 
  `rsync–delete-before -d /data/blank/ /var/spool/clientmqueue/`
- 同样的对于大文件：创建空文件 
  `touch /data/blank.txt`
- 用rsync清空文件 
  `rsync-a –delete-before –progress –stats /root/blank.txt /root/nohup.out`
  



### 端口
- 查看6379端口是否占用：`netstat -tunpl | grep 6379` (注意，redis服务需要 root 权限才能查看，不然只能检查到6379被某个进程占用，但是看不到进程名称。)

### 主机
- 修改主机名：`hostnamectl set-hostname 新主机名`

### yum
- 列出所有可更新的软件清单命令：`yum check-update`
- 更新所有软件命令：`yum update`
- 仅安装指定的软件命令：`yum install <package_name>`
- 仅更新指定的软件命令：`yum update <package_name>`
- 列出所有可安裝的软件清单命令：`yum list`
- 删除软件包命令：`yum remove <package_name>`
- 查找软件包 命令：`yum search <keyword>`
- 清除缓存命令:   
- `yum clean packages`: 清除缓存目录下的软件包
- `yum clean headers`: 清除缓存目录下的 headers
- `yum clean oldheaders`: 清除缓存目录下旧的 headers

### systemctl
- `systemctl restart nginx` : 重启nginx
- `systemctl start nginx` : 开启nginx
- `systemctl stop nginx` : 关闭nginx
- `systemctl enable nginx` : nginx开机启动
- `systemctl disable nginx` : 禁用nginx开机启动
- `systemctl status nginx` : 查看nginx服务信息
- `systemctl is-enabled nginx` ： 查看服务是否开机启动
- `systemctl list-unit-files|grep enabled` ： 查看已启动的服务列表
- `systemctl --failed` ： 查看启动失败的服务列表
- `systemctl daemon-reload` ： 重新加载service文件
- `systemctl reboot` : 重启
- `systemctl poweroff` : 关机

### 压缩解压命令
#### 压缩
- tar –cvf jpg.tar *.jpg //将目录里所有jpg文件打包成tar.jpg
- tar –czf jpg.tar.gz *.jpg   //将目录里所有jpg文件打包成jpg.tar后，并且将其用gzip压缩，生成一个gzip压缩过的包，命名为jpg.tar.gz
- tar –cjf jpg.tar.bz2 *.jpg //将目录里所有jpg文件打包成jpg.tar后，并且将其用bzip2压缩，生成一个bzip2压缩过的包，命名为jpg.tar.bz2
- tar –cZf jpg.tar.Z *.jpg   //将目录里所有jpg文件打包成jpg.tar后，并且将其用compress压缩，生成一个umcompress压缩过的包，命名为jpg.tar.Z
- rar a jpg.rar *.jpg //rar格式的压缩，需要先下载rar for linux
- zip jpg.zip *.jpg //zip格式的压缩，需要先下载zip for linux

#### 解压
- tar –xvf file.tar //解压 tar包
- tar -xzvf file.tar.gz //解压tar.gz
- tar -xjvf file.tar.bz2   //解压 tar.bz2
- tar –xZvf file.tar.Z   //解压tar.Z
- unrar e file.rar //解压rar
- unzip file.zip //解压zip

#### 总结
- .tar 用 tar –xvf 解压
- .gz 用 gzip -d或者gunzip 解压
- .tar.gz和*.tgz 用 tar –xzf 解压
- .bz2 用 bzip2 -d或者用bunzip2 解压
- .tar.bz2用tar –xjf 解压
- .Z 用 uncompress 解压
- .tar.Z 用tar –xZf 解压
- .rar 用 unrar e解压
- .zip 用 unzip 解压

### yum更换为阿里源
- 备份 ：mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup

- 下载新的CentOS-Base.repo 到/etc/yum.repos.d/

CentOS 5 ：

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo

或者

curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-5.repo

CentOS 6 ： 

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

或者

curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

CentOS 7 ： 

wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

或者

curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

- 之后运行 yum makecache 生成缓存

## 创建用户，权限，密码等
- adduser es -s /bin/bash  : 创建用户为 es ,shell指定为bash
- passwd es 更改 es 用户的密码
- chown -R es:es /project/elasticsearch-5.6.3 循环遍历更改 /project/elasticsearch-5.6.3 目录下的文件拥有者及用户组
- su - es : 切换成es用户重新登录系统
- su es : 表示与 es 建立一个连接，通过 es 来执行命令

注： 以上命令在安装 elasticsearch 时都会用的到