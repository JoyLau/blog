---
title: 重剑无锋,大巧不工 SpringBoot --- 项目问题汇总及解决
date: 2017-6-12 16:11:09
description: "<center><img src='//image.joylau.cn/blog/springboot-question-tips.png' alt='SpringBoot-Question-Tips.png'></center>  <br>这篇文章打算记录一下平时项目中遇到的各种SpringBoot问题，并记录解决方案<br>持续更新......"
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
update_o: 1
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

## 2017年9月19日更新

### SpringBoot 项目打包时修改 MANIFEST.MF 文件

一般情况下我们的 MANIFEST.MF内容如下：

``` bash
    Manifest-Version: 1.0
    Implementation-Title: joylau-media
    Implementation-Version: 1.7-RELEASE
    Archiver-Version: Plexus Archiver
    Built-By: JoyLau
    Implementation-Vendor-Id: cn.joylau.code
    Spring-Boot-Version: 1.5.4.RELEASE
    Implementation-Vendor: Pivotal Software, Inc.
    Main-Class: org.springframework.boot.loader.JarLauncher
    Start-Class: cn.joylau.code.JoylauMediaApplication
    Spring-Boot-Classes: BOOT-INF/classes/
    Spring-Boot-Lib: BOOT-INF/lib/
    Created-By: Apache Maven 3.5.0
    Build-Jdk: 1.8.0_45
    Implementation-URL: http://projects.spring.io/spring-boot/joylau-media
     /

```



解决：



``` xml
    <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
            <!--fork :  如果没有该项配置，肯呢个devtools不会起作用，即应用不会restart -->
            <fork>true</fork>
        </configuration>
    </plugin>
    
    //修改版本号，一般为pom文件的版本
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <version>3.0.2</version>
        <configuration>
            <archive>
                <manifestEntries>
                    <Manifest-Version>${version}</Manifest-Version>
                </manifestEntries>
            </archive>
        </configuration>
    </plugin>
```




### SpringBoot 项目中引入缓存
- 引入依赖

``` xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-cache</artifactId>
    </dependency>
```

@EnableCaching 开启缓存

@CacheConfig(cacheNames = "api_cache") 配置一个缓存类的公共信息

@Cacheable() 注解到方法上开启缓存

@CachePut() 根据使用的条件来执行具体的方法

@CacheEvict() 根据配置的参数删除缓存

SpringBoot默认支持很多缓存，spring.cache.type就可以知道，默认的是实现的是SimpleCacheManage，这里我记一下怎么设置缓存的超时时间



``` java
    @Configuration
    @EnableCaching
    @EnableScheduling
    public class CachingConfig {
        public static final String CACHENAME = "api_cache";
        @Bean
        public CacheManager cacheManager() {
            return new ConcurrentMapCacheManager(CACHENAME);
        }
        @CacheEvict(allEntries = true, value = {CACHENAME})
        @Scheduled(fixedDelay = 120 * 1000 ,  initialDelay = 500)
        public void reportCacheEvict() {
            System.out.println("Flush Cache " + dateFormat.format(new Date()));
        }
    }
```



这里巧妙的使用了 定时任务，再其加上注解CacheEvict来清除所有cache name 为 api——cache 的缓存，超时时间是120s


### 在说说我比较喜欢的使用方式

单独写了篇文章，戳下面：
- [重剑无锋,大巧不工 SpringBoot --- 推荐使用CaffeineCache](/2017/09/19/SpringBoot-CaffeineCache/)



>> 持续更新中...