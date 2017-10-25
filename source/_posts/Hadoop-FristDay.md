---
title: Hadoop 的第一天
date: 2017-10-25 08:52:55
description: 学习 Hadoop 的第一天，在这里记一下学习的心得笔记
categories: [大数据篇]
tags: [Hadoop]
---

<!-- more -->
## 前言
第一天学习 Hadoop 看了不少资料和文档，在这里想总结一下这一天的所学

## 感受
以前一直以为 JavaWeb 和大数据这是2条路子，学了大数据之后就要放下 JavaWeb，就像在项目中使用 Struts2 和 SpringMVC，2者只能选一个使用，在看了一些资料之后，我发现我的认识错了，其实 JavaWeb 和大数据技术就像 SpringMVC 和Spring Boot
2者是并行不悖的。大数据技术囊括很多技术，JavaWeb只是其中的一部分，要学习大数据需要学习的技术还有很多。

## 总结

### Hadoop是干什么的
一句话概括：适合大数据的分布式存储与计算平台

### Hadoop的2个重要部分
- HDFS ： 分布式文件系统
- MapReduce ： 并行计算框架

### HDFS
主从结构：

    主节点： 只有一个 namedode
    
    从节点： 多个 datanode
    
namenode:

    负责接收用户请求
    
    维护文件系统的目录结构
    
    管理文件与 block 之间的关系，block 与 datanode 之间的关系
    
datanode:

    存储文件
    
    文件被分成若干 Block 存储在磁盘上
    
    为保证数据安全，文件会被备份成多个副本
    
### MapReduce
主从结构：

    主节点： 只有一个 JobTracker
    
    从节点： 有多个 TaskTracker
    
JobTracker：

    接受用户提交的任务
    
    把计算任务分配给 TaskTracker 执行
    
    监控 TaskTracker 的执行情况
    
TaskTracker：

    执行 JobTracker 分配的任务