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

## 2018-06-22 更新
1. vim 永久显示行号 vim /etc/vimrc 添加 `set nu` 或者 `set number`

2. 最小化安装 centos 是没有 tab 键补全提示的， 需要安装 `yum install bash-completion`

3. tab 补全提示不区分大小写 ： vim /etc/inputrc 添加 `set completion-ignore-case on`

注： 以上 增加配置是全局的，只对当前用户的话，可以在当前目录下新建相应的文件，再添加配置，例如： ~/.inputrc

## 2018-9-12 更新
1. killall -9 nginx : 批量结束指定进程，比如不小心运行了 nginx，会产生1个master和n个work进程，这时候一个个结束不实际，killall就是最好的方式
2. 有时候我们安装 rpm 安装包会出现某些依赖库找不到，比如
    `libSM.so.6: cannot open shared object file: No such file or directory`
    这时候我们使用 `yum provides libSM.so.6` 来寻找包含的动态库

``` shell
    Loaded plugins: fastestmirror
    Loading mirror speeds from cached hostfile
    gperftools-libs-2.6.1-1.el7.i686 : Libraries provided by gperftools
    Repo        : Private-Base
    Matched from:
    Provides    : libprofiler.so.0

```

找到后安装即可 `yum install gperftools-libs`


## 2018-12-20 更新
1. `/dev/null 2>&1` 解释
    `>` 覆盖原来的内容 
    `>>` 在原来的内容上追加新的内容
    0是标准输入    `使用<或<<`
    1是标准输出   ` 使用>或>>`
    2是标准错误输出  `使用2>或2>>`
    `>/dev/null 2>&1`  即错误输出与标准输出全部重定向到空,可以写成 `1>/dev/null 2>/dev/null`
    标准输入0和标准输出1可以省略。（当其出现重定向符号左侧时)
    文件描述符在重定向符号左侧时直接写即可，在右侧时前面加&
    文件描述符与重定向符号之间不能有空格

## 2019-01-23 更新
0. 在命令后加个` &` 代表该命令在后台运行, shell 的控制台会立即释放,但是和守护进程又不一样, shell 断开会终止运行
1. `command > file.log 2>&1` 等价于 `command 2>file.log 1>&2` 前一个指的是标准错误重定向到标准输出,标准输出在重定向到文件 file.log 中, 其中 1 省略了;后一个指的是标准输出重定向到标准错误,标准错误又重定向到文件 file.log, 其中2 不能省略
2. shell 脚本中无法报命令不存在的错误: 在 shell 脚本第一行使用 `#!/usr/bin/env bash` 或者 `#!/usr/bin/bash` 或者 `#!/bin/bash`
3. 如果运行还是命令不存在的话: 创建一个软连接 `ln -s command /usr/bin/command`, 参数 -s 创建了个符号链接,相当于快捷方式,不加参数 -s 就是创建硬链接,相当于文件拷贝

## 2019-03-07 更新
没有联网的机器做时间服务器,写了个接口获取网络的时间,然后服务器使用 crontab 定时设置时间
java:

``` java
    /**
     * 同步时间
     */
    @GetMapping("traffic/syncDateTime")
    public String syncDateTime() {
        String taobaoTime = "http://api.m.taobao.com/rest/api.do?api=mtop.common.getTimestamp";
        String suningTime = "http://quan.suning.com/getSysTime.do";
        JSONObject jsonObject;
        jsonObject = getDateTime(taobaoTime);
        if (null != jsonObject && jsonObject.containsKey("data")) {
            String time = jsonObject.getJSONObject("data").getString("t");
            return LocalDateTime.ofEpochSecond(Long.parseLong(time) / 1000, 0, ZoneOffset.ofHours(8))
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        }
        jsonObject = getDateTime(suningTime);
        if (null != jsonObject && jsonObject.containsKey("sysTime2")) {
            return jsonObject.getString("sysTime2");
        }
        return null;

    }

    private JSONObject getDateTime(String url){
        return restTemplate.getForObject(url,JSONObject.class);
    }
```

shell:

```bash
    #!/usr/bin/env bash
    time=$(curl -G -s http://34.0.7.227:9338/traffic/syncDateTime)
    if [ ! -n "$time" ]; then
      echo "time is null...."  
    else
      date -s "${time}"
      hwclock -w
    fi
```