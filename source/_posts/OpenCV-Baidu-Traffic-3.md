---
title: OpenCV --- 基于 OpenCV 的百度路况研究记录 (三)
date: 2019-05-10 10:06:41
description: 基于 OpenCV 的百度路况研究记录
categories: [OpenCV篇]
tags: [OpenCV]
---

<!-- more -->
### 背景
本篇研究的内容有:

1. 分析得到的大量拥堵点抽稀处理

2. 拥堵区域骨架提取

3. 部分优化算法和性能



### 抽稀处理
根据之前的处理得到一张瓦片的一块拥堵区域时,需要对其进行结构化数据的分析:将坐标转化为百度坐标系的坐标,坐标转经纬度,拥堵距离计算,

但是一块区域有很多的拥堵点,如果要对每个点进行操作计算的话,会导致性能问题,而且对于密集的点来说

意义不大,没有必要这么做,如果说能够给这些点进行稀释处理,仅仅分析稀释后点,那么既能保证数据的正确性,又能提升算法的性能


算法的基本思想: 连接起点 A 和终点 B, 找出某一点到线段 AB 距离 S 最大的点 P, 如果 S 小于手动设置的阈值 H, 则舍弃其他点,直接连接 A B, 抽稀完成

如 S > H , 则以 P 为终点, 分别计算 2 端 AP 和 PB 上点到相应线段的最大距离,再重复上述步骤, 直到所有的距离均小于 S , 抽稀完成 


抽稀结果示例:
![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-2.27.04.png)  

上图中,已经将上面的拥堵部分大量点稀释的只剩下 3 个点了,这三个点还是位于原来的轨迹上, 可能看的不太清楚,放大了看  

![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-2.27.19.png)  
![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-2.27.26.png)  

示例 2 :

![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-4.15.27.png)  

对于抽稀最大直观效果,我通过下面 2 张动图来演示:  

抽稀前:  
![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-2.02.49.gif)

抽稀后:
![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-2.05.08.gif)


### 骨架提取
骨架提取是指从原来的图中层层剥离点,最后仍然要保持原来的形状

算法基本思想: 
![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-16-52-57.jpeg)

效果示例:

我以这张拥堵瓦片图来看, 我提取出左上角的拥堵部分来处理

![](//s3.joylau.cn:9000/blog/baidu-traffic/17.png)

轮廓提取:

![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-2.24.43.png)

填充内部:
![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-2.24.59.png)

上述 2 中图进行加运算, 得到整个拥堵部分,再进行骨架提取:

![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-2.25.07.png)

已经得到最小化的骨架了,基本上都是 1 像素值,这对后续的处理很有利,再放大点看:
![](//s3.joylau.cn:9000/blog/baidu-traffic/2019-04-30-2.25.24.png)

最后,我录了个视频，以展示目前的演示效果:
<center><video src="//s3.joylau.cn:9000/blog/baidu-traffic/traffic-demo.mp4" loop="true" controls="controls">您的浏览器版本太低，无法观看本视频</video></center>



