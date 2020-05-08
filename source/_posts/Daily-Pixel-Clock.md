---
title: 日常折腾 --- 自制像素时钟, 不输 LaMeetric Time
date: 2020-04-23 14:30:43
cover: //image.joylau.cn/blog/awtrix2/awtrix2_24.jpg
description: 自制像素时钟, 不输 LaMeetric Time
categories: [日常折腾篇]
tags: [日常折腾]
---

<!-- more -->
### 背景
之前看到一个像素时钟 LaMeetric Time, 感觉很漂亮, 但是太贵,淘宝上要卖到 2000 块左右
后来又看到一个项目 AWTRIX : https://awtrixdocs.blueforcer.de/#/en-en/
作者在他的网站上介绍了如何制作一个像素时钟
于是,我就跟着他的文档后面做了起来

### 这玩意是什么??
1. 首先它是一个时钟
2. 其次,他能够通过 WIFI 连接到一个服务端, 服务端有 AppStore 能装很多 app 实现很多效果
3. 我想用它来实时显示我博客的访客数, 当然,这需要我后期自己编码
4. 好玩

### 材料
#### 必须材料
1. WS2812B 可编程像素软屏
2. Wemos D1 mini ESP 8266 mini WIFI 开发板
2. 杜邦连接线,公对母


如何你想要制作成我的这种效果, 你还需要

1. 10V 1000uF 电容
2. 电烙铁家用一套
3. 5v 4A 2.5mm 电源
4. 2.5mm 直流电源插头
5. 手动修改官方 3D 打印图纸, 这是我修改好的图纸,其中前面板的高度调高了 3 mm : http://image.joylau.cn//blog/awtrix2/3d打印图纸.zip
6. 手摇自喷漆一罐
7. 定制黑色半透明亚克力板一块,尺寸 335mm * 95mm * 3mm
8. 通用超 520 粘胶一小瓶


### 服务端部署
这里最方便的莫过于 docker 部署

```bash
    docker run -d --name awtrix2 -p 7000:7000 -p 7001:7001 --restart always -e TZ=Asia/Shanghai -v /path:/data whyet/awtrix2:latest
```

注意: 这里需要挂载容器里的目录 data, 否则重启后,安装的软件会丢失不见

### 客户端烧录
最简单的方式是使用 Windows 机器
1. 下载烧录工具: https://blueforcer.de/downloads/ESP8266Flasher.exe
2. 下载最新固件: https://blueforcer.de/awtrix/stable/firmware.bin
3. 启动 ESP8266Flasher.exe 并在 “ Config” 选项卡中打开固件（单击齿轮选择固件）
4. 返回到 “操作” 选项卡，如果未自动检测到正确的串口，则需要手动设置它
5. 单击“ Flash”，然后等待该过程完成，在左下角会显示一个绿色的复选标记。
6. 重新启动控制器

### 连接 WiFi
1. 启动控制器
2. 手机连接 SSID 为 “ AWTRIX Controller ” 的 WiFi, 密码是: **awtrixxx**
3. 如果网页没有自动跳出，则可以使用任何浏览器将设置页面导航到 IP “ 172.217.28.1 ”
4. 点击“配置WiFi”，进入实际设置页面,配置家里的 WLAN 的 SSID 和密码
5. 主机 IP 则设置为之前 docker 部署的服务端的 IP, 注意不需要加端口号
6. 如果你的像素屏不是 32* 8 ,则需要配置 MatrixType2, 这个不需要配置

### 如何重置控制器???
1. 按住控制器的 reset 键 3-4 秒
2. 等待重启
3. 再按住 reset 键 3-4 秒
4. 等待重启
5. 此时如何屏上显示 **RESET** ,则重置成功

### 接线图
![1](//image.joylau.cn/blog/awtrix2/AWTRIX_Core_Steckplatine.jpg)


### 效果图
![2](//image.joylau.cn/blog/awtrix2/awtrix2_1.jpg)  

![3](//image.joylau.cn/blog/awtrix2/awtrix2_2.jpg)  

![4](//image.joylau.cn/blog/awtrix2/awtrix2_3.jpg)  

![5](//image.joylau.cn/blog/awtrix2/awtrix2_4.jpg)  

![6](//image.joylau.cn/blog/awtrix2/awtrix2_5.jpg)  

![7](//image.joylau.cn/blog/awtrix2/awtrix2_6.jpg)  

![8](//image.joylau.cn/blog/awtrix2/awtrix2_7.jpg)  

![9](//image.joylau.cn/blog/awtrix2/awtrix2_8.jpg)
![10](//image.joylau.cn/blog/awtrix2/awtrix2_9.jpg)
![11](//image.joylau.cn/blog/awtrix2/awtrix2_10.jpg)
![12](//image.joylau.cn/blog/awtrix2/awtrix2_11.jpg)
![13](//image.joylau.cn/blog/awtrix2/awtrix2_12.jpg)
![14](//image.joylau.cn/blog/awtrix2/awtrix2_13.jpg)
![15](//image.joylau.cn/blog/awtrix2/awtrix2_14.jpg)
![16](//image.joylau.cn/blog/awtrix2/awtrix2_15.jpg)
![17](//image.joylau.cn/blog/awtrix2/awtrix2_16.jpg)
![18](//image.joylau.cn/blog/awtrix2/awtrix2_17.jpg)
![19](//image.joylau.cn/blog/awtrix2/awtrix2_18.jpg)
![20](//image.joylau.cn/blog/awtrix2/awtrix2_19.jpg)
![21](//image.joylau.cn/blog/awtrix2/awtrix2_20.jpg)
![22](//image.joylau.cn/blog/awtrix2/awtrix2_21.jpg)
![23](//image.joylau.cn/blog/awtrix2/awtrix2_22.jpg)
![24](//image.joylau.cn/blog/awtrix2/awtrix2_23.jpg)
![25](//image.joylau.cn/blog/awtrix2/awtrix2_24.jpg)
![26](//image.joylau.cn/blog/awtrix2/server-page-1.png)
![27](//image.joylau.cn/blog/awtrix2/server-page-2.png)


<center>
<video src="//image.joylau.cn/blog/awtrix2/awtrix2_video1.mp4" muted loop="true" controls="controls">您的浏览器版本太低，无法观看本视频</video>
</center>

<center>
<video src="//image.joylau.cn/blog/awtrix2/awtrix2_video2.mp4" muted loop="true" controls="controls">您的浏览器版本太低，无法观看本视频</video>
</center>

### Siri 语音控制
![28](//image.joylau.cn/blog/awtrix2/awtrix2_siri-1.PNG)
![29](//image.joylau.cn/blog/awtrix2/awtrix2_siri-2.PNG)