---
title: React 项目使用 IDEA 进行调试
date: 2018-06-20 01:02:35
description: "react 项目使用 IDEA 进行调试"
categories: [React篇]
tags: [nodejs,react]
---

<!-- more -->

1. You would need to have WebStorm and JetBrains IDE Support Chrome extension installed.
    需要安装 JetBrains IDE Support 的 chrome 插件

2. In the WebStorm menu Run select Edit Configurations.... Then click + and select JavaScript Debug. Paste http://localhost:3000 into the URL field and save the configuration.
    在 Edit Configurations 选项里添加一个 JavaScript Debug 的项目，并且地址写上 http://localhost:3000
    
    
>> Note: the URL may be different if you've made adjustments via the HOST or PORT environment variables.
    地址根据配置环境而异

3. Start your app by running npm start, then press ^D on macOS or F9 on Windows and Linux or click the green debug icon to start debugging in WebStorm.
    运行项目，点击 debug 按钮调试项目，注意在页面上开启插件的调试功能，此后就能像调式Java 一样调试 js 代码了。
