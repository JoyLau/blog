---
title: PDFjs 魔改支持从地址栏传入关键字高亮显示
date: 2023-12-08 11:27:33
description: 魔改支持从地址栏传入关键字高亮显示
categories: [Tools 篇]
tags: [Tools]
---

<!-- more -->

### 修改代码

修改 `view.js` 的初始化 `setInitialView` 方法 在该方法最下面加入下面代码

```javascript
    var urlPath=decodeURIComponent(window.parent.document.location);
    var index=urlPath.indexOf("keyword");
    if (index === -1) {
        return;
    }
    var keyword=urlPath.substr(index+8);
    console.log(urlPath, index, keyword);
    document.getElementById("findInput").value=keyword;
    document.getElementById("findHighlightAll").click();
```

### 使用方法
访问时在地址栏传入 `&keyword=xxx` 关键字


