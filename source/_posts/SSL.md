---
title: SSL证书部署
date: 2017-2-20 13:30:48
description: "网站https的访问方式已经日渐流行了，拥有一个https的网站是一件多么高逼格的事情</br>今天就分享一下我所接触服务器的证书安装方式"
categories: [服务器篇]
tags: [SSL,HTTPS,Apache,Tomcat,Nginx]
---
<!-- more -->

![SSL](http://image.lfdevelopment.cn/blog/https.jpg)


## Apache 2.x 证书部署

### 文件准备
![Apache](http://image.lfdevelopment.cn/blog/apachessl.png)

### 获取证书
- Apache文件夹内获得证书文件 1_root_bundle.crt，2_www.domain.com_cert.crt 和私钥文件 3_www.domain.com.key,
- 1_root_bundle.crt 文件包括一段证书代码 “-----BEGIN CERTIFICATE-----”和“-----END CERTIFICATE-----”,
- 2_www.domain.com_cert.crt 文件包括一段证书代码 “-----BEGIN CERTIFICATE-----”和“-----END CERTIFICATE-----”,
- 3_www.domain.com.key 文件包括一段私钥代码“-----BEGIN RSA PRIVATE KEY-----”和“-----END RSA PRIVATE KEY-----”。

### 证书安装
- 编辑Apache根目录下 conf/httpd.conf 文件，
- 找到 #LoadModule ssl_module modules/mod_ssl.so 和 #Include conf/extra/httpd-ssl.conf，去掉前面的#号注释；
- 编辑Apache根目录下 conf/extra/httpd-ssl.conf 文件，修改如下内容：
    ``` bash
        <VirtualHost www.domain.com:443>
            DocumentRoot "/var/www/html"
            ServerName www.domain.com
            SSLEngine on
            SSLCertificateFile /usr/local/apache/conf/2_www.domain.com_cert.crt
            SSLCertificateKeyFile /usr/local/apache/conf/3_www.domain.com.key
            SSLCertificateChainFile /usr/local/apache/conf/1_root_bundle.crt
        </VirtualHost>
    ```
    
- 配置完成后，重新启动 Apache 就可以使用<https://www.domain.com>来访问了
注：
    - `SSLEngine on` ： 启用SSL功能
    - `SSLCertificateFile` ：证书文件
    - `SSLCertificateKeyFile` ： 私钥文件
    - `SSLCertificateChainFile` : 证书链文件
    
    
##  Nginx 证书部署

### 文件准备
![Nginx](http://image.lfdevelopment.cn/blog/Nginxssl.png)

### 获取证书
- Nginx文件夹内获得SSL证书文件 1_www.domain.com_bundle.crt 和私钥文件 2_www.domain.com.key,
- 1_www.domain.com_bundle.crt 文件包括两段证书代码 “-----BEGIN CERTIFICATE-----”和“-----END CERTIFICATE-----”,
- 2_www.domain.com.key 文件包括一段私钥代码“-----BEGIN RSA PRIVATE KEY-----”和“-----END RSA PRIVATE KEY-----”。

### 证书安装
- 将域名 www.domain.com 的证书文件1_www.domain.com_bundle.crt 、私钥文件2_www.domain.com.key保存到同一个目录，例如/usr/local/nginx/conf目录下。
- 更新Nginx根目录下 conf/nginx.conf 文件如下：
    ``` bash
        server {
                listen 443;
                server_name www.domain.com; #填写绑定证书的域名
                ssl on;
                ssl_certificate 1_www.domain.com_bundle.crt;
                ssl_certificate_key 2_www.domain.com.key;
                ssl_session_timeout 5m;
                ssl_protocols TLSv1 TLSv1.1 TLSv1.2; #按照这个协议配置
                ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;#按照这个套件配置
                ssl_prefer_server_ciphers on;
                location / {
                    root   html; #站点目录
                    index  index.html index.htm;
                }
            }
    ```
 
- 配置完成后，先用bin/nginx –t来测试下配置是否有误，正确无误的话，重启nginx。就可以使 <https://www.domain.com> 来访问了。
注：
    - `listen 443`	SSL访问端口号为443
    - `ssl on`	启用SSL功能
    - `ssl_certificate`	证书文件
    - `ssl_certificate_key`	私钥文件
    - `ssl_protocols`	使用的协议
    - `ssl_ciphers`	配置加密套件，写法遵循openssl标准
    
### 使用全站加密，http自动跳转https（可选）
- 对于用户不知道网站可以进行https访问的情况下，让服务器自动把http的请求重定向到https。
- 在服务器这边的话配置的话，可以在页面里加js脚本，也可以在后端程序里写重定向，当然也可以在web服务器来实现跳转。Nginx是支持rewrite的（只要在编译的时候没有去掉pcre）
- 在http的server里增加`rewrite ^(.*) https://$host$1 permanent`;
- 这样就可以实现80进来的请求，重定向为https了。


## Tomcat 证书部署

### 文件准备

![Nginx](http://image.lfdevelopment.cn/blog/Tomcatssl.png)


### 获取证书
- 如果申请证书时有填写私钥密码，下载可获得Tomcat文件夹，其中有密钥库 www.domain.com.jks；
- 如果没有填写私钥密码，不提供Tomcat证书文件的下载，需要用户手动转换格式生成。
- 可以通过 Nginx 文件夹内证书文件和私钥文件生成jks格式证书
- 转换工具：https://www.trustasia.com/tools/cert-converter.htm
- 使用工具时注意填写 密钥库密码 ，安装证书时配置文件中需要填写。

###  证书安装
- 配置SSL连接器，将www.domain.com.jks文件存放到conf目录下，然后配置同目录下的server.xml文件：
    ``` bash
        <Connector port="443" protocol="HTTP/1.1" SSLEnabled="true"
            maxThreads="150" scheme="https" secure="true"
            keystoreFile="conf\www.domain.com.jks"
            keystorePass="changeit"
            clientAuth="false" sslProtocol="TLS" />
    ```
注：
- `clientAuth`	    如果设为true，表示Tomcat要求所有的SSL客户出示安全证书，对SSL客户进行身份验证
- `keystoreFile`	指定keystore文件的存放位置，可以指定绝对路径，也可以指定相对于 （Tomcat安装目录）环境变量的相对路径。如果此项没有设定，默认情况下，Tomcat将从当前操作系统用户的用户目录下读取名为 “.keystore”的文件。
- `keystorePass`	密钥库密码，指定keystore的密码。（如果申请证书时有填写私钥密码，密钥库密码即私钥密码）
- `sslProtocol` 	指定套接字（Socket）使用的加密/解密协议，默认值为TLS

### http自动跳转https的安全配置

- 到conf目录下的web.xml。在</welcome-file-list>后面，</web-app>，也就是倒数第二段里，加上这样一段
    ``` bash
        <web-resource-collection >
            <web-resource-name >SSL</web-resource-name>
            <url-pattern>/*</url-pattern>
        </web-resource-collection>
        <user-data-constraint>
            <transport-guarantee>CONFIDENTIAL</transport-guarantee>
        </user-data-constraint>
    ```
    
- 这步目的是让非ssl的connector跳转到ssl的connector去。所以还需要前往server.xml进行配置：
    ``` bash
        <Connector port="8080" protocol="HTTP/1.1"
            connectionTimeout="20000"
            redirectPort="443" />
    ```
    
- redirectPort改成ssl的connector的端口443，重启后便会生效。

## 说明
- 由于我域名是托管到腾讯云上的，各个服务器的SSL文件均在腾讯云平台上下载的。
- 各个服务器亲测可用