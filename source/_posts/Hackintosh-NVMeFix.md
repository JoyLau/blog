---
title: 黑苹果 --- Hackintosh 修复磁盘 NVMe 磁盘的错误问题
date: 2021-08-16 15:58:12
cover: //s3.joylau.cn:9000/blog/macOS%E7%9A%84%E9%97%AE%E9%A2%98%E6%8A%A5%E5%91%8A.png
description: 黑苹果 Hackintosh 修复磁盘 NVMe 磁盘的错误问题
categories: [Hackintosh]
tags: [Hackintosh,黑苹果]
---

<!-- more -->
### 错误信息

![macOS 的问题报告](//s3.joylau.cn:9000/blog/macOS%E7%9A%84%E9%97%AE%E9%A2%98%E6%8A%A5%E5%91%8A.png)

系统登录后报错信息如下：

```text
panic(cpu 0 caller 0xffffff7f83e24231): nvme: "Fatal error occurred. CSTS=0x1 US[1]=0x0 US[0]=0xa6 VID=0x144d DID=0xa808
. FW Revision=EXA7301Q\n"@/AppleInternal/BuildRoot/Library/Caches/com.apple.xbs/Sources/IONVMeFamily/IONVMeFamily-470.100.17/IONVMeController.cpp:5320
Backtrace (CPU 0), Frame : Return Address
0xffffff8e0693b9e0 : 0xffffff800031868d mach_kernel : _handle_debugger_trap + 0x49d
0xffffff8e0693ba30 : 0xffffff8000452ab5 mach_kernel : _kdp_i386_trap + 0x155
0xffffff8e0693ba70 : 0xffffff800044463e mach_kernel : _kernel_trap + 0x4ee
0xffffff8e0693bac0 : 0xffffff80002bea40 mach_kernel : _return_from_trap + 0xe0
0xffffff8e0693bae0 : 0xffffff8000317d57 mach_kernel : _DebuggerTrapWithState + 0x17
0xffffff8e0693bbe0 : 0xffffff8000318147 mach_kernel : _panic_trap_to_debugger + 0x227
0xffffff8e0693bc30 : 0xffffff8000abf2bc mach_kernel : _panic + 0x54
0xffffff8e0693bca0 : 0xffffff7f83e24231 com.apple.iokit.IONVMeFamily : __ZN16IONVMeController8PolledIOEhP18IOMemoryDescriptorjyy18IOPolledCompletionjPKhm.cold.1
0xffffff8e0693bcc0 : 0xffffff7f83e0f362 com.apple.iokit.IONVMeFamily : __ZN16IONVMeController18RequestAsyncEventsEj
0xffffff8e0693be20 : 0xffffff8000a2fb29 mach_kernel : __ZN18IOTimerEventSource15timeoutSignaledEPvS0_ + 0x89
0xffffff8e0693be90 : 0xffffff8000a2fa49 mach_kernel : __ZN18IOTimerEventSource17timeoutAndReleaseEPvS0_ + 0x99
0xffffff8e0693bec0 : 0xffffff800035a645 mach_kernel : _thread_call_delayed_timer + 0xec5
0xffffff8e0693bf40 : 0xffffff800035a171 mach_kernel : _thread_call_delayed_timer + 0x9f1
0xffffff8e0693bfa0 : 0xffffff80002be13e mach_kernel : _call_continuation + 0x2e
      Kernel Extensions in backtrace:
         com.apple.iokit.IONVMeFamily(2.1)[2D554F70-092B-3B6B-B2AD-5C09EDB5B4F8]@0xffffff7f83e01000->0xffffff7f83e43fff
            dependency: com.apple.driver.AppleMobileFileIntegrity(1.0.5)[4159DFFE-7746-3327-9752-C161DC295828]@0xffffff7f813a4000
            dependency: com.apple.iokit.IOPCIFamily(2.9)[2F37AE58-E6B9-3B18-9092-3B80D34C334B]@0xffffff7f80d31000
            dependency: com.apple.driver.AppleEFINVRAM(2.1)[10E46031-889C-3FB7-8B4B-0DECAB5AE325]@0xffffff7f81628000
            dependency: com.apple.iokit.IOStorageFamily(2.1)[CB3CB8CA-881A-37F3-A96B-8063CAF0476D]@0xffffff7f80f17000
            dependency: com.apple.iokit.IOReportFamily(47)[72B53B80-5713-30C1-BAD8-9D55FD718DA2]@0xffffff7f810d3000

BSD process name corresponding to current thread: kernel_task
Boot args: keepsyms=1 agdpmod=pikera shikigva=80

Mac OS version:
19H15

Kernel version:
Darwin Kernel Version 19.6.0: Thu Oct 29 22:56:45 PDT 2020; root:xnu-6153.141.2.2~1/RELEASE_X86_64
Kernel UUID: 9B5A7191-5B84-3990-8710-D9BD9273A8E5
__HIB  text base: 0xffffff8000100000
System model name: iMac19,1 (Mac-AA95B1DDAB278B95)
System shutdown begun: YES
Panic diags file available: YES (0x0)

System uptime in nanoseconds: 81836972997
last loaded kext at 31787099012: >!AHIDKeyboard	209 (addr 0xffffff7f83d6e000, size 45056)
loaded kexts:
com.intel.driver.EnergyDriver	3.7.0
as.acidanthera.mieze.!IMausi	1.0.4
ru.joedm.SMCSuperIO	1.1.8
as.vit9696.SMCProcessor	1.1.8
as.vit9696.VirtualSMC	1.1.8
as.vit9696.WhateverGreen	1.4.4
as.vit9696.!AALC	1.5.4
as.vit9696.Lilu	1.4.9
>AudioAUUC	1.70
>!AUpstreamUserClient	3.6.8
>!AMCCSControl	1.14
@kext.AMDFramebuffer	3.1.0
>!AHDAHardwareConfigDriver	283.15
>!AHDA	283.15
@fileutil	20.036.15
@filesystems.autofs	3.0
>!APlatformEnabler	2.7.0d0
>AGPM	111.4.4
>X86PlatformShim	1.0.0
@kext.AMDRadeonX4000	3.1.0
@kext.AMDRadeonServiceManager	3.1.0
>!AGraphicsDevicePolicy	5.2.6
@AGDCPluginDisplayMetrics	5.2.6
>!A!IKBLGraphics	14.0.7
>!A!ICFLGraphicsFramebuffer	14.0.7
>!AFIVRDriver	4.1.0
@kext.AMD9500!C	3.1.0
>!A!IPCHPMC	2.0.1
>!AGFXHDA	100.1.429
>!AHV	1
|IOUserEthernet	1.0.1
|IO!BSerialManager	7.0.6f7
>pmtelemetry	1
@Dont_Steal_Mac_OS_X	7.0.0
>!A!ISlowAdaptiveClocking	4.0.0
>ACPI_SMC_PlatformPlugin	1.0.0
@private.KextAudit	1.0
|IO!BUSBDFU	7.0.6f7
>!AFileSystemDriver	3.0.1
>!AVirtIO	1.0
@filesystems.hfs.kext	522.100.5
@!AFSCompression.!AFSCompressionTypeDataless	1.0.0d1
@BootCache	40
@!AFSCompression.!AFSCompressionTypeZlib	1.0.0
@filesystems.apfs	1412.141.1
>AirPort.BrcmNIC	1400.1.1
>!AAHCIPort	341.140.1
>!ARTC	2.0
>!AACPIButtons	6.1
>!AHPET	1.8
>!ASMBIOS	2.1
>!AAPIC	1.7
$!AImage4	1
@nke.applicationfirewall	303
$TMSafetyNet	8
@!ASystemPolicy	2.0.0
|EndpointSecurity	1
>!AHIDKeyboard	209
>IO!BHIDDriver	7.0.6f7
>!ASMBus!C	1.0.18d1
|IOSMBus!F	1.1
>DspFuncLib	283.15
@kext.OSvKernDSPLib	529
@kext.triggers	1.0
@kext.AMDRadeonX4000HWLibs	1.0
@kext.AMDRadeonX4000HWServices	3.1.0
>!AGraphicsControl	5.2.6
>!AHDA!C	283.15
|IOHDA!F	283.15
>!ASMBusPCI	1.0.14d1
|IOAccelerator!F2	438.7.3
@kext.AMDSupport	3.1.0
|IONDRVSupport	576.1
|IOAVB!F	850.1
@!AGPUWrangler	5.2.6
@!AGraphicsDeviceControl	5.2.6
|IOGraphics!F	576.1
|IOSlowAdaptiveClocking!F	1.0.0
>IOPlatformPluginLegacy	1.0.0
>X86PlatformPlugin	1.0.0
>IOPlatformPlugin!F	6.0.0d8
@plugin.IOgPTPPlugin	840.3
|IOEthernetAVB!C	1.1.0
|IOAHCIBlock!S	316.100.5
|Broadcom!BHost!CUSBTransport	7.0.6f7
|IO!BHost!CUSBTransport	7.0.6f7
|IO!BHost!CTransport	7.0.6f7
|IO!B!F	7.0.6f7
|IO!BPacketLogger	7.0.6f7
>usb.IOUSBHostHIDDevice	1.2
>usb.cdc	5.0.0
>usb.networking	5.0.0
>usb.!UHostCompositeDevice	1.2
>usb.!UHub	1.2
>!UMergeNub	900.4.2
|IOAudio!F	300.2
@vecLib.kext	1.2.0
|IOSerial!F	11
|IOSurface	269.11
@filesystems.hfs.encodings.kext	1
>usb.!UHostPacketFilter	1.0
|IOUSB!F	900.4.2
>!AXsanScheme	3
|IO80211!F	1200.12.2b1
>mDNSOffloadUserClient	1.0.1b8
>corecapture	1.0.4
|IONVMe!F	2.1.0
>!AEFINVRAM	2.1
|IOSkywalk!F	1
|IOAHCI!F	290.0.1
>usb.!UXHCIPCI	1.2
>usb.!UXHCI	1.2
>!AEFIRuntime	2.1
|IOHID!F	2.0.0
$quarantine	4
$sandbox	300.0
@kext.!AMatch	1.0.0d1
>DiskImages	493.0.0
>!AFDEKeyStore	28.30
>!AEffaceable!S	1.0
>!ASSE	1.0
>!AKeyStore	2
>!UTDM	489.120.1
|IOSCSIBlockCommandsDevice	422.120.3
>!ACredentialManager	1.0
>KernelRelayHost	1
>!ASEPManager	1.0.1
>IOSlaveProcessor	1
|IOUSBMass!SDriver	157.140.1
|IOSCSIArchitectureModel!F	422.120.3
|IO!S!F	2.1
|IOUSBHost!F	1.2
>!UHostMergeProperties	1.2
>usb.!UCommon	1.0
>!ABusPower!C	1.0
|CoreAnalytics!F	1
>!AMobileFileIntegrity	1.0.5
@kext.CoreTrust	1
|IOTimeSync!F	840.3
|IONetworking!F	3.4
|IOReport!F	47
>!AACPIPlatform	6.1
>!ASMC	3.1.9
>watchdog	1
|IOPCI!F	2.9
|IOACPI!F	1.4
@kec.pthread	1
@kec.corecrypto	1.0
@kec.Libm	1



```


### 修复方法
见 GitHub: https://github.com/acidanthera/NVMeFix

macOS 10.15 及之前的版本可以安装在 `/Library/Extensions` 目录下
或者通用的方法是注入到启动器里

具体方法：
1. 下载 NVMeFix.kext
2. 拷贝至 `/Volumes/EFI/EFI-backup/EFI/OC/Kexts` 目录中
3. 更新 `config.plist` 文件, 在 `Kernel` -> `add` 节点下添加如下内容：

```xml
            <dict>
				<key>Arch</key>
				<string>x86_64</string>
				<key>BundlePath</key>
				<string>NVMeFix.kext</string>
				<key>Comment</key>
				<string>NVMeFix</string>
				<key>Enabled</key>
				<true/>
				<key>ExecutablePath</key>
				<string>Contents/MacOS/NVMeFix</string>
				<key>MaxKernel</key>
				<string></string>
				<key>MinKernel</key>
				<string>12.0.0</string>
				<key>PlistPath</key>
				<string>Contents/Info.plist</string>
			</dict>
```