---
title: Electron --- 关于自动更新的一系列折腾
date: 2019-09-16 09:00:12
description: 关于 Electron 自动更新的一系列折腾
categories: [Electron篇]
tags: [Electron]
---

<!-- more -->
### Electron 自动更新的方法
1. 使用 Electron 自己提供的 autoUpdater 模块
2. 使用更新服务器
3. 自己实现自动更新逻辑

为什么说经过了一系列的折腾呢, 因为前 2 中方式都没有解决我的问题,最后我是自己实现了自动更新的逻辑  
没有解决我的问题是因为我需要兼顾到 mac 平台和 Windows 平台,然而 mac 平台比较麻烦,代码需要签名  
我自己亲测方式一和方式二在 mac 平台上都需要代码签名, 而签名代码需要注册苹果开发者账号,需要付年费  
于是这 2 条路就走不通了  

最后我决定自己实现更新的逻辑

### 更新逻辑分析
1. 自动触发或手动触发软件更新检查
2. 服务器版本号大于本地版本才出现更新提示
3. 对于更新,无非就是卸载之前的版本,安装新下载的安装包
4. 软件的打包我选择的是 Electron Builder, 分别打成 dmg , setup.exe , app.zip
5. 更新的时候先从服务器下载新版本
6. 下载完成后对于安装包的安装分平台来说

### Windows 下的更新
1. Windows 下的安装包是 exe 可执行文件,安装包本身是有处理逻辑在里面的
2. 于是我们只需要将安装包下载到临时目录,然后再软件里打开它,再退出软件,剩下的安装步骤交给用户
3. 有一点需要注意的是,NSIS 的新安装包在安装前会自动卸载掉之前的版本,不过不会提示用户,我们可以在 nsis 脚本里加一个提示

### MacOS 下的更新
1. 相比于 Windows 下的安装包, macOS 下的 dmg 安装包就没有什么逻辑了,直接打开,然后将 app 文件拖到 Applications 目录中即可完成安装
2. 于是有 2 中方法可选
3. 一. 挂载 dmg, 找到挂载目录,在 mac 下是 /Volumes 目录下; 删除 /Applications 下的 app, 将 /Volumes 下的 app 拷贝到 /Applications 目录下; 再卸载 dmg; 重启应用即可,该方法可实现类似无缝更新的效果
4. 二. 和方法一一个道理,只不过不是挂载 dmg 来查找 app, 直接解压 app.zip 压缩文件即可得到 app ,在使用相同的方式覆盖即可.


### 软件的版本控制
可以采取一个 json 文件来记录个版本的更新记录, 这里给个参考:

```json
    [
      {
        "version": "1.1.0",
        "force": false,
        "time": "2019-09-14",
        "download": {
          "winSetup": "",
          "dmg": "",
          "appZip": ""
        },
        "description": [
          "1. 修复若干 BUG,稳定性提升"
        ]
      },
      {
        "version": "1.0.0",
        "force": false,
        "time": "2019-09-01",
        "download": {
          "winSetup": "",
          "dmg": "",
          "appZip": ""
        },
        "description": [
          "1. 全新界面,主体功能完成"
        ]
      }
    ]
```

### 代码参考

```js
    import $ from 'jquery';
    import semver from 'semver';
    import request from 'request';
    import progress from 'request-progress';

    //global.fs = require('fs');
    //global.cp = require('child_process');
    const fs = window.fs;
    const cp = window.cp;
    const electron = window.electron;
    const {app, shell} = electron.remote;

    state = {
        check: true,
        latest: {},
        // wait,download,install,error
        update: 'wait',
        downloadState: {}
    };

    // 检查更新
    $.ajax({
        url: appConfig.updateCheckURL,
        timeout: 10000,
        type: 'GET',
        cache:false,
        success: function (data) {
            let latest = data[0];
            if(semver.satisfies(latest.version, '>' + app.getVersion())){
                if (latest.force) {
                    that.updateVersion();
                }
            }
        },
        complete: function (XMLHttpRequest, status) {
            that.setState({
                check: false
            })
        }
    });


    updateVersion(){
        let that = this;
        const platform = osInfo.platform();
        try {
            const downloadUrl = platform === 'darwin' ? this.state.latest.download.dmg : platform === 'win32' ? this.state.latest.download.winSetup : '';
            if (downloadUrl === '') return;
    
            const downloadUrlArr = downloadUrl.split("/");
    
            const filename = downloadUrlArr[downloadUrlArr.length-1];
    
            const savePath = osInfo.tmpdir() + '/' + filename;
    
            const _request = request(downloadUrl);
            progress(_request, {
                // throttle: 2000,                    // Throttle the progress event to 2000ms, defaults to 1000ms
                // delay: 1000,                       // Only start to emit after 1000ms delay, defaults to 0ms
                // lengthHeader: 'x-transfer-length'  // Length header to use, defaults to content-length
            })
                .on('progress', function (state) {
                    // The state is an object that looks like this:
                    // {
                    //     percent: 0.5,               // Overall percent (between 0 to 1)
                    //     speed: 554732,              // The download speed in bytes/sec
                    //     size: {
                    //         total: 90044871,        // The total payload size in bytes
                    //         transferred: 27610959   // The transferred payload size in bytes
                    //     },
                    //     time: {
                    //         elapsed: 36.235,        // The total elapsed seconds since the start (3 decimals)
                    //         remaining: 81.403       // The remaining seconds to finish (3 decimals)
                    //     }
                    // }
                    that.setState({downloadState: state})
                })
                .on('error', function (err) {
                    that.setState({
                        downloadState:{
                            error: true
                        }
                    })
                })
                .on('end', function () {
                    if (that.state.update === 'error') return;
                    that.setState({
                        update: 'install',
                    });
    
                    setTimeout(function () {
                        if (platform === 'darwin'){
                            const appName = pjson.build.productName;
                            const appVersion = app.getVersion();
                            console.info(appName,appVersion);
                            // 挂载
                            cp.execSync(`hdiutil attach '${savePath}' -nobrowse`, {
                                stdio: ['ignore', 'ignore', 'ignore']
                            });
    
                            // 覆盖原 app
                            cp.execSync(`rm -rf '/Applications/${appName}.app' && cp -R '/Volumes/${appName} ${appVersion}/${appName}.app' '/Applications/${appName}.app'`);
    
                            // 卸载挂载的 dmg
                            cp.execSync(`hdiutil eject '/Volumes/${appName} ${appVersion}'`, {
                                stdio: ['ignore', 'ignore', 'ignore']
                            });
    
                            // 重启
                            app.relaunch();
                            app.quit();
                        }
    
                        if (platform === 'win32') {
                            shell.openItem(savePath);
                            setTimeout(function () {
                                app.quit();
                            },1500)
                        }
                    },2000)
                })
                .pipe(fs.createWriteStream(savePath));
    
            that.setState({update:'download'});
        } catch (e) {
            console.info(e);
            that.setState({
                update: 'error',
            });
        }
    }
```


