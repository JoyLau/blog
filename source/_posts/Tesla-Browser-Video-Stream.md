---
title: 特斯拉如何在行驶过程中通过浏览器观看视频
date: 2026-04-08 10:30:00
description: 记录下如何在特斯拉行驶过程中通过浏览器观看视频的曲线救国方案
categories: [Tesla 篇]
tags: [Tesla, ffmpeg]
---


## 背景

特斯拉为了驾驶安全，一旦挂入 D 档后，车载浏览器中的所有 `<video>` 标签都会被强制终止，WebRTC 方案也不可行。

但是，浏览器渲染图片和播放音频是不受限制的。

于是想到一个曲线救国的方案：**用 ffmpeg 实时转码视频为 JPEG 图片流，浏览器不断渲染图片，同时单独转码音频流供浏览器播放**。

## 实现思路

```
特斯拉浏览器
    │  GET /watch?url=https://youtube.com/watch?v=xxx
    ▼
[服务端]
  yt-dlp 获取视频源
    │ pipe
  ffmpeg stdin
    ├──► JPEG frames → multipart/x-mixed-replace → 浏览器 <img> 标签渲染
    │
    └──► MP3 audio stream → 浏览器 <audio> 标签播放
```
## 实现效果
<video src="https://s3.joylau.cn:9000/mdpic/picgo/2026/04/08/Tesla-Browser-Video-Stream.mp4" muted controls="controls"> </video>

<!-- more -->

核心是 ffmpeg 两路流：
1. **视频流**：实时转码为 JPEG 帧，浏览器通过 `<img>` 标签不断刷新显示
2. **音频流**：实时转码为 MP3 格式，浏览器直接播放

## 项目地址

https://github.com/JoyLau/opencarstream

这个项目 fork 自开源项目 [santibacat/opencarstream](https://github.com/santibacat/opencarstream)，我这边做了一些 BUG 修复和对国内 Bilibili 视频站的支持。


## 核心实现

### MJPEG 帧解析

JPEG 图片以 `0xFFD8` 开头（SOI），以 `0xFFD9` 结尾（EOI），通过这两个标记从字节流中切分出每一帧：

```python
SOI = b"\xff\xd8"
EOI = b"\xff\xd9"

buf = b""
while True:
    chunk = ff_proc.stdout.read(65536)
    if not chunk:
        break
    buf += chunk
    while True:
        start = buf.find(SOI)
        if start == -1:
            buf = b""
            break
        end = buf.find(EOI, start + 2)
        if end == -1:
            buf = buf[start:]
            break
        frame = buf[start:end + 2]  # 提取一帧完整的 JPEG
        buf = buf[end + 2:]
        with stream.lock:
            stream.frame = frame
```

### 音频缓冲

音频数据通过单独的线程持续读取并存入缓冲区，浏览器请求时从缓冲区获取：

```python
def _drain():
    try:
        with os.fdopen(audio_r, "rb", buffering=0) as audio_pipe:
            while True:
                chunk = audio_pipe.read(8192)
                if not chunk:
                    break
                with stream._audio_lock:
                    stream._audio_chunks.append(chunk)
                stream._audio_ready.set()
    finally:
        with stream._audio_lock:
            stream._audio_done = True
        stream._audio_ready.set()

threading.Thread(target=_drain, daemon=True).start()
```

## 支持的视频源

| 来源 | 示例 URL |
|------|----------|
| YouTube | `https://www.youtube.com/watch?v=VIDEO_ID` |
| Bilibili | `https://www.bilibili.com/video/BVxxx` |
| Twitch | `https://www.twitch.tv/channelname` |
| Twitter/X | `https://x.com/user/status/TWEET_ID` |
| Pluto TV | 内置频道列表 |
| IPTV | `.m3u` / `.m3u8` 播放列表 |
| 本地文件 | 通过 Local Media 标签页 |

## 我做的改进

相比原项目，主要做了以下改进：

### 1. Bilibili 视频站支持

- **新增 Bilibili 标签页**：在 Web 界面添加独立的 Bilibili 标签页
- **视频搜索功能**：支持在界面内直接搜索 Bilibili 视频
- **搜索历史**：自动保存搜索历史，最多保留 100 条记录，方便快速访问常看的内容
- **缩略图支持**：播放页面显示视频缩略图预览

### 2. 音视频播放优化

- **防止重复启动 pipeline**：添加 `_pipeline_started` 标志，避免同一个流被重复启动
- **进程管理优化**：改进 ffmpeg 和 yt-dlp 进程的终止逻辑，确保资源正确释放
- **流停止处理**：优化返回按钮和流停止的处理逻辑，避免残留进程

### 3. UI 改进

- **视频卡片样式**：优化视频卡片的样式和结构
- **防盗链处理**：添加 `<meta name="referrer" content="no-referrer">` 解决B站图片无法加载的问题
