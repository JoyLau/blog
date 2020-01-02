---
title: React-App-Rewired 的一些配置
date: 2019-12-26 16:32:18
description: React-App-Rewired 创建的项目的一些配置记录
categories: [React篇]
tags: [react]
---

<!-- more -->
### 添加多页面配置
之前写过一篇 npm eject 之后的多页面配置,可以往前翻阅 , 现在不想 eject, 该怎么配置多页面?

1.  npm install react-app-rewire-multiple-entry --save-dev

2. 在 config-overrides.js 中添加配置
现在 public 里复制一个 html 页面, 在 src 目录下再新增一个目录,里面的文件拷贝 index 的稍微改动下,
大致目录如下:

-serviceWorker.js
-metadata.js
-metadata.css
-logo.svg
-App.test.js
-App.js
-App.css

基本使用:

```js
    const multipleEntry = require('react-app-rewire-multiple-entry')([{
        entry: 'src/metadata/metadata.js',
        template: 'public/metadata.html',
        outPath: '/metadata',
    }]);

    module.exports = {
      webpack: function(config, env) {
        multipleEntry.addMultiEntry(config);
        return config;
      }
    };
```

在 customize-cra 使用

```js
    const multipleEntry = require('react-app-rewire-multiple-entry')([
      {
        entry: 'src/entry/landing.js',
        template: 'public/landing.html',
        outPath: '/landing.html'
      }
    ]);
    
    const {
      override,
      overrideDevServer
    } = require('customize-cra');
    
    module.exports = {
      webpack: override(
        multipleEntry.addMultiEntry
      )
    };
```

结合 ant-design 使用

```js
    const {override, fixBabelImports, addLessLoader} = require('customize-cra');
    
    const multipleEntry = require('react-app-rewire-multiple-entry')([{
        entry: 'src/metadata/metadata.js',
        template: 'public/metadata.html',
        outPath: '/metadata',
    }]);
    
    
    module.exports = override(
        multipleEntry.addMultiEntry,
        fixBabelImports('import', {
            libraryName: 'antd',
            libraryDirectory: 'es',
            style: true,
        }),
        addLessLoader({
            javascriptEnabled: true,
            modifyVars: { '@primary-color': '#1890ff' },
        }),
    );
```

> 注意,这样配置的话, 请求的 uri 是 /metadata, 在 build 后会生成 metadata 文件, 将打包后的文件拷贝到服务器上运行效果不好
> 一般我都注释掉 template, 再将 outPath 写成 /metadata.html


### 打包不生成 source-map 文件
在项目更目录下创建文件 .env, 写入: GENERATE_SOURCEMAP=false 即可.