---
title: OpenWrt --- 小米路由器 AX3600 不扩容分区刷固件 OpenWrt
date: 2024-09-26 16:57:23
description: 小米路由器 AX3600 不扩容分区刷机 OpenWrt
categories: [ OpenWrt篇 ]
tags: [ OpenWrt ]
---

# 刷机教程
https://openwrt.org/toh/xiaomi/ax3600
## 简单总结下
1. 降级到 miwifi_r3600_firmware_5da25_1.0.17.bin
2. 解锁 SSH

初始化后登录到后台，打开浏览器控制台，执行下面的命令

<!-- more -->

```javascript
function getSTOK() {
    let match = location.href.match(/;stok=(.*?)\//);
    if (!match) {
        return null;
    }
    return match[1];
}

function execute(stok, command) {
    command = encodeURIComponent(command);
    let path = `/cgi-bin/luci/;stok=${stok}/api/misystem/set_config_iotdev?bssid=SteelyWing&user_id=SteelyWing&ssid=-h%0A${command}%0A`;
    console.log(path);
    return fetch(new Request(location.origin + path));
}

function enableSSH() {
    stok = getSTOK();
    if (!stok) {
        console.error('stok not found in URL');
        return;
    }
    console.log(`stok = "${stok}"`);

    password = prompt('Input new SSH password');
    if (!password) {
        console.error('You must input password');
        return;
    }

    execute(stok,
        `
nvram set ssh_en=1
nvram commit
sed -i 's/channel=.*/channel=\\"debug\\"/g' /etc/init.d/dropbear
/etc/init.d/dropbear start
`
    )
        .then((response) => response.text())
        .then((text) => console.log(text));
    console.log('New SSH password: ' + password);
    execute(stok, `echo -e "${password}\\n${password}" | passwd root`)
        .then((response) => response.text())
        .then((text) => console.log(text));
}

enableSSH();

```

3. 登录SSH，使用 scp 将文件 openwrt-23.05.4-ipq807x-generic-xiaomi_ax3600-initramfs-factory.ubi 传到 /tmp 目录下

验证启动分区是哪个

`nvram get flag_boot_rootfs`

如果是 0，则执行

`ubiformat /dev/mtd13 -y -f /tmp/openwrt-23.05.4-ipq807x-generic-xiaomi_ax3600-initramfs-factory.ubi -s 2048 -O 2048 && nvram set flag_boot_rootfs=1 && nvram set flag_last_success=1 && nvram commit`

如果是 1, 则执行

`ubiformat /dev/mtd12 -y -f /tmp/openwrt-23.05.4-ipq807x-generic-xiaomi_ax3600-initramfs-factory.ubi -s 2048 -O 2048 && nvram set flag_boot_rootfs=0 && nvram set flag_last_success=0 && nvram commit`

4. 重启 `reboot`
5. 上传更新包，刷入更新包 `sysupgrade -n /tmp/openwrt-23.05.4-ipq807x-generic-xiaomi_ax3600-squashfs-sysupgrade.bin`


# 更新源
`opkg update`

# 安装中文界面
`opkg install luci-i18n-base-zh-cn`

# 安装 SFTP
``` shell
opkg install vsftpd openssh-sftp-server
/etc/init.d/vsftpd enable
/etc/init.d/vsftpd start
```

# 安装 Argon 主题
https://github.com/jerrykuku/luci-theme-argon/blob/master/README_ZH.md

# 安装 FRPC
`opkg install frpc luci-app-frpc luci-i18n-frpc-zh-cn`

# 安装 KMS 服务
去这里下载文件 https://dl.openwrt.ai/packages-23.05/aarch64_cortex-a53/kiddin9/  
下载 **vlmcsd_svn1113-21_aarch64_cortex-a53.ipk** 和 **luci-app-vlmcsd_git-25.219.56239-ecd1f90_all.ipk**  
传到 /tmp 目录下进行安装  
`opkg install vlmcsd_svn1113-21_aarch64_cortex-a53.ipk `  
`opkg install luci-app-vlmcsd_git-25.219.56239-ecd1f90_all.ipk `  
重新登录后台即可看到管理界面  

# 安装内网测速服务
下载文件 **speedtest-web_1.1.5-6_aarch64_cortex-a53.ipk** 和 **luci-app-speedtest-web_git-25.217.50006-bc84593_all.ipk**  
安装

# 配置无线网络
## radio0
![radio0](https://s3.joylau.cn:9000/blog/openwrt-radio0.png)
## radio1
![radio1](https://s3.joylau.cn:9000/blog/openwrt-radio1.png)
## radio2
![radio2](https://s3.joylau.cn:9000/blog/openwrt-radio2.png)

关于 N AC AX 我这边找到的资料：
> OpenWrt 无线设置中的 legacy、n、ac 和 ax 代表不同的 WiFi 标准:
>
> - legacy: 代表旧的802.11a/b/g标准,最大速率为 54Mbps(802.11g)。
>
> - n:代表 802.11n 标准,最大速率为 600Mbps。
>
> - ac:代表 802.11ac 标准,最大速率为 6.93Gbps。
>
> - ax:代表最新的 802.11ax 标准,最大速率为 10Gbps。
>
> 这些标准的区别和优缺点:
>
> - legacy: 速度较慢,意味旧设备。但兼容性好。
>
> - n:大幅提升速率,向后兼容legacy设备。
>
> - ac:再次大幅提速,不兼容legacy设备。
>
> - ax: 当前最快标准,但设备支持有限。
>
> 所以在兼容性和速率之间进行平衡:
>
> - 如果需要支持旧设备,选择legacy。
>
> - 如果没有老设备,可以选择ac或ax来获得更快速率。
>
> - n协议是在兼容性和速率之间的折衷。
>
> 通过选择合适的协议,可以根据无线环境需求进行性能和兼容性的平衡。÷

使用自己的手机 （15 Pro Max）对各个 WIFI 的测试结果:  

AX 下行 650 Mbps 上行 137 Mbps  
AC 下行 280 Mbps 上行 263 Mbps  
N  下行 25  Mbps   上行 50  Mbps  

# TFTP 救砖
https://www.youtube.com/watch?v=c9HOIYsLjiU&t=8s  
对应地址: https://openwrt.org/toh/xiaomi/ax3600#tftp_recovery

# 安装 OpenVPN 客户端并访问局域网内其他设备
### 安装服务
- openvpn-openssl
- luci-app-openvpn
- luci-i18n-openvpn-zh-cn

### 配置文件修改
由于我的服务端是 iKuai 需要修改2处配置以适配
1. 新增 auth-user-pass /etc/openvpn/homeopenvpn.auth
2. 修改 cipher AES-256-GCM

### 服务端可以访问客户端网段的其他设备
可视化界面: 需要修改防火墙配置下的 LAN 的配置， 启用 masq（MASQUERADE）  
如果是修改配置文件的话修改  
/etc/config/firewall，在 config zone 部分启用 masq

```bash
config zone
    option name 'lan'
    option masq '1'  # 对所有从 LAN 出去的流量启用 MASQUERADE
    option network 'lan'
    option input 'ACCEPT'
    option output 'ACCEPT'
    option forward 'ACCEPT'
```

然后重启

iKuai 服务端配置需要
1. 设置固定IP
2. 配置静态路由

参考 [OpenVPN服务端](https://www.ikuai8.com/index.php?option=com_content&view=article&id=165&Itemid=277)

