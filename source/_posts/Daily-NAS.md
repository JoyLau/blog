---
title: 日常折腾 --- 蜗牛星际安装黑群晖
date: 2019-05-27 10:29:53
img: <center><img src='http://image.joylau.cn/blog/daily-nas.png' alt='daily-nas'></center>
description: 蜗牛星际安装黑群晖
categories: [日常折腾篇]
tags: [日常折腾]
---

<!-- more -->
### 背景
前一段时间矿难,坑了 20 亿, 5600 多的矿机现在 200 多的甩卖

### 蜗牛星际
蜗牛星际指的是这批矿机的名字, 现一共有四款
型号根据网口数据不一样也有不一样的叫法。一个网口称为单，两个网口称为双。
分别有：A单，A双；B单，B双；C单，C双；D单。  
下面是网络上整理的一个表单

![](http://image.joylau.cn/blog/heiqun_catg.jpg)

我买的是 B 款单网口的 intel i211 的网卡
双网卡,还有一个网卡是 82583 需要短接主板上 2 个触电可完美使用双千兆

### 安装黑群晖
#### 方式一 
U 盘作为引导启动盘, 系统装入主板上的 16 G SATA 盘
#### 方式二
将引导系统和系统主程序都装入 sata 盘上

我选择的是第二种，因为我不想插着个 U 盘在后面的主板上，而且我也没有那么小的U盘

#### 方式一安装步骤
0. 所需资料: 链接: https://pan.baidu.com/s/1Dk220UoOpDFuTjSV9dUAHw 提取码: c32z 
1. 插入优盘, 使用芯片精灵查看 U盘的 vid 和 pid ,记录下来
2. 将引导系统写入 U 盘
3. 打开 U盘,找到 grub.cfg 文件,修改 pid 和 vid 和 U 盘中的一致即可
4. 重启
5. 找到机器的 IP,在浏览器上打开,端口默认是 5000, 在线安装最先的版本即可

#### 方式二安装步骤
1. U 盘上安装一份 PE 系统，这里推荐使用微 PE
2. 将系统镜像 和 写盘工具 拷贝到 U 盘上：链接: https://pan.baidu.com/s/1T2KibqcSi6t99BPq8VQA7g 提取码: y7x5 ; 链接: https://pan.baidu.com/s/1QhAkpGxjYoJiKGgMSdFhyQ 提取码: 1s45 
3. 进入 PE 系统，使用 diskgenius 删除 ssd 上的所有分区，再使用写盘工具将镜像写入 ssd 上
4. 重启系统

### 如何洗白?
想要洗白, 修改 grub.cfg 配置文件的 sn 和 mac 地址即可  
mac 地址需要是 001132 开头的  
这就需要修改机器的物理 IP  
我这里提供一个方法: 链接: https://pan.baidu.com/s/1km_LpQprkxPvpQOoe8Pq9w 提取码: qsvd   
SN 需要算号器,我这里提供个工具: 链接: https://pan.baidu.com/s/1-k9Wp82occb6IzUxt37EBw 提取码: yxj6

### 建议
1. 自带的 ZUMAX 电源并不是很好,带 4 块硬盘怕只能呵呵,想稳定点还是换个好点的电源,我换了台达 80 金牌 DPS-400AB-12A 1U 电源
2. 有条件的话,硬盘的背板也还是换了吧,看着做工不是很好

### 关于洗白
个人的建议是:不要洗白!

1. 因为洗白的主要是用群晖的快连功能,但是据我所用快连的速度并不是很好,还不如自建内网穿透服务  
2. 容易被检测出来,容易被封号,一旦被封号,系统显示硬盘损毁,数据拷贝不出来,就损失大了  

黑群一时爽,一直黑群一直爽