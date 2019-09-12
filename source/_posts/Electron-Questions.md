---
title: Electron --- 知识点小记
date: 2019-09-11 18:11:32
description: Electron 平时使用过程中遇到的问题小记
categories: [Electron篇]
tags: [Electron]
---

<!-- more -->
### Electron 只启动一个实例
使用 app.requestSingleInstanceLock()

```js
    const gotTheLock = app.requestSingleInstanceLock();

    if (!gotTheLock) {
        app.quit()
    } else {
        app.on('ready', createWindow);
    
        app.on('window-all-closed', () => {
            app.quit();
        });
    
        app.on('activate', () => {
            if (win == null) {
                createWindow();
            }
        });
    }
```

### Electron 不显示菜单栏
经过实测
`Menu.setApplicationMenu(null);`
在 Windows 环境下没有菜单栏, 在 MAC 系统上开发模式下有菜单栏

正确的解决方式是
`Menu.setApplicationMenu(Menu.buildFromTemplate([]));`

### 注册快捷键
electron 自带的注册快捷键的功能函数是 globalShortcut, 这个是全局的快捷键,就是说焦点不在当前程序上也能触发快捷键
我这里使用的是一个第三方的组件 electron-localshortcut

```js
    electronLocalshortcut.register(win, 'F12', function () {
        win.webContents.isDevToolsOpened() ? win.webContents.closeDevTools() : win.webContents.openDevTools();
    });

    electronLocalshortcut.register(win, 'F5', function () {
        win.reload();
    });
```

### 主线程和渲染线程之间的通信
这里使用的是 ipcMain 和 ipcRenderer
渲染进程使用ipcRenderer.send发送异步消息，然后使用on事件监控主进程的返回值。主进程使用on事件监听消息，使用event.sender.send返回数据

App.js:

```js
    const {ipcRenderer} = require('electron')
    ipcRenderer.send('asynchronous-message', 'ping')
    ipcRenderer.on('asynchronous-reply', (event, arg) => {
         console.log(arg) // prints "pong"
    })
```

main.js

```js
    const {ipcMain} = require('electron')
    ipcMain.on('asynchronous-message', (event, arg) => {
      console.log(arg)  // prints "ping"
      event.sender.send('asynchronous-reply', 'pong')
    });
```

渲染进程使用ipcRenderer.sendSync发送同步消息。主进程使用on事件监控消息，使用event.returnValue返回数据给渲染进程。返回值在渲染进程中，就直接体现为ipcRenderer.sendSync的函数返回值

### 主线程如何给渲染线程发送消息
上面的示例没有说主线程如何对小渲染线程发送消息,应该这样做:

```js
    win.webContents.send('ch-1', 'send');
```

### 渲染进程和渲染进程如何互发消息
1. 渲染进程的页面自己处理
2. 通过主线程进行中间转换

### 渲染线程如何使用 electron 的功能
渲染窗口添加配置:

```js
    webPreferences: {
        nodeIntegration: true, // 开启 node 功能
        preload: path.join(__dirname, './public/renderer.js')
    }
```

添加 renderer.js

```js
    global.electron = require('electron')
```

渲染进程的页面使用:

```js
    const electron = window.electron;
    electron.xxxx
```

### 主线程和渲染进程如何共享对象
不需要引入任何包,直接在主线程使用 global

```js
    // 共享对象
    global.shareObject = {
        osInfo: os
    };
```

渲染进程获取信息: let osInfo = electron.remote.getGlobal('shareObject').osInfo;

主线程修改对象: global.shareObject.osInfo = message;

渲染线程修改对象: electron.remote.getGlobal('shareObject').osInfo = null;

### 区分开发模式还是生产模式
建议使用 `app.isPackaged`

### 通过协议打开第二个实例的情况下触发的事件
Windows 环境下:

```js
    app.on('second-instance', (event, commandLine, workingDirectory) => {
        // 当运行第二个实例时,主动对焦
        if (win) {
            if (win.isMinimized()) win.restore();
            win.focus();
            win.show();
        }
    });
```

Mac 环境下:

```js
    // macOS
    app.on('open-url', (event, urlStr) => {
        if (win) {
            win.showInactive();
        }
    });
```

### 开发环境和生成环境加载不同的页面

```js
     if (app.isPackaged) {
        win.loadURL(`file://${__dirname}/build/index.html`);
    } else {
        win.loadURL('http://localhost:3000');
    }
```