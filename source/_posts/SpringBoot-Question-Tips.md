---
title: 重剑无锋,大巧不工 SpringBoot --- 项目问题汇总及解决
date: 2017-6-12 16:11:09
description: "<center><img src='//image.joylau.cn/blog/springboot-question-tips.png' alt='SpringBoot-Question-Tips.png'></center>  <br>这篇文章打算记录一下平时项目中遇到的各种SpringBoot问题，并记录解决方案<br>持续更新......"
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->

## 引用本地包并打包部署的问题

### 背景

- 在最近的开发中需要对接C++服务提供的`ZeroC Ice`接口，客户机环境安装了和服务环境相同的Ice，服务端的Ice比较老，是3.4.0的版本
在maven的中央仓库中没有找到**ice-3.4.0**的jar包，只能引用安装路径下提供的jar了

那么常用的写法是这样的：（包括但不限于SpringBoot）

``` xml
        <!--Ice-->
            <dependency>
                <groupId>Ice</groupId>
                <artifactId>Ice</artifactId>
                <version>3.4.0</version>
                <scope>system</scope>
                <systemPath>${basedir}/src/lib/Ice.jar</systemPath>
            </dependency>
```

我是在src下新建的lib目录，在开发编译的是没有问题的。

在进行打包的时候发现Ice.jar没有被打进去

相对于这个应用来说，打成jar包是最合适的做法了

>> 这里说一下，用package打包，不要用SpringBoot插件的jar打包



### 解决

在*build*里加上这一段：
``` xml
    <build>
                ..............
            <resources>
                <resource>
                    <directory>src/lib</directory>
                    <targetPath>BOOT-INF/lib/</targetPath>
                    <includes>
                        <include>**/*.jar</include>
                    </includes>
                </resource>
                <resource>
                    <directory>src/main/resources</directory>
                    <targetPath>BOOT-INF/classes/</targetPath>
                </resource>
            </resources>
        </build>
```

之后，再打包，再解压一看，果然是打进去了，完美~


然后，遇到了新问题........


### 以jar运行时没有主清单属性

之后便很愉快的使用 `java -jar  xxxxx.jar`

提示：没有主清单属性

再解压一看，有Application.java类，但是jar包的大小明显不对，光SpringBoot父项目依赖的jar至少也有10+M了，这个大小明显不对


在结合没有主属性的错误，知道了错误的原因在这：

``` xml
        <dependencyManagement>
    		<dependencies>
    			<dependency>
    				<!-- Import dependency management from Spring Boot -->
    				<groupId>org.springframework.boot</groupId>
    				<artifactId>spring-boot-dependencies</artifactId>
    				<version>1.5.2.RELEASE</version>
    				<type>pom</type>
    				<scope>import</scope>
    			</dependency>
    	<dependencyManagement>
```

我用的项目是多模块依赖

解决的方式是：

``` xml
        <build>
            <plugins>
                <plugin>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-maven-plugin</artifactId>
                    <version>${spring-boot-dependencies.version}</version>
                    <executions>
                        <execution>
                            <goals>
                                <goal>repackage</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>
        </build>
```

正如我文章截图的那样，解决问题！


### 父项目依赖,打包成jar

同时加入以下代码
``` xml
    <build>
            <plugins>
                <plugin>
                    <artifactId>maven-compiler-plugin</artifactId>
                    <configuration>
                        <source>1.8</source>
                        <target>1.8</target>
                    </configuration>
                </plugin>
                <plugin>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-maven-plugin</artifactId>
                    <version>${spring-boot.version}</version>
                    <executions>
                        <execution>
                            <goals>
                                <goal>repackage</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>
            </plugins>
        </build>
```

>> 持续更新中...