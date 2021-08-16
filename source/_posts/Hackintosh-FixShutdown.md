---
title: 黑苹果 --- Hackintosh 解决系统关机变重启的问题
date: 2021-08-10 15:58:12
description: 黑苹果 Hackintosh 解决系统关机变重启的问题
categories: [Hackintosh]
tags: [Hackintosh,黑苹果]
---

<!-- more -->
### 表现
系统关机偶尔会变成重启

### 解决
参考文章： https://dortania.github.io/OpenCore-Post-Install/usb/misc/shutdown.html  
GitHub: https://github.com/dortania/OpenCore-Post-Install/blob/master/extra-files/FixShutdown-USB-SSDT.dsl  
GitHub: https://github.com/dortania/OpenCore-Post-Install/blob/master/extra-files/FixShutdown-Patch.plist  

需要工具：https://github.com/acidanthera/MaciASL/releases

### 解决思路
1. 将 `FixShutdown-USB-SSDT.dsl` 文件使用 `MaciASL` 编译成 `FixShutdown-USB-SSDT.aml` 文件
2. `FixShutdown-USB-SSDT.aml` 文件添加到 `ACPI` 中
3. 打上补丁

FixShutdown-USB-SSDT.dsl：

```text
DefinitionBlock ("", "SSDT", 2, "Slav", "ZPTS", 0x00000000)
{
    External (_SB_.PCI0.XHC_.PMEE, FieldUnitObj)
    External (ZPTS, MethodObj)    // 1 Arguments

    Method (_PTS, 1, NotSerialized)  // _PTS: Prepare To Sleep
    {
        ZPTS (Arg0)
        If ((0x05 == Arg0))
        {
            \_SB.PCI0.XHC.PMEE = Zero
        }
    }
}
```

当 ZPTS 的 Arg0 被赋值为 0x05 时（S5 状态），让 SB.PCI0.XHC 这个设备变成 0

其中 SB.PCI0.XHC 是设备位置

将 `FixShutdown-USB-SSDT.aml` 文件拷贝到 `/Volumes/EFI/EFI-backup/EFI/OC/ACPI`

更新 config.plist 文件：

ACPI -> Add:

```xml
    <dict>
        <key>Comment</key>
        <string>Ensure USB is shutdown correctly</string>
        <key>Enabled</key>
        <true/>
        <key>Path</key>
        <string>FixShutdown-USB-SSDT.aml</string>
    </dict>
```

ACPI -> Patch:

```xml
    <dict>
        <key>Comment</key>
        <string>_PTS to ZPTS</string>
        <key>Count</key>
        <integer>0</integer>
        <key>Enabled</key>
        <true/>
        <key>Find</key>
        <data>X1BUUw==</data>
        <key>Limit</key>
        <integer>0</integer>
        <key>Mask</key>
        <data></data>
        <key>OemTableId</key>
        <data>AAAAAA==</data>
        <key>Replace</key>
        <data>WlBUUw==</data>
        <key>ReplaceMask</key>
        <data></data>
        <key>Skip</key>
        <integer>0</integer>
        <key>TableLength</key>
        <integer>0</integer>
        <key>TableSignature</key>
        <data>AAAAAA==</data>
    </dict>
```