---
title: Linux菜鸟到熟悉---常用命令备忘
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