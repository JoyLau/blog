---
title: Tomcat服务器添加多个Root项目
date: 2017-2-20 12:11:33
description: "官网下载的Tomcat默认的配置是只有一个ROOT，但如果想开启一个Tomcat，而在根目录下运行多个项目该怎么做呢?"
categories: [服务器篇]
tags: [Tomcat,GZIP]
---
<!-- more -->

![Tomcat](http://image.lfdevelopment.cn/blog/tomcat.jpg)


## 事发起因

- 只有一台云服务器
- 服务器配置较低，只能开一台Server
- 对外只想提供80及443端口
- 想把2个项目放到一个更目录下
- 2个项目想用不同的二级域名来访问：
   - <http://www.lfdevelopment.cn>想放我的个人主页
   - <http://blog.lfdevelopment.cn>想放我的博客
   - <http://life.lfdevelopment.cn>想放我的生活站

## 事发经过

### 建立文件夹
- 在Tomcat的根目录下建立blog文件夹
![blog文件夹](http://image.lfdevelopment.cn/blog/floder1.png)
- 在blog文件夹下建立ROOT文件夹，用作新项目的根路径
![ROOT文件夹](http://image.lfdevelopment.cn/blog/folder2.png)

### 修改配置
- 修改server.xml配置文件,多加一对<Host></Host>配置
    ``` bash
        <Engine name="Catalina" defaultHost="localhost">
              <Realm className="org.apache.catalina.realm.LockOutRealm">
                <Realm className="org.apache.catalina.realm.UserDatabaseRealm"
                       resourceName="UserDatabase"/>
              </Realm>
        
              <Host name="localhost"  appBase="webapps"
                    unpackWARs="true" autoDeploy="true">
                <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
                       prefix="localhost_access_log" suffix=".txt"
                       pattern="%h %l %u %t &quot;%r&quot; %s %b" />
              </Host>
        	  
        	  <Host name="blog.lfdevelopment.cn"  appBase="blog"
                    unpackWARs="true" autoDeploy="true">
        	    </Host>
            </Engine>
    ```
    
## 事发结果
- 重启服务器，问题解决。

## 总结
- 建立新的文件夹的时候一定要保证和webapps在同一级目录，以备在server.xml文件里路径被识别

## 补充

### Tomcat开启压缩资源文件功能

- 原理
HTTP 压缩可以大大提高浏览网站的速度，它的原理是，在客户端请求服务器对应资源后，从服务器端将资源文件压缩，再输出到客户端，由客户端的浏览器负责解压缩并浏览。相对于普通的浏览过程HTML ,CSS,Javascript , Text ，它可以节省40%左右的流量。更为重要的是，它可以对动态生成的，包括CGI、PHP , JSP , ASP , Servlet,SHTML等输出的网页也能进行压缩，压缩效率也很高。
- 配置
  ``` bash
        <Connector port="80" protocol="HTTP/1.1"
                       connectionTimeout="20000"
                       redirectPort="443" compression="on"
                            compressionMinSize="2048"
                            noCompressionUserAgents="gozilla,traviata"
                            compressableMimeType="text/html,text/xml,text/javascript,application/x-javascript,application/javascript,text/css,text/plain"/>
  ```
  
- 参数说明
    - compression="on" 打开压缩功能
    - compressionMinSize="50" 启用压缩的输出内容大小，默认为2KB 
    - noCompressionUserAgents="gozilla, traviata" 对于以下的浏览器，不启用压缩 
    - compressableMimeType="text/html,text/xml,text/javascript,text/css,text/plain"　哪些资源类型需要压缩


