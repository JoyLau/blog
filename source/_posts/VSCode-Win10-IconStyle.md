---
title: VSCode 图标在 Windows 10 系统开始菜单里的背景色为黑色问题的解决
date: 2020-05-03 01:00:31
description: 安装好 CODE 后， 将快捷方式固定到开始菜单， 发现图标的背景色为黑色，和其他图标一比较，显得格格不入
categories: [VSCode]
tags: [VSCode]
---

<!-- more -->
### 背景
安装好 CODE 后， 将快捷方式固定到开始菜单， 发现图标的背景色为黑色，和其他图标一比较，显得格格不入

### 解决
由于 VSCODE 是 electron 开发的， 通过GitHub 查看源码，发现配置文件位于： `https://github.com/Microsoft/vscode/blob/master/resources/win32/VisualElementsManifest.xml`

那么安装好之后的该配置文件位于安装路径的根目录下：`Code.VisualElementsManifest.xml`

修改 BackgroundColor 为透明色 rgba(0, 0, 0, 0) 即可：

```xml
    <Application xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    		<VisualElements
    				BackgroundColor="rgba(0, 0, 0, 0)"
    				ShowNameOnSquare150x150Logo="on"
    				Square150x150Logo="resources\app\resources\win32\code_150x150.png"
    				Square70x70Logo="resources\app\resources\win32\code_70x70.png"
    				ForegroundText="light" />
    </Application>
```

重新创建快捷方式， 再固定到开始菜单上即可看到效果。