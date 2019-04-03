---
title: OpenCV 读取数据流图片
date: 2019-04-03 10:54:28
description: OpenCV 提供的 API 是直接根据路径读取图片的,那么该如何读取 byte[] 的图片呢?
categories: [OpenCV篇]
tags: [OpenCV]
---

<!-- more -->
### 背景
OpenCV 提供的 API 是直接根据路径读取图片的, 在实际生产环境中,可能大部分情况下都是直接读取网络图片

在内存就完成图片和 opencv 的 Mat 对象的转换

那么该如何读取 byte[] 的图片呢?

### API
openCV 提供的 API

``` java
    Mat src = Imgcodecs.imread("/static/img/17.png");
```

很简单的就转化为 Mat 对象

而 该方法后面还有一个参数, flags, 该参数可选项有:

- **IMREAD_UNCHANGED** = -1,
- **IMREAD_GRAYSCALE** = 0,
- **IMREAD_COLOR** = 1,
- **IMREAD_ANYDEPTH** = 2,
- **IMREAD_ANYCOLOR** = 4,
- **IMREAD_LOAD_GDAL** = 8,
- **IMREAD_REDUCED_GRAYSCALE_2** = 16,
- **IMREAD_REDUCED_COLOR_2** = 17,
- **IMREAD_REDUCED_GRAYSCALE_4** = 32,
- **IMREAD_REDUCED_COLOR_4** = 33,
- **IMREAD_REDUCED_GRAYSCALE_8** = 64,
- **IMREAD_REDUCED_COLOR_8** = 65,
- **IMREAD_IGNORE_ORIENTATION** = 128;


IMREAD_UNCHANGED: 以图片原有的方式读入,不进行任何改变
IMREAD_GRAYSCALE: 以灰度图读取
IMREAD_COLOR: 以彩色图读取

### 过渡
为了支持 OpenCV 读取 byte[] 的图片,为此我查找了很多资料做了大量的实验,有很多失败报错了,也有读取成功的,下面我将一一列举出来....


### 读取失败
#### Converters 类
我留意到 opencv 提供的 api 里有一个 `utils` 包, 里面有个转换类 `Converters`, 可以将 Mat 和 一些 java 的基本数据类型进行互相转换,其中有这样 2 个方法: `vector_uchar_to_Mat` 和 `vector_char_to_Mat`
参数是 `List<Byte>`

``` java
    private static Mat testConvertChar2Mat(byte[] bytes){
        @SuppressWarnings("unchecked")
        List<Byte> bs = CollectionUtils.arrayToList(bytes);
        return Converters.vector_uchar_to_Mat(bs);
//        return Converters.vector_char_to_Mat(bs);
    }
```

`vector_uchar_to_Mat`  指有符号

转换出来的图片是一个像素的竖直线,读取失败


#### new Mat
Mat 对象除了转化得到,还可以 new , 再利用 Mat 的 put 方法,来创建 Mat

``` java
    private static Mat testNewMat(int height, int width, byte[] bytes) throws IOException {
        Mat data = new Mat(height, width, CvType.CV_8UC3);
        data.put(0, 0, bytes);
        return data;
    }
```

转换出来的图片也不对,一些花花绿绿的像素点


#### new BufferByte
Mat 对象还有个构造方法,最后一个参数是传入 BufferByte,这时只需要在上述步骤中再将 byte[] 转化为 BufferByte

``` java
    private static Mat testNewBuffer(int height, int width, byte[] bytes){
        ByteBuffer byteBuffer = ByteBuffer.wrap(bytes);
        return new Mat(height, width, CvType.CV_8UC3,byteBuffer);
    }
```

