---
title: Elasticsearch 集群安全控制
date: 2018-5-21 15:27:49
cover: //s3.joylau.cn:9000/blog/elasticsearch-secu.jpg
description: 一般我们搭建起来的 es 集群都可以通过默认的 9200 端口来进行 API 访问,这在局域网上没有什么大问题，如果说搭建的环境在公网上，这将埋下巨大的隐患 
categories: [大数据篇]
tags: [Elasticsearch,Linux]
---

<!-- more -->

## 前言
一般我们搭建起来的 es 集群都可以通过默认的 9200 端口来进行 API 访问,这在局域网上没有什么大问题，如果说搭建的环境在公网上，这将埋下巨大的隐患，因为任何人都可以操作 API 来进行增删改查，这是多么的恐怖！！

## 说明
1. 集群环境： elasticsearch 5.3.0；centos 7.2
2. 集群公网环境

## 解决方案
elasticsearch 集群搭建完成后，通过制定的端口都可以访问，但是实际情况中，我们并不想这样。我们可能想只有固定的ip地址才能访问，或者需要用户名、密码才能访问
对于如何控制 Elasticsearch 的安全性，我详细查了下资料，现有如下解决方式

1. 官方的 x-pack 插件，收费的，一下子就觉得用不了了，截止现在（2018年5月21日16:23:19），有最新消息，在 ElasticON 2018 的开幕主题演讲中，x-pack 负责人在博客宣布将开放 X-Pack的代码，但是现在为止只是第一阶段完成，
    最后在博客中宣布在6.3版本，其中免费的X-Pack功能将包含在Elastic Stack的默认发行版中，所以说现在没戏
 
2. 官方推荐的shield插件，再5.x的版本后已经集成到 x-pack里了，版本不适合，不用

3. elasticsearch-http-basic 插件， 已经不支持 5.x的版本了，没法用

4. ReadonlyREST : 官网地址： https://readonlyrest.com/download/ elasticsearch 版的插件，是免费的， kibana 的插件是收费的，此法可用

5. 使用 nginx 的 http-basic，可用

## ReadonlyREST 插件的使用
1. 官网选择 elasticsearch 的版本，填写邮箱地址，收到邮件后下载插件文件
    注意：只能通过官网填写邮箱的方式来进行下载，注意看的话，下载的地址后面有校验参数
2. 运行 `bin/elasticsearch-plugin install file:///tmp/readonlyrest-1.16.19_es5.3.0.zip` 安装插件，注意是 file:// 再加上绝对路径
    卸载插件 `bin/elasticsearch-plugin remove readonlyrest`
3. 配置文件 readonlyrest.yml,这个比较坑，插件生成好之后，居然不生成 readonlyrest.yml，还需要我们自己配置，还不知道需要配置什么东西，没办法，只能去 github 上查看文档，
文档地址： https://github.com/beshu-tech/readonlyrest-docs/blob/master/elasticsearch.md 
4. 文档说了很多，我找了半天才找到我需要的配置：

``` yml
    readonlyrest:
        prompt_for_basic_auth: true
    
        access_control_rules:
    
        - name: "::ADMIN::"
          auth_key: admin:12333
```

此时启动 elasticsearch， 再次访问 localhost:9200 就会弹出输入用户名和密码的窗口，此时输入 admin/12333 即可看到接口信息，请求成功后，在日志里会看到 ALLOWED by { name: '::PERSONAL_GRP::', p。。。 的日志信息。
想要屏蔽这样的日志信息，只需再 `auth_key` 下面加上配置 `verbosity: error` 即可。默认为 info

这里吐槽一下，ReadonlyREST 插件的文档是真的难读，可能是国外人和我们的思维方式不一样吧。

至此 ReadonlyREST 插件的使用就完毕了。

## nginx  http-basic 的使用
利用 nginx 的反向代理，分配一个二级域名来进行使用

1. 一个二级域名，比如xxxx.joylau.cn
2. 添加 nginx 的配置文件:/etc/nginx/conf.d/elasticsearch.conf, nginx 会默认读取 `/etc/nginx/conf.d/` 目录下的 *.conf的文件

``` bash
    upstream JoyElasticSearch {
            server localhost:port  weight=1;
        }
    
    
    server {
        listen       80;
        server_name  xxxxx.joylau.cn;
    
        location / {
            # 提示信息
            auth_basic "请输入账号密码";
            # 密码文件，最好写绝对路径
            auth_basic_user_file /etc/nginx/conf.d/es-password;
            autoindex on;
            proxy_pass  http://JoyElasticSearch;
        }
    }

```

在这里访问 xxxxx.joylau.cn 会被定向到 elasticsearch 的http端口
`auth_basic_user_file` ：指的是密码文件，注意这里写绝对路径，防止出错

3. 用户名，密码文件 es-password

``` bash
    # root:123
    root:Hx53TyjMWNmLo
```

这里假设 用户名是root，密码是123（实际上不是123），该加密方式为 httpd 加密，怎么获取明文加密后的密文，这个在网上有很多的在线工具可以直接使用，这里不再赘述

4. 保存并重新加载配置

``` bash
    nginx -s reload
```

访问 xxxxx.joylau.cn 就会提示输入用户名密码，输入正确即可。

至此，nginx  http-basic 就结束了

但是还有一个问题，就是直接访问 host + elasticsearch的端口也是可以访问的，解决这个问题，需要使用 iptables 来进行端口的限制访问。

## iptables 限制端口的访问
1. 禁用防火墙 `systemctl stop firewalld`
2. 禁用firewalld服务  `systemctl mask firewalld`
3. 安装iptables  `yum install -y iptables`
4. 开机自启 `systemctl enable iptables`
5. 启动 iptables `systemctl start iptables`

6. 查看现在的所有规则 `iptables -L -n`
7. 清空所有默认规则  `iptables -F`
8. 清空所有自定义规则  `iptables -X`
9. 添加限制规则 `iptables -A INPUT -p tcp --dport 9200 ! -s 127.0.0.1 -j DROP`
    这句规则的意思是，除了本机，其他的地址都不允许 访问 9200 端口
10. 保存：`service iptables save`

注： 后续想要删除这条规则的话
       直接修改 iptables.conf 文件后 `service iptables save`
       或者 `iptables -L INPUT --line-numbers` 查看所有规则
       iptables -D INPUT 1 （注意，这个1是行号，num下面的数字）
       保存：`service iptables save`
       
这样的话，其他机器就不能访问 elasticsearch 的http 服务的端口了，这能通过 配置好的二级域名来访问

至此配置结束


## 集群环境下的配置
在多个 elasticsearch 集群环境下，可配置一台机器作为负载均衡的机器，配置

``` yml
    node.master: false
    node.data: false
```

即可，其他机器的配置 `http.enabled: false` ，即对外不提供 http 服务
访问的时候只需访问那台负载均衡的节点。

至此，文章结束。







