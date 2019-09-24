---
title: Electron --- Electron-Builder 打包的各种配置
date: 2019-09-14 09:00:12
description: Electron-Builder 打包的各种配置记录
categories: [Electron篇]
tags: [Electron]
---

<!-- more -->
### 打包的资源无法包含 build 目录
 
```json
    "files": [
          "**/*",
          "build/",
          "!build/static/js/*.js.map",
          "!src/"
        ],
```

同时该配置也可防止源码被打包进去,

### 查看打包后的目录结构
`"asar": false,` 


### 引入外部文件

```json
    "extraResources": [
          {
            "from": "./LICENSE",
            "to": "./../LICENSE.txt"
          }
        ],
```

### 定义安装包输出目录

```json
    "directories": {
      "output": "dist"
    },
```

### Windows 环境下打出 32 位和 64 位二合一包

```json
    "win": {
      "target": [
        {
          "target": "nsis",
          "arch": [
            "ia32",
            "x64"
          ]
        }
      ]
    },
```

### 打出的 mac 包写入数据到 Info.plist 文件

```json
   "mac": {
     "extendInfo": {
       "URL types": [
         {
           "URL identifier": "Joy Security",
           "URL Schemes": [
             "joy-security"
           ]
         }
       ]
     }
   },
```

### NSIS 配置

```json
    "nsis": {
      "oneClick": false, // 一键安装
      "perMachine": true, // 为所有用户安装
      "allowElevation": true, // 允许权限提升, 设置 false 的话需要重新允许安装程序
      "allowToChangeInstallationDirectory": true, // 允许更改安装目录
      "installerIcon": "./public/icons/win.ico",
      "uninstallerIcon": "./public/icons/win_uninstall.ico",
      "installerHeaderIcon": "./public/icons/win.ico",
      "createDesktopShortcut": true,
      "createStartMenuShortcut": true,
      "shortcutName": "Joy Security",
      "license": "./LICENSE",
      "include": "./public/nsis/installer.nsh" // 包含的脚本
    }
```

### NSIS 脚本

```nsh
    !macro customHeader
    
    !macroend
    
    !macro preInit
    
    !macroend
    
    !macro customInit
            # guid=7e51495b-3f4d-5235-aadd-5636863064f0
            ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{7e51495b-3f4d-5235-aadd-5636863064f0}" "UninstallString"
            ${If} $0 != ""
                MessageBox MB_ICONINFORMATION|MB_TOPMOST  "检测到系统中已安装本程序，将卸载旧版本" IDOK
                # ExecWait $0 $1
            ${EndIf}
    !macroend
    
    !macro customInstall
    
    !macroend
    
    !macro customInstallMode
      # set $isForceMachineInstall or $isForceCurrentInstall
      # to enforce one or the other modes.
      #set $isForceMachineInstall
    !macroend
```

### NSIS 引入 license 文件包含中文的问题
当引入的 license 文件里有中文时, 在 Windows (中文操作系统) 平台下打包需要 GBK 编码, 在 macOS 下,GBK 编码会直接报错,需要修改为 UTF-8 编码

