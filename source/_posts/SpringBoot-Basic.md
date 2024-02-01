---
title: 重剑无锋,大巧不工 SpringBoot --- 基础篇
date: 2017-3-13 16:07:01
description: 纵横江湖三十余载，杀尽仇寇，败尽英雄，天下更无敌手，无可柰何，惟隐居深谷，以雕为友。呜呼，生平求一敌手而不可得，诚寂寥难堪也。</br>第一柄剑长四尺，锋利无比，剑下石片下写着：「凌厉刚猛，无坚不摧，弱冠前以之与河朔群雄争锋。」</br>第二片石片上没有剑，下面写着：「紫薇软剑，三十岁前所用，误伤义士不祥，悔恨无已，乃弃之深谷。」</br>第三柄武器：「重剑无锋，大巧不工。四十岁前恃之横行天下。」</br>第四柄木剑，石片上文字道：「四十岁之后不滞于物，草木竹石均可为剑。自此精进，渐入无剑胜有剑之境。」
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->
![SpringBoot-Start](//s3.joylau.cn:9000/blog/springbootstart.png)

## 说明
> - 玄铁重剑是神雕侠侣中杨过的兵器，外表看似笨重无比，但内在却精致有细。
> - 在脚本语言和敏捷开发大行其道的时代，JavaEE的开发显得尤为笨重，这使得很多开发人员本应该如此，Spring在提升JavaEE的开发效率上从未停止过努力，SpringBoot的出现时具有颠覆性和划时代意义的。

## 开始准备
- JDK1.7+
- Maven3.x+
- Tomcat8.5+
- Spring4.3.x+
- IntelliJ IDEA / MyEclipse（强烈推荐IDEA，我认为IDEA目前所有 IDE 中最具备沉浸式的 IDE，**没有之一**）

## 优缺点

### 优点
- `习惯优于配置`：使用SpringBoot只需要很少的配置，在绝大部分时候我们只需要使用默认配置
- 项目极速搭建，可无配置整合其他第三方框架,极大提高开发效率
- 完全不使用XML配置，只使用自动配置和JavaConfig
- 内嵌Servlet容器，可打成jar包独立运行
- 强大的运行时监控
- 浑然天成的集成云计算


### 缺点
- ![流汗](//tb2.bdstatic.com/tb/editor/images/face/i_f10.png?t=20140803)没有

## 优雅的开始
- Spring 官方网站搭建
    1. 访问：http://start.spring.io/
    2. 选择构建工具Maven Project、Spring Boot版本1.5.1以及一些工程基本信息，可参考下图所示
        ![SpringInitializr](//s3.joylau.cn:9000/blog/SpringInitializr.png)
    3. 点击Generate Project下载项目压缩包
    4. 导入到你的工程，如果是IDEA，则需要：
       a.菜单中选择`File–>New–>Project from Existing Sources...`
       b.选择解压后的项目文件夹，点击OK
       c.点击`Import project from external model`并选择Maven，点击Next到底为止。
       d.若你的环境有多个版本的JDK，注意到选择Java SDK的时候请选择Java 7以上的版本
       
       
- IntelliJ IDEA创建（**强烈推荐**）
在File菜单里面选择 New > Project,然后选择Spring Initializr，接着如下图一步步操作即可。
![SpringInitializr](//s3.joylau.cn:9000/blog/SpringInitializr-IDEA.png)
![SpringInitializr-2](//s3.joylau.cn:9000/blog/SpringInitializr-IDEA-2.png)
![SpringInitializr-3](//s3.joylau.cn:9000/blog/SpringInitializr-IDEA-3.png)
![SpringInitializr-4](//s3.joylau.cn:9000/blog/SpringInitializr-IDEA-4.png)

若上述步骤步骤没有出现网络错误导致的无法搭建，基本上已经没有什么问题了

### 项目目录
根据上面的操作已经初始化了一个Spring Boot的框架了，项目结构如下：
![SpringBootProject-view](//s3.joylau.cn:9000/blog/SpringBootProject-view.png)

项目里面基本没有代码，除了几个空目录外，还包含如下几样东西。
- `pom.xml`：Maven构建说明文件。
- `JoylauApplication.java`：一个带有main()方法的类，用于启动应用程序（关键）。
- `JoylauApplicationTests.java`：一个空的Junit测试类，它加载了一个使用Spring Boot字典配置功能的Spring应用程序上下文。
- `application.properties`：一个空的properties文件，你可以根据需要添加配置属性。(还推荐一种yml文件的配置方式)

### 项目文件
我们来看pom.xml文件
    ``` xml
        <parent>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-parent</artifactId>
            <version>1.5.0.RELEASE</version>
            <relativePath/> <!-- lookup parent from repository -->
        </parent>
    ```
这块配置就是Spring Boot父级依赖，有了这个，当前的项目就是Spring Boot项目了，spring-boot-starter-parent是一个特殊的starter,它用来提供相关的Maven默认依赖，使用它之后，常用的包依赖可以省去version标签。


并不是每个人都喜欢继承自spring-boot-starter-parent POM。也有可能我们需要使用的自己的公司标准parent，或者我们更喜欢显式声明所有的Maven配置。
如果不想使用spring-boot-starter-parent，仍然可以通过使用scope = import依赖关系来保持依赖关系管理：
    ``` xml
        <dependencyManagement>
             <dependencies>
                <dependency>
                    <!-- Import dependency management from Spring Boot -->
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-dependencies</artifactId>
                    <version>1.5.0.RELEASE</version>
                    <type>pom</type>
                    <scope>import</scope>
                </dependency>
            </dependencies>
        </dependencyManagement>
    ```
    
该设置不允许使用`spring-boot-dependencies`所述的属性(properties)覆盖各个依赖项，要实现相同的结果，需要在`spring-boot-dependencies`项之前的项目的dependencyManagement中添加一个配置，例如，要升级到另一个Spring Data版本系列，可以将以下内容添加到pom.xml中。
    ``` xml
    <dependencyManagement>
        <dependencies>
            <!-- Override Spring Data release train provided by Spring Boot -->
            <dependency>
                <groupId>org.springframework.data</groupId>
                <artifactId>spring-data-releasetrain</artifactId>
                <version>Fowler-SR2</version>
                <scope>import</scope>
                <type>pom</type>
            </dependency>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>1.5.1.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    ```
    
    
### 项目依赖
#### 起步依赖 spring-boot-starter-xx
Spring Boot提供了很多”开箱即用“的依赖模块，都是以spring-boot-starter-xx作为命名的。举个例子来说明一下这个起步依赖的好处，比如组装台式机和品牌机，自己组装的话需要自己去选择不同的零件，最后还要组装起来，期间有可能会遇到零件不匹配的问题。耗时又消力，而品牌机就好一点，买来就能直接用的，后续想换零件也是可以的。相比较之下，后者带来的效果更好点（这里就不讨论价格问题哈），起步依赖就像这里的品牌机，自动给你封装好了你想要实现的功能的依赖。就比如我们之前要实现web功能，引入了spring-boot-starter-web这个起步依赖。我们来看看spring-boot-starter-web到底依赖了哪些,如下图：
![SpringBoot-starter-web-dependencies](//s3.joylau.cn:9000/blog/SpringBoot-starter-web-dependencies.png)


## 最后
### 项目启动的三种方式
1. `main`方法
![SpringBoot-Start1](//s3.joylau.cn:9000/blog/SpringBoot-Start1.png)
2. 使用命令 `mvn spring-boot:run`在命令行启动该应用，IDEA中该命令在如下位置
![SpringBoot-Start2](//s3.joylau.cn:9000/blog/SpringBoot-Start2.png)
3. 运行`mvn package`进行打包时，会打包成一个可以直接运行的 JAR 文件，使用`java -jar`命令就可以直接运行
![SpringBoot-Start3](//s3.joylau.cn:9000/blog/SpringBoot-Start3.png)
![SpringBoot-Start4](//s3.joylau.cn:9000/blog/SpringBoot-Start4.png)