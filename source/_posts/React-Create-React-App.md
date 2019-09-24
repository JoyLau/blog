---
title: Create-React-App 的一些配置
date: 2019-09-10 16:52:54
description: Create-React-App 创建的项目的一些配置记录
categories: [React篇]
tags: [react,webpack]
---

<!-- more -->

### 添加多页面配置
1. `npm run eject`
2. 修改 webpack.config.js

entry 修改: 
这里我加了一个 update.html 页面

```js
    entry: {
      index: [
        // Include an alternative client for WebpackDevServer. A client's job is to
        // connect to WebpackDevServer by a socket and get notified about changes.
        // When you save a file, the client will either apply hot updates (in case
        // of CSS changes), or refresh the page (in case of JS changes). When you
        // make a syntax error, this client will display a syntax error overlay.
        // Note: instead of the default WebpackDevServer client, we use a custom one
        // to bring better experience for Create React App users. You can replace
        // the line below with these two lines if you prefer the stock client:
        // require.resolve('webpack-dev-server/client') + '?/',
        // require.resolve('webpack/hot/dev-server'),
        isEnvDevelopment &&
        require.resolve('react-dev-utils/webpackHotDevClient'),
        // Finally, this is your app's code:
        paths.appIndexJs,
        // We include the app code last so that if there is a runtime error during
        // initialization, it doesn't blow up the WebpackDevServer client, and
        // changing JS code would still trigger a refresh.
      ].filter(Boolean),
      update: [
        isEnvDevelopment &&
        require.resolve('react-dev-utils/webpackHotDevClient'),
        paths.appSrc + '/update.js',
      ].filter(Boolean),
    },
```


output 修改

```js
    output: {
          // The build folder.
          path: isEnvProduction ? paths.appBuild : undefined,
          // Add /* filename */ comments to generated require()s in the output.
          pathinfo: isEnvDevelopment,
          // There will be one main bundle, and one file per asynchronous chunk.
          // In development, it does not produce real files.
          filename: isEnvProduction
            ? 'static/js/[name].[contenthash:8].js'
            : isEnvDevelopment && 'static/js/[name]bundle.js',
          // There are also additional JS chunk files if you use code splitting.
          chunkFilename: isEnvProduction
            ? 'static/js/[name].[contenthash:8].chunk.js'
            : isEnvDevelopment && 'static/js/[name].chunk.js',
          // We inferred the "public path" (such as / or /my-project) from homepage.
          // We use "/" in development.
          publicPath: publicPath,
          // Point sourcemap entries to original disk location (format as URL on Windows)
          devtoolModuleFilenameTemplate: isEnvProduction
            ? info =>
                path
                  .relative(paths.appSrc, info.absoluteResourcePath)
                  .replace(/\\/g, '/')
            : isEnvDevelopment &&
              (info => path.resolve(info.absoluteResourcePath).replace(/\\/g, '/')),
        },
```

注意修改其中的 filename



HtmlWebpackPlugin 修改:
新增一个 HtmlWebpackPlugin 



```js
    new HtmlWebpackPlugin(
            Object.assign(
              {},
              {
                inject: true,
                template: paths.appHtml,
                chunks: ["index"]
              },
              isEnvProduction
                ? {
                    minify: {
                      removeComments: true,
                      collapseWhitespace: true,
                      removeRedundantAttributes: true,
                      useShortDoctype: true,
                      removeEmptyAttributes: true,
                      removeStyleLinkTypeAttributes: true,
                      keepClosingSlash: true,
                      minifyJS: true,
                      minifyCSS: true,
                      minifyURLs: true,
                    },
                  }
                : undefined
            )
          ),
          new HtmlWebpackPlugin(
              Object.assign(
                  {},
                  {
                    inject: true,
                    template: paths.appHtml,
                    chunks: ["update"],
                    filename: "update.html"
                  },
                  isEnvProduction
                      ? {
                        minify: {
                          removeComments: true,
                          collapseWhitespace: true,
                          removeRedundantAttributes: true,
                          useShortDoctype: true,
                          removeEmptyAttributes: true,
                          removeStyleLinkTypeAttributes: true,
                          keepClosingSlash: true,
                          minifyJS: true,
                          minifyCSS: true,
                          minifyURLs: true,
                        },
                      }
                      : undefined
              )
          ),
```

在 public 目录里添加 update.html, 内容照抄 index.html 文件即可;
在 src 目录下添加 update.js 文件:

```js
    import React from 'react';
    import ReactDOM from 'react-dom';
    import './index.css';
    import Update from './page/Update';
    import * as serviceWorker from './serviceWorker';
    
    ReactDOM.render(<Update />, document.getElementById('root'));
    serviceWorker.register();
```


之后, http://localhost:3000/update.html 即可访问; 如果想加个路径,直接修改 HtmlWebpackPlugin 里的 filename, 例如 `filename: "index/update.html"`  
就可以 使用 http://localhost:3000/index/update.html 来访问


### 引入 src 目录以外的文件报错
例如需要引入 public 目录下的图片,就会报错,此时,注释掉

```js
    // new ModuleScopePlugin(paths.appSrc, [paths.appPackageJson]),
```

这一行,重启即可.