---
title: Java 代码中使用 Scala
date: 2017-9-26 11:46:26
description: ' Maven 项目中使用 Scala 代码编程'
categories: [Scala篇]
tags: [Scala,Scala]
---
<!-- more -->



将 Scala 依赖 scala-library 和插件 scala-maven-plugin 添加到 Maven 项目中

``` xml
    <dependency>
        <groupId>org.scala-lang</groupId>
        <artifactId>scala-library</artifactId>
        <version>2.11.7</version>
    </dependency>



    <plugin>
    <groupId>net.alchim31.maven</groupId>
    <artifactId>scala-maven-plugin</artifactId>
    <executions>
        <execution>
            <id>scala-compile-first</id>
            <phase>process-resources</phase>
            <goals>
                <goal>add-source</goal>
                <goal>compile</goal>
            </goals>
        </execution>
        <execution>
            <id>scala-test-compile</id>
            <phase>process-test-resources</phase>
            <goals>
                <goal>testCompile</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

更新完上面的内容之后，你需要等待Maven下载完所有的依赖。

安装IDEA插件 `Scala`
现在可以在Java工程中使用Scala代码了
创建新的文件夹src/main/scala；
Scala Maven插件将会识别这些目录，并且编译其中的Scala文件：

``` java
    object BooksProcessor {
      def filterByAuthor(author: String)(implicit books: util.ArrayList[Book]) = {
        books.filter(book => book.getAuthor == author)
      }
     
    }
```
