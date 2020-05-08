---
title: Maven --- 发布自己的构件到中央仓库
date: 2017-3-17 11:43:01
cover: //image.joylau.cn/blog/sonatype.png
description: Sonatype真可谓是个强大的公司，如此多的构件包竟能管理的有条不紊，最近自己写了个ECharts的类库，想传到Maven中央仓库，下面开始动手吧.....
categories: [Maven篇]
tags: [Maven,GPG]
---
<!-- more -->

![Sonatype](//image.joylau.cn/blog/sonatype.png)


## 说明
- 个人感觉第一次发布的步骤非常复杂，我在第一次操作的时候来来回回发布了7,8个版本，最后都是校验失败，导致构件不能关闭（因为我遇到了个大坑）
- 第一次发布成功之后后面的更新和添加新的构件都相对来说要容易一些（groupid不变的情况下）

## 开始

### 账户注册
- 注册地址 ： https://issues.sonatype.org/secure/Signup!default.jspa  ,这一步需要注意的是记住用户名和密码，后面配置文件会用到
![注册](//image.joylau.cn/blog/sonatype-register.png)

### 创建并提交工单
![创建工单](//image.joylau.cn/blog/sonatype_issue.PNG)

- Project和issue Type的填写如上图所示，不能填写错了
- 创建完成之后就等待网站工作人员的审核就可以了，不知道为什么，我等待的时间非常短，2分钟都不到，工作人员就回复我了，可能是我的运气比较好吧，但是上个星期买房摇号我却没摇到![伤心欲绝](////image.joylau.cn/aodamiao/18.gif)
- 当issue 的 state 变为 `RESOLVED`时就可继续操作了，同时下面的活动区会给你发消息
![Comment](//image.joylau.cn/blog/issue-activity.png)


### gpg生成密钥对
- 下载安装：https://www.gpg4win.org/download.html 
 **_安装时注意的是，只安装主体组件和加密解密窗口的组件就可以了，其他的不需要~~~~_**
- 查看是否安装成功:`gpg --version`
![version](//image.joylau.cn/blog/gpg-version.png)
- 生成密钥对:`gpg --gen-key`
![gpg --gen-key](//image.joylau.cn/blog/gpg-2.png)
![gpg --gen-key](//image.joylau.cn/blog/gpg-2.png)
- 之后往下，会让你输入用户名和邮箱，还有一个Passphase，相当于密钥库密码，不要忘记。
- 查看公钥:`gpg --list-keys`
- 将公钥发布到 PGP 密钥服务器
``` bash
    gpg --keyserver hkp://pool.sks-keyservers.net --send-keys C990D076
    //可能由于网络问题，有点慢，多重试几次
    
    //查看发布是否成功
    gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys C990D076 
```


### 配置setting.xml文件和pom.xml文件
- setting.xml文件
    ``` xml
        <servers>
            <server>
              //记住id，需要和pom文件里的id一致
              <id>oss</id>
              <username>username</username>
              <password>password</password>
            </server>
          </servers>
    ```
    
- pom.xml文件
    ``` xml
        <!--
          ~ The MIT License (MIT)
          ~
          ~ Copyright (c) 2017 2587038142@qq.com
          ~
          ~ Permission is hereby granted, free of charge, to any person obtaining a copy
          ~ of this software and associated documentation files (the "Software"), to deal
          ~ in the Software without restriction, including without limitation the rights
          ~ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
          ~ copies of the Software, and to permit persons to whom the Software is
          ~ furnished to do so, subject to the following conditions:
          ~
          ~ The above copyright notice and this permission notice shall be included in
          ~ all copies or substantial portions of the Software.
          ~
          ~ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
          ~ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
          ~ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
          ~ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
          ~ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
          ~ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
          ~ THE SOFTWARE.
          -->
        
        <project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://maven.apache.org/POM/4.0.0"
                 xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
            <modelVersion>4.0.0</modelVersion>
        
            <groupId>cn.joylau.code</groupId>
            <artifactId>joylau-echarts</artifactId>
            <version>1.0</version>
            <packaging>jar</packaging>
        
            <name>joylau-echarts</name>
            <description>Configure the most attribute for ECharts3.0+ by Gson</description>
            <url>http://code.joylau.cn</url>
        
            <parent>
                <groupId>org.sonatype.oss</groupId>
                <artifactId>oss-parent</artifactId>
                <version>7</version>
            </parent>
        
            <licenses>
                <license>
                    <name>The Apache Software License, Version 2.0</name>
                    <url>http://www.apache.org/licenses/LICENSE-2.0.txt</url>
                </license>
            </licenses>
        
            <developers>
                <developer>
                    <name>JoyLau</name>
                    <email>2587038142@qq.com</email>
                    <url>http://joylau.cn</url>
                </developer>
            </developers>
        
            <scm>
                <connection>scm:git:git@github.com:JoyLau/joylau-echarts.git</connection>
                <developerConnection>scm:git:git@github.com:JoyLau/joylau-echarts.git</developerConnection>
                <url>git@github.com:JoyLau/joylau-echarts</url>
            </scm>
            <properties>
                <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
            </properties>
        
            <dependencies>
                <dependency>
                    <groupId>com.google.code.gson</groupId>
                    <artifactId>gson</artifactId>
                    <version>2.5</version>
                    <scope>compile</scope>
                    <optional>true</optional>
                </dependency>
            </dependencies>
        
            <build>
                <testResources>
                    <testResource>
                        <directory>src/test/resources</directory>
                    </testResource>
                    <testResource>
                        <directory>src/test/java</directory>
                    </testResource>
                </testResources>
            </build>
        
            <profiles>
                <profile>
                    <id>release</id>
                    <build>
                        <plugins>
                            <!--Compiler-->
                            <plugin>
                                <artifactId>maven-compiler-plugin</artifactId>
                                <configuration>
                                    <source>1.7</source>
                                    <target>1.7</target>
                                </configuration>
                            </plugin>
                            <!-- Source -->
                            <plugin>
                                <groupId>org.apache.maven.plugins</groupId>
                                <artifactId>maven-source-plugin</artifactId>
                                <version>2.2.1</version>
                                <executions>
                                    <execution>
                                        <phase>package</phase>
                                        <goals>
                                            <goal>jar-no-fork</goal>
                                        </goals>
                                    </execution>
                                </executions>
                            </plugin>
                            <!-- Javadoc -->
                            <plugin>
                                <groupId>org.apache.maven.plugins</groupId>
                                <artifactId>maven-javadoc-plugin</artifactId>
                                <version>2.9.1</version>
                                <executions>
                                    <execution>
                                        <phase>package</phase>
                                        <goals>
                                            <goal>jar</goal>
                                        </goals>
                                    </execution>
                                </executions>
                            </plugin>
                            <!-- GPG -->
                            <plugin>
                                <groupId>org.apache.maven.plugins</groupId>
                                <artifactId>maven-gpg-plugin</artifactId>
                                <version>1.6</version>
                                <executions>
                                    <execution>
                                        <phase>verify</phase>
                                        <goals>
                                            <goal>sign</goal>
                                        </goals>
                                    </execution>
                                </executions>
                            </plugin>
                        </plugins>
                    </build>
                    <distributionManagement>
                        <snapshotRepository>
                            <id>oss</id>
                            <url>https://oss.sonatype.org/content/repositories/snapshots/</url>
                        </snapshotRepository>
                        <repository>
                            <id>oss</id>
                            <url>https://oss.sonatype.org/service/local/staging/deploy/maven2/</url>
                        </repository>
                    </distributionManagement>
                </profile>
            </profiles>
        </project>
    ```

### 上传构件到 OSS 中
``` xml
    mvn clean deploy -P release
    <--! jdk1.8后再生成javadoc时语法较为严格，这时去除javadoc即可 !-->
    mvn clean deploy -P release -Dmaven.javadoc.skip=true
```
在上传之前会自动弹出一个对话框，需要输入上面提到的 Passphase，它就是刚才设置的 GPG 密钥库的密码。
随后会看到大量的 upload 信息，因为在国内网络的缘故，时间有点久，耐心等待吧。

### 在 OSS 中发布构件
- 在 OSS 中，使用自己的 Sonatype 账号登录后，可在 Staging Repositories 中查看刚才已上传的构件，这些构件目前是放在 Staging 仓库中，可进行模糊查询，快速定位到自己的构件。
- 此时，该构件的状态为 Open，需要勾选它，然后点击 Close 按钮。系统会自动验证该构件是否满足指定要求，当验证完毕后，状态会变为 Closed。
![1](//static.dexcoder.com/images/201501/VvtDdbqdERgRv1qn.png)
- 最后，点击 Release 按钮来发布该构件，这一步没有截图，将就看吧知道就行：
![2](//static.dexcoder.com/images/201501/2gPUnClPeYP1Vjbb.png)

### 等待构件审批通过
这个，又只能等待了，当然他们晚上上班，还是第二天看。当审批通过后，将会收到邮件通知。

### 从中央仓库中搜索构件
这时，就可以在maven的中央仓库中搜索到自己发布的构件了，以后可以直接在pom.xml中使用了！

中央仓库搜索网站：http://search.maven.org/

第一次成功发布之后，以后就不用这么麻烦了，可以直接使用Group Id发布任何的构件，当然前提是Group Id没有变。

以后的发布流程：

a）构件完成后直接使用maven在命令行上传构建；

b）在https://oss.sonatype.org/ close并release构件；

c)等待同步好（大约2小时多）之后，就可以使用了

## 遇坑记录
- 安装GPG时候，没有安装弹框组件，导致gpg密码框弹不出来
- 一开始所有的命令行都在git下操作，每次部署的时候都是提示没有私钥错误，后来发现git生成的gpg密钥对在user更目录下，切换到CMD操作，是生成在AppData下。经查看有私钥，问题解决


## 引用
- 前一部分为自己实践所写
- 后面上传构件，发布版本参考：http://blog.csdn.net/hj7jay/article/details/51130398