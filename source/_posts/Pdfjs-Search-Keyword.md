---
title: PDFjs 魔改支持从地址栏传入关键字高亮显示及双指捏合缩放
date: 2023-12-08 11:27:33
description: 魔改支持从地址栏传入关键字高亮显示及双指捏合缩放
categories: [Tools 篇]
tags: [Tools]
---


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

<!-- more -->

### 使用方法
访问时在地址栏传入 `&keyword=xxx` 关键字

### 双指捏合缩放

在 viewer.html 中的 `<script src="viewer.js"></script>` 下面添加如下代码
```javascript
 <script src="custom-pinch-zoom.js"></script>
```



custom-pinch-zoom.js 代码如下：
```javascript
window.addEventListener("webviewerloaded", () => {
    const container = document.getElementById("viewerContainer");

    let startDistance = 0;
    let startScale = 1;
    let currentScale = 1;
    let isPinching = false;

    const viewer = document.getElementById("viewer");

    function getDistance(touches) {
        const dx = touches[0].clientX - touches[1].clientX;
        const dy = touches[0].clientY - touches[1].clientY;

        return Math.sqrt(dx * dx + dy * dy);
    }

    container.addEventListener(
        "touchstart",
        (e) => {
            if (e.touches.length === 2) {
                isPinching = true;

                startDistance = getDistance(e.touches);

                startScale =
                    PDFViewerApplication.pdfViewer.currentScale;

                currentScale = startScale;
            }
        },
        { passive: true }
    );

    container.addEventListener(
        "touchmove",
        (e) => {
            if (!isPinching || e.touches.length !== 2) {
                return;
            }

            e.preventDefault();

            const currentDistance =
                getDistance(e.touches);

            const scaleFactor =
                currentDistance / startDistance;

            currentScale = startScale * scaleFactor;

            currentScale = Math.max(
                0.5,
                Math.min(currentScale, 5)
            );

            // 关键：
            // pinch 过程中只做 transform
            viewer.style.transform =
                `scale(${currentScale / startScale})`;

            viewer.style.transformOrigin = "center center";
        },
        { passive: false }
    );

    container.addEventListener("touchend", () => {
        if (!isPinching) {
            return;
        }

        isPinching = false;

        // 清除临时 transform
        viewer.style.transform = "";

        // 最终真正 rerender
        PDFViewerApplication.pdfViewer.currentScale =
            currentScale;
    });
});


```

不是很完美，但是能用