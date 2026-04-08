---
title: 日常折腾 --- AX206 屏 + lcd4linux 变身摄像头监控小屏
date: 2026-04-18 18:12:20
description: 使用 ax206 屏配合 lcd4linux 和 ffmpeg，将 RTSP 视频流实时转码为图片，打造一个低成本监控小屏
categories: [日常折腾篇]
tags: [日常折腾, LCD4Linux, OpenWrt]
---

之前写过一篇 [编译 LCD4Linux 增加 Image,VNC,X11 驱动](https://blog.joylau.cn/2024/10/31/Daily-LCD4Linux/) 的文章，这次我把 LCD4Linux 用在了 FriendlyWrt 小主机上，配合 ax206 屏实现了一个实时监控小屏。

<!-- more -->

### 背景

我还有一块 ax206 小屏，480x320 分辨率，之前一直没想好怎么用。想着能不能把监控画面实时显示在小屏上，放在桌面上随时看看门口的情况。

### 思路

整体思路很简单：
1. ffmpeg 从 摄像头 的 RTSP 子码流中每隔 1 秒截取一帧图片
2. lcd4linux 的 Image Widget 加载这张图片并显示到 ax206 屏
3. 通过 procd 服务管理，实现自动启动和异常重启

这里有个关键问题：ffmpeg 写文件和 lcd4linux 读文件如果直接操作同一个文件，会出现读写冲突导致小屏显示闪烁的问题。于是需要一个"中转"机制。

### 解决方案

使用两个服务：
- `cam_ffmpeg`：负责从 RTSP 流截取图片到 `/tmp/cam.png`
- `cam_watch`：监听文件变化，将图片复制到 `/tmp/cam_copy.png`

lcd4linux 只读取 `/tmp/cam_copy.png`，避免了读写冲突。

### 服务脚本

#### cam_ffmpeg 服务

```bash
cat /etc/init.d/cam_ffmpeg
#!/bin/sh /etc/rc.common

START=99
STOP=10

USE_PROCD=1

PROG="/usr/bin/ffmpeg"
OUT="/tmp/cam.png"
URL="rtsp://admin:password@192.168.68.6:554/stream2"

start_service() {
    procd_open_instance
    procd_set_param command $PROG \
        -rtsp_transport tcp \
        -loglevel error \
        -fflags nobuffer \
        -flags low_delay \
        -i "$URL" \
        -vf scale=480:320 \
        -r 1 \
        -update 1 \
        -y "$OUT"

    # 自动重启（非常关键）
    procd_set_param respawn 5 10 0

    # 限制资源（可选）
    procd_set_param limits core="unlimited"

    procd_close_instance
}

stop_service() {
    killall ffmpeg
}
```

这里需要注意的是：
    - `stream2`：使用子码流，降低码率，减少带宽占用，处理更及时，这里需要根据不同厂家的摄像头选择合适的子码流，我这里是 TPLINK 的摄像头
    - `-rtsp_transport tcp`：使用 TCP 传输更稳定
    - `-r 1`：每秒 1 帧，降低刷新频率减少 CPU 占用
    - `-update 1`：持续更新同一个文件而不是生成多个文件
    - `procd_set_param respawn 5 10 0`：进程异常退出后自动重启，RTSP 流经常会断连，这个配置非常重要

#### cam_watch 服务

```bash
cat /etc/init.d/cam_watch
#!/bin/sh /etc/rc.common

START=99
STOP=10

USE_PROCD=1

start_service() {
    procd_open_instance

    procd_set_param command sh -c '
        inotifywait -m -e close_write /tmp/cam.png | while read; do
            sleep 0.05
            cp /tmp/cam.png /tmp/cam_copy.png
        done
    '

    # 挂了自动拉起
    procd_set_param respawn

    procd_close_instance
}

stop_service() {
    # procd 会自动管理，一般不用写
    :
}
```

这里需要注意的是：
    - 需要先安装 `inotifywait` 工具：`opkg install inotifywait`
    - `sleep 0.05`：等待 50ms 确保文件写入完成后再复制
    - 监听 `close_write` 事件，文件写入完成时触发

### lcd4linux 配置

```bash
cat /etc/lcd4linux.conf
Display dpf {
    Driver     'DPF'
    Port       'usb0'
    Font       '12x16'
    Foreground 'ffffff'
    Background 'ffffff00'
    Basecolor  '000000'
    Orientation 0
    Backlight  6
}

Widget IPCam {
    class 'Image'
    file '/tmp/cam_copy.png'
    update 1000
    reload 1
    inverted 0
    visible 1
}

Widget CPU {
    class 'Text'
    expression proc_stat::cpu('busy', 1000)
    prefix ''
    postfix '%'
    width 4
    precision 0
    align 'R'
    update 1000
    Foreground '00CC66'
}

Widget CPUTMP {
    class 'Text'
    expression i2c_sensors('temp1_input')
    postfix 'C'
    precision  0
    width 4
    align 'R'
    update 1000
    Foreground 'FFCC33'
}

Layout layout_480x320 {
    Row1.Col36 'CPU'
    Row3.Col36 'CPUTMP'

    Layer 1 {
        X1.Y1 'IPCam'
    }
}
Display 'dpf'
Layout 'layout_480x320'
```

这里需要注意的是：
    - `reload 1`：每次 update 时重新加载图片文件
    - `update 1000`：每 1000ms（1秒）刷新一次，和 ffmpeg 的 `-r 1` 配合
    - 除了监控画面，还显示 CPU 使用率和温度，放在右上角观察下系统的负载情况


### 效果

最终实现的效果是：小屏每秒刷新一次监控画面，右上角显示 CPU 使用率和温度。虽然只有 1 帧/秒，但对于门口监控来说已经够用了。

这套方案的优势：
- 低成本：利用闲置的小屏和已有的低功耗旁路由
- 稳定：procd 自动重启机制保证服务持续运行

最后这套方案也可以近实时的显示电视直播流，比如每秒看 CCTV13 新闻频道  
参考

```shell
ffmpeg -fflags nobuffer -flags low_delay -i http://10.255.126.3:8006/AHBKLIVE/00000001000000050000000000000151 -vf scale=480:320 -r 1 -update 1 -y /tmp/cam2.png
```

### 注意点
这里的 ffmpeg 的命令我是从这里（https://johnvansickle.com/ffmpeg/ ）下载的静态可执行文件， opkg 源自带的缺少很多编译参数，导致命令无法完整使用  