抛出异常: **CvException [org.opencv.core.CvException: cv::Exception: OpenCV(4.1.0-pre) /Users/joylau/opencv4/opencv/modules/core/include/opencv2/core/mat.inl.hpp:548: error: (-215:Assertion failed) total() == 0 || data != NULL in function 'Mat'**

### 读取成功
#### BufferedImage 转换
一次我在调试代码时 发现` HighGui.waitKey();` 的实现是将 Mat 对象转化为 BufferedImage 的逻辑,于是我明白了,OpenCV 里操作的 Mat 在显示的时候也需要转化为 BufferedImage
源码里有这样一段代码

``` java
    public static Image toBufferedImage(Mat m) {
        int type = BufferedImage.TYPE_BYTE_GRAY;

        if (m.channels() > 1) {
            type = BufferedImage.TYPE_3BYTE_BGR;
        }

        int bufferSize = m.channels() * m.cols() * m.rows();
        byte[] b = new byte[bufferSize];
        m.get(0, 0, b); // get all the pixels
        BufferedImage image = new BufferedImage(m.cols(), m.rows(), type);

        final byte[] targetPixels = ((DataBufferByte) image.getRaster().getDataBuffer()).getData();
        System.arraycopy(b, 0, targetPixels, 0, b.length);

        return image;
    }
```

此时,我逆向转化,将 byte[] 转 BufferedImage ,BufferedImage 再转 Mat 即可


``` java
    private static byte[] getBufferedImageByte(byte[] bytes) throws IOException{
        BufferedImage bImage = ImageIO.read(new ByteArrayInputStream(bytes));
        return ((DataBufferByte) bImage.getRaster().getDataBuffer()).getData();
    }
    
    // 再将从 BufferedImage 得到的 byte[] 使用 new Mat 对象
    private static Mat testNewMat(int height, int width, byte[] bytes) throws IOException {
        Mat data = new Mat(height, width, CvType.CV_8UC3);
        data.put(0, 0, bytes);
        return data;
    }
```

该方法成功读取显示了图片

于是又引发了我的思考: 为什么直接从文件读取的 byte[] 无法被转化,而 BufferedImage 中得到的 byte[] 却可以被转化

于是我将 BufferedImage 中得到的 byte[] 在使用,调用 `Converters.vector_char_to_Mat` 方法

可惜却失败了.....


#### imdecode
Imgcodecs 类中有一个编码的方法 `Imgcodecs.imdecode(Mat buf, int flags)`
Mat 还有个子类 MatOfByte

``` java
    private static Mat testImdecode(byte[] bytes){
        return Imgcodecs.imdecode(new MatOfByte(bytes), Imgcodecs.IMREAD_COLOR);
    }
```

该方法可成功转化

而且比上一个方法的优势是:

1. byte[] 不需要再通过 BufferedImage 转化
2. 不需要初始化 Mat 的长和宽


为此还可以逆向得出 Mat 转换成 byte[] 的方法

``` java
    /**
     * Mat转换成byte数组
     *
     * @param matrix        要转换的Mat
     * @param fileExtension 格式为 ".jpg", ".png", etc
     */
    public static byte[] mat2Byte(Mat matrix, String fileExtension) {
        MatOfByte mob = new MatOfByte();
        Imgcodecs.imencode(fileExtension, matrix, mob);
        return mob.toArray();
    }
```



### 最后
以下是全部测试代码

``` java
    /**
     * Created by liuf on 2019-04-01.
     * cn.joylau.code
     * liuf@ahtsoft.com
     */
    @Slf4j
    public class Byte2Mat {
    
        public static void main(String[] args) throws Exception {
            System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    
    //        Mat mat = testImdecode(getImageByte());
    
    //        Mat mat = testConvertChar2Mat(getBufferedImageByte(getImageByte()));
    
    
    //        Mat mat = testNewBuffer(480,480,getImageByte());
    
    //        Mat mat = testNewMat(480,480,getImageByte());
    
            Mat mat = testNewMat(480,480,getBufferedImageByte(getImageByte()));
    
            log.info("{},{}",mat.rows(),mat.cols());
            HighGui.imshow("byte2mat",mat);
            HighGui.waitKey();
            HighGui.destroyAllWindows();
        }
    
        private static byte[] getImageByte() throws IOException{
            Resource resource = new FileSystemResource("/Users/joylau/work/anhui-project/traffic-service-layer/src/main/resources/static/img/1.jpg");
            return IOUtils.toByteArray(resource.getInputStream());
        }
    
        private static byte[] getBufferedImageByte(byte[] bytes) throws IOException{
            BufferedImage bImage = ImageIO.read(new ByteArrayInputStream(bytes));
            return ((DataBufferByte) bImage.getRaster().getDataBuffer()).getData();
        }
    
    
        private static Mat testNewMat(int height, int width, byte[] bytes) throws IOException {
            Mat data = new Mat(height, width, CvType.CV_8UC3);
            data.put(0, 0, bytes);
            return data;
        }
    
        private static Mat testNewBuffer(int height, int width, byte[] bytes){
            ByteBuffer byteBuffer = ByteBuffer.wrap(bytes);
            return new Mat(height, width, CvType.CV_8UC3,byteBuffer);
        }
    
    
        private static Mat testConvertChar2Mat(byte[] bytes){
            @SuppressWarnings("unchecked")
            List<Byte> bs = CollectionUtils.arrayToList(bytes);
            return Converters.vector_uchar_to_Mat(bs);
    //        return Converters.vector_char_to_Mat(bs);
        }
    
        private static Mat testImdecode(byte[] bytes){
            return Imgcodecs.imdecode(new MatOfByte(bytes), Imgcodecs.IMREAD_COLOR);
        }
    
    
    
    
    
        /**
         * Mat转换成byte数组
         *
         * @param matrix        要转换的Mat
         * @param fileExtension 格式为 ".jpg", ".png", etc
         */
        public static byte[] mat2Byte(Mat matrix, String fileExtension) {
            MatOfByte mob = new MatOfByte();
            Imgcodecs.imencode(fileExtension, matrix, mob);
            return mob.toArray();
        }
    }
```