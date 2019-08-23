---
title: Ubuntu 强制设置分辨率
date: 2019-07-15 09:10:44
description: 一次系统重启后,Ubuntu 系统无法正确识别连接的显示器分辨率了...
categories: [Ubuntu篇]
tags: [Ubuntu]
---
<!-- more -->

## 背景
一次系统重启后,Ubuntu 系统无法正确识别连接的显示器分辨率了,我连接的 2 个显示器,其中一个分辨率正确识别,另一个却无法识别,默认成 1024 的分辨率了

## 注意
强制设置的分辨率起码显示器得支持

## 步骤
1. `xrandr` 查看当前显示器的设置信息, 记住当前显示接口的名称,我这里是 `VGA-1`, 而且支持的分辨率列表应该是没有你想要的分辨率,不然的话在设置里就能看到了
2. 添加一个分辨率,我这里是 1920 * 1080 : `cvt 1920 1080`; 得到输出: `Modeline "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync`
3. 将 cvt 得到的显示模式使用 xrandr 命令添加:
    `sudo xrandr --newmode "1920x1080_60.00" 173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync`
    `sudo xrandr --addmode VGA-1 "1920x1080_60.00"`
4. 这样设置重启会失效, 将第三步的操作写到 `/etc/profile` 即可