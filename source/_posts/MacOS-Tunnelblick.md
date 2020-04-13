---
title: Tunnelblick The tmp system folder (/tmp) is not secure. 问题解决记录
date: 2020-04-15 11:15:23
description: Tunnelblick The tmp system folder (/tmp) is not secure. 问题的解决
categories: [MacOS篇]
tags: [Tunnelblick]
---

<!-- more -->
### 记录
MacOS 升级到 10.15 后,每次打开 Tunnelblick 都会提示 The tmp system folder (/tmp) is not secure
虽然点继续可以使用,但是无法打开软件的配置界面, 会直接闪退
于是就想着修复这个问题
可是过程并没有那么顺利

1. 首先查看官方文档

https://tunnelblick.net/cSystemFolderNotSecure.html

根据文档提示执行操作:

```bash
    sudo chown root:admin /tmp; sudo chmod 0755 /tmp
    sudo chown root:wheel /private/tmp; sudo chmod 01777 /private/tmp
```

重启,问题继续.....


2. 升级最新版本
通过查看官方文档, 了解到官方在 Tunnelblick 3.8.0+ 版本后修复这一问题
于是想着升级就可以了
首先升级到最新版本 `Tunnelblick 3.8.2 (build 5480)`  
可是,问题继续.....

3. 完全卸载
于是继续查看官方文档,发现官方有个卸载程序: `Tunnelblick Uninstaller 1.12`
于是下载下来完全卸载程序
之后重装,问题继续......

4. 再读文档

> Disconnect all configurations and quit Tunnelblick*
> Control-click the "Uninstaller" and click "Open"
> Click on "Test" or "Uninstall"
> When the uninstall is complete, restart your computer.

**restart your computer.**

我忽略了这个问题

于是完全卸载完后重启, 重启之后再重装, 问题继续......

但是这次提示不太一样, 错误信息: 

> The installation or repair took too long or failed. Try again?


5. 再次执行第一步的命令
重启软件,解决!!!


备注: 


For OS X 10.11 and higher (including all versions of macOS):

| Folder                       | Owner | Group | Permissions | Octal | Terminal command to repair                                                                           |
|------------------------------|-------|-------|-------------|-------|------------------------------------------------------------------------------------------------------|
| /Applications                | root  | admin | rwxrwxr\-x  | 0775  | sudo chown root:admin /Applications; sudo chmod 0775 /Applications                                   |
| /Library                     | root  | wheel | rwxr\-xr\-x | 0755  | sudo chown root:wheel /Library; sudo chmod 0755 /Library                                             |
| /Library/Application Support | root  | admin | rwxr\-xr\-x | 0755  | sudo chown root:admin /Library/Application\\ Support; sudo chmod 0755 /Library/Application\\ Support |
| /tmp \(10\.11 \- 10\.14\)    | root  | wheel | rwxr\-xr\-x | 0755  | sudo chown root:wheel /tmp; sudo chmod 0755 /tmp                                                     |
| /tmp \(10\.15\+\)            | root  | admin | rwxr\-xr\-x | 0755  | sudo chown root:admin /tmp; sudo chmod 0755 /tmp                                                     |
| /private                     | root  | wheel | rwxr\-xr\-x | 0755  | sudo chown root:wheel /private; sudo chmod 0755 /private                                             |
| /private/tmp                 | root  | wheel | rwxrwxrwt   | 1777  | sudo chown root:wheel /private/tmp; sudo chmod 01777 /private/tmp                                    |
| /Users                       | root  | admin | rwxr\-xr\-x | 0755  | sudo chown root:admin /Users; sudo chmod 0755 /Users                                                 |
| /usr                         | root  | wheel | rwxr\-xr\-x | 0755  | sudo chown root:wheel /usr; sudo chmod 0755 /usr                                                     |
| /usr/bin                     | root  | wheel | rwxr\-xr\-x | 0755  | sudo chown root:wheel /usr; sudo chmod 0755 /usr/bin                                                 |

