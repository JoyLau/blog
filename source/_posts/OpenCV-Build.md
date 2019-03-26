---
title: CentOS , Ubuntu 和 Mac OS 上编译安装 OpenCV4 及 SpringBoot 的结合使用
date: 2019-03-15 15:41:23
description: 记录下 CentOS , Ubuntu 和 Mac OS 上编译安装 OpenCV
categories: [OpenCV篇]
tags: [OpenCV]
---

<!-- more -->
### 为什么没有 Windows 下的编译安装
因为官网已经提供的编译好的 exe 包,双击运行就会解压到特定的目录了,除此之外官网还提供了 ios 版和 安卓版
这里着重记录下 CentOS , Ubuntu 和 Mac OS 下的安装,因为官网没有提供编译好的包

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


### 编译好的包
1. centos7 版: http://cloud.joylau.cn:1194/s/kUoNelmj1SX810K 或者  https://pan.baidu.com/s/1qaZ-TbF0xP0DxaEJKbdt-A 提取码: jkir
2. Ubuntu 16.04 版: http://cloud.joylau.cn:1194/s/TsNRKwxJhM0v0HE  或者  https://pan.baidu.com/s/1ha6nATLrSt5WPL1iQlmWSg 提取码: gduu
3. java 调用所需 opencv-410.jar 包: http://image.joylau.cn/blog/opencv-410.jar



### Mac OS 上
1. AppStore 上安装 XCode, 安装完成打开 XCode , 同意 license
2. 安装 HomeBrew
3. 安装必要依赖: Python 3, CMake and Qt 5

```bash
    brew install python3
    brew install cmake
    brew install qt5
```

4. 安装环境

```bash
    mkdir ~/opencv4
    git clone https://github.com/opencv/opencv.git
    git clone https://github.com/opencv/opencv_contrib.git
    
    # 变量定义
    cwd=$(pwd)
    cvVersion="master"
    QT5PATH=/usr/local/Cellar/qt/5.12.2
    
    rm -rf opencv/build
    rm -rf opencv_contrib/build
    
    # Create directory for installation
    mkdir -p installation/OpenCV-"$cvVersion"
    
    sudo -H pip3 install -U pip numpy
    # Install virtual environment
    sudo -H python3 -m pip install virtualenv virtualenvwrapper
    VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
    echo "VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3" >> ~/.bash_profile
    echo "# Virtual Environment Wrapper" >> ~/.bash_profile
    echo "source /usr/local/bin/virtualenvwrapper.sh" >> ~/.bash_profile
    cd $cwd
    source /usr/local/bin/virtualenvwrapper.sh
     
    ############ For Python 3 ############
    # create virtual environment 由于 mac OS 本身使用的是 Python 2.7 , 而一些本身的应用依赖于 Python 2 ,为了不影响原来的环境,这里创建一个 Python3 的虚拟环境来进行编译
    mkvirtualenv OpenCV-"$cvVersion"-py3 -p python3
    workon OpenCV-"$cvVersion"-py3
      
    # now install python libraries within this virtual environment
    pip install cmake numpy scipy matplotlib scikit-image scikit-learn ipython dlib
      
    # quit virtual environment
    deactivate
    ######################################
    
    cd opencv
    mkdir build
    cd build
    
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
                -D CMAKE_INSTALL_PREFIX=$cwd/installation/OpenCV-"$cvVersion" \
                -D INSTALL_C_EXAMPLES=ON \
                -D INSTALL_PYTHON_EXAMPLES=ON \
                -D WITH_TBB=ON \
                -D WITH_V4L=ON \
                -D OPENCV_SKIP_PYTHON_LOADER=ON \
                -D CMAKE_PREFIX_PATH=$QT5PATH \
                -D CMAKE_MODULE_PATH="$QT5PATH"/lib/cmake \
                -D OPENCV_PYTHON3_INSTALL_PATH=~/.virtualenvs/OpenCV-"$cvVersion"-py3/lib/python3.7/site-packages \
            -D WITH_QT=ON \
            -D WITH_OPENGL=ON \
            -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
            -D BUILD_EXAMPLES=ON ..
    
    make -j$(sysctl -n hw.physicalcpu)
    make install
     
```

