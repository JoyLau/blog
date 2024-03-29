---
title: OpenCV --- 基于 OpenCV 的百度路况研究记录 (二)
date: 2019-05-05 09:52:17
description: 基于 OpenCV 的百度路况研究记录
categories: [OpenCV篇]
tags: [OpenCV]
---

<!-- more -->
### 背景
本篇就之前对于拥堵路段为曲线状且涉及多个路段时分析的结果差强人意的情况进行了算法重构

### 简介
之前算法核心是 找出分段拥堵,并提取信息  
之前算法的缺陷是使用霍夫变换提取瓦片中的直线时, 无法很好的控制参数, 导致在临近的曲线情况下分析结果不正确  
简单示意图:  
![](//s3.joylau.cn:9000/blog/baidu-traffic/8.gif)  


在二维的坐标系中, 控制直线的是参数 m(斜率) 和 b(截距)

转化为极坐标系再化简后,控制直线的参数是  θ (极角) 和 r(极径)

原来的思路是曲线是有很多小部分的直线段构成的,如若能够将曲线分成适合的若干线段,那么同样可以将整个曲线提取出来,继而提取其他信息

这种思路得考虑三种主要的参数:

1. threshold：识别某部分为一条直线时必须达到的值

2. min_theta：检测到的直线的最小角度

3. max_theta：检测到的直线的最大角度



然而经过多次测试,按照这个想法进行处理,结果并不好, 出现更多的结果是

1. 曲线 a 会被他的相邻曲线 b 干扰,继续分析的结果是会从 a 与 b 的相邻端直接跳到 b 曲线上,接着分析的线路走向就会直接沿着 b 走下去, 就是上次截图所示的结果

2. 曲线 a 会有多处幅度较大的弯曲时,会沿着角度大的地方直接放射出去, 例如下面所测试的

### 做法

下面测试的参数

threshold: 65

min_theta: 0

max_theta: 5

![](//s3.joylau.cn:9000/blog/baidu-traffic/9.gif)  

对于形态各异的瓦片图来说,很难调整出一个适当的参数.  

于是我开始重整思路, 但是思路的核心还是不变: 找出分段拥堵  


目前的思路是:

1. 读入瓦片原图(RGBA)

2. 进行色彩空间转换: 将带透明通道的 RGBA 转换为 BGR, 再将 BRG 转化为 HSV 色彩空间,方便颜色的提取

3. 在 HSV 的色彩空间上提取出黄色(缓行)和红色(拥堵), 并各自区分保存

4. 得到的图像信息二值化, 方便下一步处理

5. 在二值化的图像上提取黄色和红色的边缘信息, 分析边缘信息得到分段拥堵的外包矩形

6. 已有的黄,红拥堵段做外包矩形的位置定位,得出分段拥堵信息

7. 大量坐标点抽稀处理


开发一系列流程截图如下:

![](//s3.joylau.cn:9000/blog/baidu-traffic/10.gif)  

图示的顺序依次对应思路的步骤, 在最后一张图中,已经将分析出来的分段拥堵信息再绘制到原图上, 准确度很高  

对于之前算法没有解决的瓦片,这个算法暂时算是解决了,那么面对更加复杂的拥堵情况呢?  

为此我特地抽取了北京天安门附近的拥堵瓦片图  

![](//s3.joylau.cn:9000/blog/baidu-traffic/11.gif)  

这张图里反应的拥堵情况应该很具有代表性了,下面再用此算法对这张图进行分析:  

![](//s3.joylau.cn:9000/blog/baidu-traffic/12.gif)  

值得一提的是, 前一张图片处理耗时时间是: 0.08534727 s; 而后一张图片处理的时间是: 0.084427357 s, 时间基本无差.