---
title: CentOS 和 Ubuntu 上编译安装 OpenCV4 及 SpringBoot 的结合使用
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


### 编译好的包
1. centos7 版: http://cloud.joylau.cn:1194/s/kUoNelmj1SX810K 或者  https://pan.baidu.com/s/1qaZ-TbF0xP0DxaEJKbdt-A 提取码: jkir
2. Ubuntu 16.04 版: http://cloud.joylau.cn:1194/s/TsNRKwxJhM0v0HE  或者  https://pan.baidu.com/s/1ha6nATLrSt5WPL1iQlmWSg 提取码: gduu
3. java 调用所需 opencv-410.jar 包: http://image.joylau.cn/blog/opencv-410.jar


### IDEA 及 Spring Boot 项目中的使用
1. 下载 opencv-410.jar 包,引入到项目中

```groovy
   dependencies {
       implementation 'org.springframework.boot:spring-boot-starter-web'
       compileOnly 'org.projectlombok:lombok'
       annotationProcessor 'org.projectlombok:lombok'
       testImplementation 'org.springframework.boot:spring-boot-starter-test'
   
       compile fileTree(dir:'libs',include:['*.jar'])
   } 
```
2. 配置动态库路径, vm options: -Djava.library.path=/home/joylau/opencv4/opencv/build/lib

![vm options](http://image.joylau.cn/blog/vm_options_config.jpg)


3. 加载动态库

```java
    @SpringBootApplication
    public class OpencvTestApplication {
    
        public static void main(String[] args) {
            System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
            System.out.println(Core.VERSION);
            SpringApplication.run(OpencvTestApplication.class, args);
        }
    }
```

4. 脸部识别 demo

``` java
    private static void testFace() {
            // 1 读取OpenCV自带的人脸识别特征XML文件
            CascadeClassifier facebook = new CascadeClassifier("/home/joylau/opencv4/opencv/data/haarcascades/haarcascade_frontalface_alt.xml");
            // 2 读取测试图片
            Mat image = Imgcodecs.imread("/home/joylau/图片/image-test-4.jpg");
            // 3 特征匹配
            MatOfRect face = new MatOfRect();
            facebook.detectMultiScale(image, face);
            // 4 匹配 Rect 矩阵 数组
            Rect[] rects = face.toArray();
            System.out.println("匹配到 " + rects.length + " 个人脸");
            // 5 为每张识别到的人脸画一个框
            for (int i = 0; i < rects.length; i++) {
                Imgproc.rectangle(image,new Point(rects[i].x, rects[i].y), new Point(rects[i].x + rects[i].width, rects[i].y + rects[i].height), new Scalar(0, 0, 255));
                Imgproc.putText(image,"face-" + i, new Point(rects[i].x, rects[i].y),Imgproc.FONT_HERSHEY_SIMPLEX, 1.0, new Scalar(0, 255, 0),1,Imgproc.LINE_AA,false);
            }
            // 6 展示图片
            HighGui.imshow("人脸-匹配", image);
            HighGui.waitKey(0);
        }
```

![test_face](http://image.joylau.cn/blog/opencv_test_face.jpg)

> 注: 图片来自微博

5. 边缘检测 demo

``` java
    private static void testContours() {
            //1 获取原图
            Mat src = Imgcodecs.imread("/home/joylau/图片/image-test.jpg");
            //2 图片灰度化
            Mat gary = new Mat();
            Imgproc.cvtColor(src, gary, Imgproc.COLOR_RGB2GRAY);
            //3 图像边缘处理
            Mat edges = new Mat();
            Imgproc.Canny(gary, edges, 200, 500, 3, false);
            //4 发现轮廓
            List<MatOfPoint> list = new ArrayList<MatOfPoint>();
            Mat hierarchy = new Mat();
            Imgproc.findContours(edges, list, hierarchy, Imgproc.RETR_TREE, Imgproc.CHAIN_APPROX_SIMPLE);
            //5 绘制轮廓
            for (int i = 0, len = list.size(); i < len; i++) {
                Imgproc.drawContours(src, list, i, new Scalar(0, 255, 0), 1, Imgproc.LINE_AA);
            }
            HighGui.imshow("边缘检测", src);
            HighGui.waitKey(0);
        }
```

![test_source](http://image.joylau.cn/blog/image-test.jpg)
![test_contours](http://image.joylau.cn/blog/test_contours.jpg)

