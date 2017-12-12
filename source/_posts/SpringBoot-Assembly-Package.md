---
title: 重剑无锋,大巧不工 SpringBoot --- 自定义打包部署，暴露配置文件和静态资源文件
date: 2017-12-12 09:24:39
description: "<center><img src='http://image.joylau.cn/blog/Assembly-Package.png' alt='Assembly-Package'></center><br>SpringBoot 默认有2种打包方式，一种是直接打成 jar 包，直接使用 java -jar 跑起来，另一种是打成 war 包，移除掉 web starter 里的容器依赖，然后丢到外部容器跑起来。这篇文章说下自定义打包，暴露配置文件和静态资源文件"
categories: [SpringBoot篇]
tags: [Maven,SpringBoot]
---

<!-- more -->
## 前言
SpringBoot 默认有2种打包方式，一种是直接打成 jar 包，直接使用 java -jar 跑起来，另一种是打成 war 包，移除掉 web starter 里的容器依赖，然后丢到外部容器跑起来。

第一种方式的缺点是整个项目作为一个 jar，部署到生产环境中一旦有配置文件需要修改，则过程比较麻烦
linux 下可以使用 vim jar 包，找到配置文件修改后再保存
window 下需要使用 解压缩软件打开 jar 再找到配置文件，修改后替换更新

第二种方式的缺点是需要依赖外部容器，这无非多引入了一部分，很多时候我们很不情愿这么做

>> spring boot 项目启动时 指定配置有2种方式：一种是启动时修改配置参数，像 java -jar xxxx.jar --server.port=8081 这样；另外一种是 指定外部配置文件加载，像 java -jar xxxx.jar -Dspring.config.location=applixxx.yml这样

## 目标
我们希望打包成 tomcat 或者 maven 那样的软件包结构，即


    --- bin
        --- start.sh
        --- stop.sh
        --- restart.sh
        --- start.bat
        --- stop.bat
        --- restart.bat
    --- boot
        --- xxxx.jar
    --- lib
    --- conf
    --- logs
    --- README.md
    --- LICENSE


就像这样
![Assembly-Package](http://image.joylau.cn/blog/Assembly-Package.png)

- `bin` 目录放一些我们程序的启动停止脚本
- `boot` 目录放我们自己的程序包
- `lib` 目录是我们程序的依赖包
- `conf` 目录是项目的配置文件
- `logs` 目录是程序运行时的日志文件
- `README.md` 使用说明
- `LICENSE` 许可说明


## 准备
- maven-jar-plugin ： 打包我们写的程序包和所需的依赖包，并指定入口类，依赖包路径和classpath路径，其实就是在MANIFEST.MF这个文件写入相应的配置
- maven-assembly-plugin ： 自定义我们打包的文件目录的格式


## pom.xml 配置
``` xml
    <build>
        <plugins>
            <!--<plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <configuration>
                    <fork>true</fork>
                </configuration>
            </plugin>-->

            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-jar-plugin</artifactId>
                <configuration>
                    <archive>
                        <addMavenDescriptor>false</addMavenDescriptor>
                        <manifest>
                            <mainClass>com.ahtsoft.AhtsoftBigdataWebApplication</mainClass>
                            <addClasspath>true</addClasspath>
                            <classpathPrefix>../lib/</classpathPrefix>
                        </manifest>
                        <manifestEntries>
                            <Class-Path>../conf/resources/</Class-Path>
                        </manifestEntries>
                    </archive>
                    <excludes>
                        <exclude>static/**</exclude>
                        <exclude>*.yml</exclude>
                    </excludes>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <configuration>
                    <descriptors>
                        <descriptor>src/main/assembly/assembly.xml</descriptor>
                    </descriptors>
                </configuration>
                <executions>
                    <execution>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
```

1. 将 spring boot 默认的打包方式 spring-boot-maven-plugin 去掉，使用现在的打包方式
2. maven-jar-plugin 配置中，制定了入口类，addClasspath 配置将所需的依赖包单独打包，依赖包打的位置在lib目录底下，在MANIFEST.MF这个文件写入相应的配置
3. 配置了 classpath 在 /conf/resources/ ,这个和后面的 assembly.xml 要相对应
4. 我单独把spring boot 的配置文件 yml文件 和 静态资源目录 static 单独拎了出来，在我们的源码包中并没有打进去，而是交给 assembly.xml 来单独打到一个独立的文件 conf文件下
5. 这也是照应了 前面为什么要设置 classpath 为 /conf/resources/

下面重要的是 assembly.xml 配置文件了，这个文件才是把我们的程序打成标准的目录结构

## assembly.xml
``` xml
    <assembly>
        <id>assembly</id>
        <formats>
            <format>tar.gz</format>
        </formats>
        <baseDirectory>${project.artifactId}-${project.version}/</baseDirectory>
    
        <files>
            <file>
                <source>target/${project.artifactId}-${project.version}.jar</source>
                <outputDirectory>boot/</outputDirectory>
                <destName>${project.artifactId}-${project.version}.jar</destName>
            </file>
        </files>
    
        <fileSets>
            <fileSet>
                <directory>./</directory>
                <outputDirectory>./</outputDirectory>
                <includes>
                    <include>*.txt</include>
                    <include>*.md</include>
                </includes>
            </fileSet>
            <fileSet>
                <directory>src/main/bin</directory>
                <outputDirectory>bin/</outputDirectory>
                <includes>
                    <include>*.sh</include>
                    <include>*.cmd</include>
                </includes>
                <fileMode>0755</fileMode>
            </fileSet>
            <fileSet>
                <directory>src/main/resources/static</directory>
                <outputDirectory>conf/resources/static/</outputDirectory>
                <includes>
                    <include>*</include>
                </includes>
            </fileSet>
            <fileSet>
                <directory>src/main/resources</directory>
                <outputDirectory>conf/resources</outputDirectory>
                <includes>
                    <include>*.properties</include>
                    <include>*.conf</include>
                    <include>*.yml</include>
                </includes>
            </fileSet>
        </fileSets>
    
        <dependencySets>
            <dependencySet>
                <useProjectArtifact>true</useProjectArtifact>
                <outputDirectory>lib</outputDirectory>
                <scope>runtime</scope>
                <includes>
                    <include>*:*</include>
                </includes>
                <excludes>
                    <exclude>${groupId}:${artifactId}</exclude>
                    <exclude>org.springframework.boot:spring-boot-devtools</exclude>
                </excludes>
            </dependencySet>
        </dependencySets>
    </assembly>
```

- 将最终的程序包打成 tar.gz ,当然也可以打成其他的格式如zip,rar等，fileSets 里面指定我们源码里的文件和路径打成标准包相对应的目录
- 需要注意的是，在最终的依赖库 lib 下 去掉我们的程序和开发时spring boot的热部署依赖 spring-boot-devtools，否则的会出问题
- 代码里的启动和停止脚本要赋予权限，否则在执行的时候可能提示权限的问题