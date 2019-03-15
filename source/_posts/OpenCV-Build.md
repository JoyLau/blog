---
title: Linux(CentOS, Ubuntu) 编译安装 OpenCV4
date: 2019-03-15 15:41:23
description: 记录下 CentOS 和 Ubuntu 编译安装 OpenCV
categories: [OpenCV篇]
tags: [OpenCV]
---

<!-- more -->
### 为什么没有 Windows 下的编译安装
因为官网已经提供的编译好的 exe 包,双击运行就会解压到特定的目录了,除此之外官网还提供了 ios 版和 安卓版
这里着重记录下 CentOS 和 Ubuntu 下的安装,因为官网没有提供编译好的包

### 条件
1. GCC 4.4.x or later
2. CMake 2.8.7 or higher
3. Git
4. GTK+2.x or higher, including headers (libgtk2.0-dev)
5. pkg-config
6. Python 2.6 or later and Numpy 1.5 or later with developer packages (python-dev, python-numpy)
7. ffmpeg or libav development packages: libavcodec-dev, libavformat-dev, libswscale-dev
8. [optional] libtbb2 libtbb-dev
9. [optional] libdc1394 2.x
10. [optional] libjpeg-dev, libpng-dev, libtiff-dev, libjasper-dev, libdc1394-22-dev
11. [optional] CUDA Toolkit 6.5 or higher

### 步骤
1. 安装常用的开发编译工具包, Centos 的命令为: yum groupinstall "Development Tools", Ubuntu 的命令为: apt-get install build-essential
2. 安装 cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev
3. mkdir opencv4; cd opencv4
4. git clone https://github.com/opencv/opencv.git
5. git clone https://github.com/opencv/opencv_contrib.git
6. cd opencv
7. mkdir build
8. cd build
9. cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local ..  (如果不工作的话,删除 -D的空格,cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local ..)
10. make -j7 # runs 7 jobs in parallel 使用7个并行任务来编译
11. 生成文档 cd ~/opencv/build/doc/; make -j7 doxygen
12. make install

### CentOS 上 CMake 版本太低的解决方法
1. yum 上安装的版本太低,先卸载掉版本低的,yum remove cmake
2. cd /opt
   tar zxvf cmake-3.10.2-Linux-x86_64.tar.gz

3. vim /etc/profile
   export CMAKE_HOME=/opt/cmake-3.10.2-Linux-x86_64 
   export PATH=$PATH:$CMAKE_HOME/bin

4. source /etc/profile 

### 没有生成 opencv-410.jar 

``` bash
    Java:                          
    --     ant:                         /bin/ant (ver 1.9.4)
    --     JNI:                         /usr/lib/jvm/java-1.8.0-openjdk/include /usr/lib/jvm/java-1.8.0-openjdk/include/linux /usr/lib/jvm/java-1.8.0-openjdk/include
    --     Java wrappers:               YES
    --     Java tests:                  NO

```

需要 ant 环境,安装后即可, java 即可进行调用




