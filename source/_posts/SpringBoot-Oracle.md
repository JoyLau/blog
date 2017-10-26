---
title: SpringBoot 连接 Oracle 及 Navicat for Oracle 绿色版下载
date: 2017-10-26 12:00:36
description: Oracle 数据库在我平时工作中很少使用，今天使用SpringBoot 连接了 Oracle 进行操作，在此记录下，并记下 Navicat for Oracle 绿色版下载
categories: [SpringBoot篇]
tags: [Oracle,SpringBoot]
---

<!-- more -->
## SpringBoot 连接 Oracle
### pom 文件配置
``` xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>

    <dependency>
        <groupId>com.oracle</groupId>
        <artifactId>ojdbc6</artifactId>
        <version>12.1.0.2</version>
    </dependency>
```

注意： com.oracle.ojdbc6.12.1.0.2 在中央仓库没有，需要单独下载下来，再安装到本地仓库

### yml文件配置
``` yml
    spring:
      datasource:
        driver-class-name: oracle.jdbc.OracleDriver
        url: jdbc:oracle:thin:@192.168.10.240:1522:orcl12c
        username: C##itmscz
        password: itmscz
      jpa:
        hibernate:
          ddl-auto: update
        show-sql: true
```

接下来的套路都一样了，写好model实体类，注册个接口，然后就可以直接增删改查了

model ：

``` java
    @Entity(name = "t_samp_recog")
    @Data
    public class SampRecog {
        @Id
        @GeneratedValue
        private int id; //主键
        private String batch; // 批次
        private String img_url; // 图片路径
        private String plate_nbr; // 车辆号牌
        private boolean plate_nbr_right; // 车辆号牌是否正确
        private String brand; // 品牌
        private boolean brand_right; // 品牌是否正确
        private String veh_type; // 车辆类型
        private boolean veh_type_right; // 车辆类型是否正确
        private String veh_color; // 车身颜色
        private boolean veh_color_right; // 车身颜色是否正确
        private String sticker_pos; // 车标位置
        private boolean sticker_pos_right; // 车标位置是否全部正确
        private boolean is_right; // 是否全部正确
        private int check_status; //核对状态 1.未核对，2，正在核对，3、已经核对
    }
```

dao :

``` java
    public interface SampRecogDAO extends JpaRepository<SampRecog,Integer> {
    }
```

看来 SpringBoot 整合数据源的套路都一样，下次整合其他的猜都知道怎么做了



## Navicat for Oracle

以前一直用的 Navicat Premiun,里面虽然支持 Oracle ，但是支持 Oracle 版本都比较老啦，新一点的根本连接不上去，今天在网上找到个绿色版的 Navicat for Oracle，赶紧记下来，mark一下

### 地址
百度云盘：链接: https://pan.baidu.com/s/1mhPS9wW 密码: gtq4

7z的是我替换操作后的

### 操作
下载 3个文件 ：
Navicat for Oracle.zip

instantclient-basic-nt-12.1.0.2.0.zip
 
instantclient-sqlplus-nt-12.1.0.2.0.zip 

直接把 instantclient-basic-nt-12.1.0.2.0.zip 解压到 Navicat for Oracle 的解压目录的instantclient_10_2目录下

然后这个目录下多了instantclient_12_1 这个目录 

然后再把instantclient-sqlplus-nt-12.1.0.2.0.zip 解压到 instantclient_12_1下

完成

最后打开Navicat for Oracle 单击   工具->选项-> OCI 

2个路径分别选：

\instantclient_12_1\.oci.dll

\instantclient_12_1\.sqlplus.exe

然后就可以连接使用了