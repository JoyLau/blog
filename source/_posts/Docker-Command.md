---
title: Docker菜鸟到熟悉 --- 常用命令备忘
date: 2017-3-22 12:33:48
description: 记下自己常用的Docker命令，以便快速查询和备忘
categories: [Docker篇]
tags: [Docker,CMD]
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
    
    
    
    
### Docker

- 安装： `yum docker install`
- 卸载： `yum remove docker`
- 启动： `systemctl start docker`
- 开机自启： `systemctl enable docker`


### Dockerfile
``` bash
    FROM java:8
    MAINTAINER joylau
    ADD joyalu-0.0.1-SNAPSHOT.jar joylau.jar
    EXPOSE 8080
    ENTRYPOINT ["java","-jar","/joylau.jar"]
```


### 镜像
- 编译镜像: `docker build –t joylau/docker .`
- 查看镜像： `docker images`
- 删除镜像： `docker rmi name/id`


### 容器
- 运行: `docker run –d --name joylau –p 8080:8080 joylau/docker`
- 停止容器： `docker stop id/name`
- 查看运行中的容器 ：  `docker ps`
- 查看所有容器：  `docker ps -a`
- 删除容器：  `docker rm id/name`


>> 未完待更........