5. cmake 后输出如下:

```bash
    --   OpenCV modules:
    --     To be built:                 aruco bgsegm bioinspired calib3d ccalib core cvv datasets dnn dnn_objdetect dpm face features2d flann freetype fuzzy gapi hfs highgui img_hash imgcodecs imgproc java java_bindings_generator line_descriptor ml objdetect optflow phase_unwrapping photo plot python2 python3 python_bindings_generator quality reg rgbd saliency shape stereo stitching structured_light superres surface_matching text tracking ts video videoio videostab xfeatures2d ximgproc xobjdetect xphoto
    --     Disabled:                    world
    --     Disabled by dependency:      -
    --     Unavailable:                 cnn_3dobj cudaarithm cudabgsegm cudacodec cudafeatures2d cudafilters cudaimgproc cudalegacy cudaobjdetect cudaoptflow cudastereo cudawarping cudev hdf js matlab ovis sfm viz
    --     Applications:                tests perf_tests examples apps
    --     Documentation:               NO
    --     Non-free algorithms:         NO
    -- 
    --   GUI: 
    --     QT:                          YES (ver 5.12.2)
    --       QT OpenGL support:         YES (Qt5::OpenGL 5.12.2)
    --     Cocoa:                       YES
    --     OpenGL support:              YES (/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/System/Library/Frameworks/OpenGL.framework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/System/Library/Frameworks/OpenGL.framework)
    --     VTK support:                 NO
    -- 
    --   Media I/O: 
    --     ZLib:                        build (ver 1.2.11)
    --     JPEG:                        build-libjpeg-turbo (ver 2.0.2-62)
    --     WEBP:                        build (ver encoder: 0x020e)
    --     PNG:                         build (ver 1.6.36)
    --     TIFF:                        build (ver 42 - 4.0.10)
    --     JPEG 2000:                   build (ver 1.900.1)
    --     OpenEXR:                     build (ver 1.7.1)
    --     HDR:                         YES
    --     SUNRASTER:                   YES
    --     PXM:                         YES
    --     PFM:                         YES
    -- 
    --   Video I/O:
    --     DC1394:                      NO
    --     FFMPEG:                      YES
    --       avcodec:                   YES (58.35.100)
    --       avformat:                  YES (58.20.100)
    --       avutil:                    YES (56.22.100)
    --       swscale:                   YES (5.3.100)
    --       avresample:                YES (4.0.0)
    --     GStreamer:                   NO
    --     AVFoundation:                YES
    --     v4l/v4l2:                    NO
    -- 
    --   Parallel framework:            GCD
    -- 
    --   Trace:                         YES (with Intel ITT)
    -- 
    --   Other third-party libraries:
    --     Intel IPP:                   2019.0.0 Gold [2019.0.0]
    --            at:                   /Users/joylau/opencv4/opencv/build/3rdparty/ippicv/ippicv_mac/icv
    --     Intel IPP IW:                sources (2019.0.0)
    --               at:                /Users/joylau/opencv4/opencv/build/3rdparty/ippicv/ippicv_mac/iw
    --     Lapack:                      YES (/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/System/Library/Frameworks/Accelerate.framework)
    --     Eigen:                       NO
    --     Custom HAL:                  NO
    --     Protobuf:                    build (3.5.1)
    -- 
    --   OpenCL:                        YES (no extra features)
    --     Include path:                NO
    --     Link libraries:              -framework OpenCL
    -- 
    --   Python 2:
    --     Interpreter:                 /usr/bin/python2.7 (ver 2.7.10)
    --     Libraries:                   /usr/lib/libpython2.7.dylib (ver 2.7.10)
    --     numpy:                       /System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/numpy/core/include (ver 1.8.0rc1)
    --     install path:                lib/python2.7/site-packages
    -- 
    --   Python 3:
    --     Interpreter:                 /usr/local/bin/python3 (ver 3.7.2)
    --     Libraries:                   /usr/local/Frameworks/Python.framework/Versions/3.7/lib/libpython3.7m.dylib (ver 3.7.2)
    --     numpy:                       /usr/local/lib/python3.7/site-packages/numpy/core/include (ver 1.16.2)
    --     install path:                /Users/joylau/.virtualenvs/OpenCV-master-py3/lib/python3.7/site-packages
    -- 
    --   Python (for build):            /usr/bin/python2.7
    -- 
    --   Java:                          
    --     ant:                         /Users/joylau/dev/apache-ant-1.10.5/bin/ant (ver 1.10.5)
    --     JNI:                         /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/System/Library/Frameworks/JavaVM.framework/Headers /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/System/Library/Frameworks/JavaVM.framework/Headers /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.14.sdk/System/Library/Frameworks/JavaVM.framework/Headers
    --     Java wrappers:               YES
    --     Java tests:                  YES
    -- 
    --   Install to:                    /Users/joylau/opencv4/installation/OpenCV-master
    -- -----------------------------------------------------------------
    -- 
    -- Configuring done
    -- Generating done
    -- Build files have been written to: /Users/joylau/opencv4/opencv/build
```

