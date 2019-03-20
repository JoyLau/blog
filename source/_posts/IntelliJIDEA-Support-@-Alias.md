---
title: IntelliJ IDEA (WebStorm) 识别 @ 作为别名进行导包 
date: 2019-03-20 10:35:28
description: IntelliJ IDEA 或者 WebStorm 识别 @ 作为别名进行导包
categories: [IntelliJ IDEA篇]
tags: [IntelliJ IDEA]
---

<!-- more -->
### 配置前
![配置前](http://image.joylau.cn/blog/idea-support-alas-1.png)

@ 导包的类无法点击跳转,也不识别

### 配置
在项目根目录添加配置文件 webpack.config.js

```js
    /**
     * 不是真实的 webpack 配置，仅为兼容 webstorm 和 intellij idea 代码跳转
     */
    
    module.exports = {
      resolve: {
        alias: {
          '@': require('path').resolve(__dirname, 'src'), // eslint-disable-line
        },
      },
    };
```

然后,在 idea 的 preference -> language & frameworks -> javascript -> webpack 路径到更目录下的webpack.config.js

完成