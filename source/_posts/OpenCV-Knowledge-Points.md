---
title: OpenCV --- 知识点速记
date: 2019-05-17 10:50:34
description: OpenCV 知识点速记
categories: [OpenCV篇]
tags: [OpenCV]
---

<!-- more -->
#### CV type 的转换
CV_8UC3 转 CV_8UC1 : convertTo 或者 cvtColor
CV_8UC1 转 CV_8UC3 : cvtColor (灰度相同,通道已经转化, CV_GRAY2RGB)

#### Mat 初始化
Mat.zeros: 创建全 0 矩阵
Mat.ones: 创建全 1 矩阵
Mat.eye: 创建单位矩阵

#### 零碎
1. 判断点与多边形的关系: pointPolygonTest  
2. ROI 区域: Rect(col,row,width,height)
    1. col: x 坐标 (坐标以 0 开始, 左上角 0,0)
    2. row: y 坐标
    3. width: 宽度
    4. height: 高度