6. 编译好的安装包: http://cloud.joylau.cn:1194/s/6GMLl09ZAYNAUMU 或者: https://pan.baidu.com/s/1YBxUD_vB1zKOcxHeAtn6Xw 提取码: twsq 

### 遇到的问题

#### CentOS 上 CMake 版本太低的解决方法
1. yum 上安装的版本太低,先卸载掉版本低的,yum remove cmake
2. cd /opt
   tar zxvf cmake-3.10.2-Linux-x86_64.tar.gz

3. vim /etc/profile
   export CMAKE_HOME=/opt/cmake-3.10.2-Linux-x86_64 
   export PATH=$PATH:$CMAKE_HOME/bin

4. source /etc/profile 

#### 没有生成 opencv-410.jar 

``` bash
    Java:                          
    --     ant:                         /bin/ant (ver 1.9.4)
    --     JNI:                         /usr/lib/jvm/java-1.8.0-openjdk/include /usr/lib/jvm/java-1.8.0-openjdk/include/linux /usr/lib/jvm/java-1.8.0-openjdk/include
    --     Java wrappers:               YES
    --     Java tests:                  NO

```

需要 ant 环境,安装后即可, java 即可进行调用

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

mac os 下路径为: -Djava.library.path=/Users/joylau/opencv4/installation/OpenCV-master/share/java/opencv4


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


6. 实时人脸识别

``` java
    /**
         * OpenCV-4.0.0 实时人脸识别
         *
         */
        public static void videoFace() {
            VideoCapture capture=new VideoCapture(0);
            Mat image=new Mat();
            int index=0;
            if (capture.isOpened()) {
                do {
                    capture.read(image);
                    HighGui.imshow("实时人脸识别", getFace(image));
                    index = HighGui.waitKey(1);
                } while (index != 27);
            }
        }
    
        /**
         * OpenCV-4.0.0 人脸识别
         * @param image 待处理Mat图片(视频中的某一帧)
         * @return 处理后的图片
         */
        public static Mat getFace(Mat image) {
            // 1 读取OpenCV自带的人脸识别特征XML文件
            CascadeClassifier facebook=new CascadeClassifier("/Users/joylau/opencv4/opencv/data/haarcascades/haarcascade_frontalface_alt.xml");
            // 2  特征匹配类
            MatOfRect face = new MatOfRect();
            // 3 特征匹配
            facebook.detectMultiScale(image, face);
            Rect[] rects=face.toArray();
            log.info("匹配到 "+rects.length+" 个人脸");
            // 4 为每张识别到的人脸画一个圈
            for (Rect rect : rects) {
                Imgproc.rectangle(image, new Point(rect.x, rect.y), new Point(rect.x + rect.width, rect.y + rect.height), new Scalar(0, 255, 0));
                Imgproc.putText(image, "Human", new Point(rect.x, rect.y), Imgproc.FONT_HERSHEY_SIMPLEX, 2.0, new Scalar(0, 255, 0), 1, Imgproc.LINE_AA, false);
                //Mat dst=image.clone();
                //Imgproc.resize(image, image, new Size(300,300));
            }
            return image;
        }
```

<center><video src="http://image.joylau.cn/blog/opencv-video-face.mp4" loop="true" controls="controls">您的浏览器版本太低，无法观看本视频</video></center>