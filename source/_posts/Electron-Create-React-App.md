---
title: Electron --- Create-React-App + Antd + Electron 的搭建
date: 2019-09-10 16:41:30
description: Create-React-App + Antd + Electron 项目的搭建
categories: [Electron篇]
tags: [Electron,React]
---

<!-- more -->
## 步骤
### 创建 create-react-app-antd 项目
1. git clone https://github.com/ant-design/create-react-app-antd
2. npm install
3. 将 webpack 所有内建的配置暴露出来, `npm run eject`, 如果发现错误,看下 package.json 里 eject 的脚本是不是为 `react-scripts eject `
4. 修改 config-overrides.js

```js
    module.exports = function override(config, env) {
        return config;
    };
```

5. 修改 webpack.config.js 里的 `module.rules.oneOf` 支持 css 和 less, 添加
```js
    {
      test: /\.(css|less)$/,
      use: [
        require.resolve('style-loader'),
        {
          loader: require.resolve('css-loader'),
          options: {
            importLoaders: 1,
          },
        },
        {
          loader: require.resolve('postcss-loader'),
          options: {
            // Necessary for external CSS imports to work
            // https://github.com/facebookincubator/create-react-app/issues/2677
            ident: 'postcss',
            plugins: () => [
              require('postcss-flexbugs-fixes'),
              autoprefixer({
                browsers: [
                  '>1%',
                  'last 4 versions',
                  'Firefox ESR',
                  'not ie < 9', // React doesn't support IE8 anyway
                ],
                flexbox: 'no-2009',
              }),
            ],
          },
        },
        {
          loader: require.resolve('less-loader'),
          options: { javascriptEnabled: true }
        },
      ],
    }
```

6. 修改 start.js 注释掉下面代码关闭项目启动自动打开浏览器

```js
    // openBrowser(urls.localUrlForBrowser);
```

7. package.json 添加 `"homepage": "."` ,防止打包后的静态文件 index.html 引入 css 和 js 的路径错误

8. App.less 修改为 `@import '~antd/dist/antd.less';`


### 添加 electron 
1. package.json 添加 `"main": "main.js",` 和 electron 依赖

```json
    {
        "main": "main.js",
        "devDependencies": {
            "electron": "^6.0.7"
         }
     }
```
2. 创建 main.js,添加以下代码

```js
    const {app, BrowserWindow, Menu} = require('electron');
    
    let win;
    
    let windowConfig = {
        width: 800,
        height: 600,
        title: "Joy Security",
    };
    
    let menuTemplate = [{
        label: 'Joy Security',
        submenu: [{
            label: '退出',
            role: 'quit'
        }, {
            label: `关于 ${windowConfig.title}`,
            role: 'about'
        }]
    }];
    
    
    app.on('ready', createWindow);

    app.on('window-all-closed', () => {
        app.quit();
    });

    app.on('activate', () => {
        if (win == null) {
            createWindow();
        }
    });
    
    
    function createWindow() {
        // 隐藏菜单栏,兼容 MAC
        Menu.setApplicationMenu(Menu.buildFromTemplate([]));
    
        win = new BrowserWindow(windowConfig);
    
        win.loadURL('http://localhost:3000');
    
        win.on('close', () => {
            //回收BrowserWindow对象
            win = null;
        });
    
        win.on('resize', () => {
            // win.reload();
        });
    
    }
    
```

3. package.json 更改脚本

```json
    {
    "scripts": {
        "react-start": "node scripts/start.js",
        "eletron-start": "electron .",
        "react-build": "node scripts/build.js",
      }
    }
```

4. 启动时先 react-start 再 eletron-start 即可看到效果