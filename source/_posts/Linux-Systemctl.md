---
title: Linux菜鸟到熟悉 --- systemctl 托管自定义程序
date: 2018-5-18 15:31:18
description: 有时我们会将我们的代码部署到服务器上，希望我们服务能够开机启动和被系统托管
categories: [Linux篇]
tags: [Linux,CMD]
---

<!-- more -->
## 说明
1. 系统 centos 7
2. 能够开机启动
3. 能够一键开启，关闭，重启

## 文件
注意文件编码的问题

- service 文件

``` shell
    [Unit]
    Description=frp server Service
    After=network.target
    
    [Service]
    ## 可以包含的值为simple、forking、oneshot、dbus、notify、idel其中之一。
    ## Type=forking
    
    ## 守护进程的PID文件，必须是绝对路径，强烈建议在Type=forking的情况下明确设置此选项
    ## PIDFile=/project/frp_0.19.0_linux_amd64
    
    ## 设置启动服务是要执行的命令（命令+参数）
    ExecStart=/project/frp_0.19.0_linux_amd64/systemctl-frps start
    ## ExecStop=
    ## ExecReload=
    
    ## 当服务进程正常退出、异常退出、被杀死、超时的时候，是否重启系统该服务。进程通过正常操作被停止则不会被执行重启。可选值为：
    ## no：默认值，表示任何时候都不会被重启
    ## always：表示会被无条件重启
    ## no-success：表示仅在服务进程正常退出时重启
    ## on-failure：表示仅在服务进程异常退出时重启
    ## 所谓正常退出是指，退出码为“0”，或者到IGHUP, SIGINT, SIGTERM, SIGPIPE 信号之一，并且退出码符合 SuccessExitStatus= 的设置。
    ## 所谓异常退出时指，退出码不为“0”，或者被强杀或者因为超时被杀死。
    Restart=on-abort
    
    
    [Install]
    WantedBy=multi-user.target
```

文件放到 /usr/lib/systemd/system/ 下

如果单独运行的是命令，这个就已经足够了，但是如果运行一些守护进程的话或者更复杂的情况的话，需要单独写一个脚本来运行

关于 service 里面的详细配置可以参考： http://blog.51cto.com/littledevil/1912570 

- 脚本文件

``` bash
    #!/bin/bash
    
    #set service name
    SERVICE_NAME=frpServerService
    BIN_FILE_NAME=frps
    
    # set basic executable environment, do not modify those lines
    BIN_HOME=$(dirname $0)
    if [ "${BIN_HOME}" = "." ]; then
            BIN_HOME=$(pwd)
    fi
    
    cd ${BIN_HOME}
    
    #the service pid
    pid=`ps -ef|grep $SERVICE_NAME|grep -v grep|grep -v kill|awk '{print $2}'`
    
    start() {
       if [ -n "$pid" ]; then
         echo "service ${SERVICE_NAME} already start with PID :$pid"
         return 0
       fi
       nohup ./$BIN_FILE_NAME -c ./$BIN_FILE_NAME.ini >/dev/null 2>&1 & 
       echo "Starting $SERVICE_NAME : "
       pid=`ps -ef|grep $SERVICE_NAME|grep -v grep|grep -v kill|awk '{print $2}'`
       if [ ${pid} ]; then
            echo "start ${SERVICE_NAME} successfully with PID: ${pid}"
       else
            echo "start ${SERIVCE_NAME} failed"
       fi
    }
    
    debug() {
       if [ ${pid} ]; then
         kill -9 $pid
       fi
       ./${BIN_FILE_NAME} -c ./${BIN_FILE_NAME}.ini
    }
    
    stop() {
       if [ -z ${pid} ]; then
            echo "service $SERVICE_NAME already stopped"
       else
            kill -9 $pid
            echo -n "Shutting down $SERVICE_NAME : "
            check_pid=`jps | grep ${SERVICE_NAME}|grep -v grep|awk '{print $1}'`
            while [ -n "${check_pid}" ]
            do
                    check_pid=`jps | grep ${SERVICE_NAME}|grep -v grep|awk '{print $1}'`
                    if [ -z "${check_pid}" ];then
                            break;
                    fi
            done
            echo "stop ${SERVICE_NAME} with PID: ${pid}"
       fi
    }
    
    
    status() {
       pid=`jps | grep ${SERVICE_NAME}|grep -v grep|awk '{print $1}'`
       if [ -n "$pid" ] ;then
            echo "service $SERVICE_NAME (pid $pid) is running ..."
       else
            echo "service $SERVICE_NAME is stopped"
       fi
    }
    
    # See how we were called.
    case "$1" in
      start)
            start
            ;;
      stop)
            stop
            ;;
      status)
            status
            ;;
      restart)
            stop
            start
            ;;
      debug)
            debug
            ;;
      *)
            echo $"Usage: $0 {start|stop|status|restart|debug}"
            exit 2
    esac
```

上面这个脚本是一个模板，包括了start，stop，status，restart，debug各个命令，是可以直接传参执行的
在一个文件上的 ExecStart= 就可以运行脚本文件 并传入 start 参数

注意： 如果运行的是守护进程的话，Type=forking 要配置上，意指 ExecStart 命令里面运行进程才是主进程

## 使用命令
1. 启动服务：systemctl start serviceName
2. 停止服务：systemctl stop serviceName
3. 服务状态：systemctl status serviceName
4. 项目日志：journalctl -u serviceName
5. 开机启动：systemctl enable serviceName
6. 重新加载service文件：systemctl daemon-reload