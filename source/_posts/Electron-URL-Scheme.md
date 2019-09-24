---
title: Electron --- 在 Windows 下和在 MacOS 下 Scheme 协议的使用
date: 2019-09-12 11:21:12
description: Electron Scheme 协议的使用
categories: [Electron篇]
tags: [Electron]
---

<!-- more -->
### 什么是 URL Scheme 协议
个人理解为注册一种协议来实现应用间的跳转

### Windows 上的实现
Windows 上是通过注册表实现的

通过在 HKCR (HKEY_CALSSES_ROOT) 添加一条注册表记录

![Win Registry](http://image.joylau.cn/blog/Electron-URL-Scheme-win.png)

其中 command 的命令即为要执行的命令,注意后面要加一个参数 `"%1"`

### Mac 上的实现
在应用里显示包内容,使用 xcode 查看 Info.plist 找到 URL types -- URL Schemes 里添加一项

![Mac Info.plist](http://image.joylau.cn/blog/Electron-URL-Scheme-mac.png)

### Electron 的实现

```js
   app.setAsDefaultProtocolClient(PROTOCOL, process.execPath, [`${__dirname}`]);
```

这一句话即可完成 Windows 下和 macOS 下的协议注册,只不过需要应用启动后才可注册成功,就是说如果安装过后不打开的话,无法通过协议来唤醒应用,解决方式我们后面再讲

第一个参数为协议的名称, 第二个参数为执行的命令,第三个参数为所传字符串参数数组

在 Windows 环境下最后一项需要带上当前的项目路径,否则的话在开发模式下会打不开 electron 应用,打包完成后不会存在这个问题, mac 上也不会存在这个问题


### Electron 上协议参数的处理
参数的处理分 2 中情况
1. 新打开的窗口
2. 打开的第二个实例

对于新打开的窗口:
使用 `let argv = process.argv; ` 来获取进程参数,得到的是一个数组,如果做够一项包含我们的协议,则需要根据自己的字符串规则来进行处理

```js
    let argv = process.argv;
    if (argv[argv.length - 1].indexOf(PROTOCOL + "://") > -1) {
        //.....
    }
```

对于打开的第二个实例:
windows 上监听的事件是 `second-instance`, mac 上监听的事件是 `open-url`, 2 个事件传入参数还不一样, Windows 下传入的参数是字符串数组,mac 传入的参数是字符串,都包含了协议名称

```js
    app.on('second-instance', (event, commandLine, workingDirectory) => {
        // 当运行第二个实例时,主动对焦
        if (win) {
            if (win.isMinimized()) win.restore();
            win.focus();
            win.show();

            let message = handleArgv(commandLine);
            processSend(message);
        }
    });

    // macOS
    app.on('open-url', (event, urlStr) => {
        if (win) {
            win.showInactive();
            let message = handleArgv(urlStr);
            processSend(message);
        } else {
            global.shareObject.message = handleArgv(urlStr);
            global.shareObject.isSend = true;
        }

    });
    
    
    function processSend(message) {
        global.shareObject.message = message;
        win.webContents.send('ch-1', 'send');
    }
    
    function handleArgv(argv) {
        let urlObj = [];
        if (Array.isArray(argv)) {
            urlObj = argv[argv.length - 1].replace(PROTOCOL + "://", "").split("_");
        } else {
            urlObj = argv.replace(PROTOCOL + "://", "").split("_");
        }
        return urlObj.length >= 2 ? {sessionId: urlObj[0], url: urlObj[1], macInfo: os.networkInterfaces()} : {};
    }
```

### 浏览器判断 scheme 协议是否存在
使用 setTimeout, 如果超时未打开的话则说明协议不存在 

```js
    let downloadURL = "http://xxxx";
    window.location = "joy-security://xxxxxx_xxxxxxx";
    setTimeout(function() {
      window.location = downloadURL;
    },1000)
```
