---
title: CentOS 7 磁盘扩展方法
date: 2021-01-27 17:32:36
description: CentOS 7 磁盘扩展方法
categories: [Linux篇]
tags: [Linux,磁盘挂载]
---

<!-- more -->
#### 第一步:	磁盘分区

1. 使用 `fdisk -l` 查看本机磁盘分区情况

```bash
[root@localhost core]# fdisk -l

磁盘 /dev/vda：85.9 GB, 85899345920 字节，167772160 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
磁盘标签类型：dos
磁盘标识符：0x000b2efb

   设备 Boot      Start         End      Blocks   Id  System
/dev/vda1   *        2048     2099199     1048576   83  Linux
/dev/vda2         2099200   167772159    82836480   8e  Linux LVM

磁盘 /dev/vdb：1610.6 GB, 1610612736000 字节，3145728000 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节


磁盘 /dev/mapper/centos-root：51.3 GB, 51308920832 字节，100212736 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节


磁盘 /dev/mapper/centos-swap：8455 MB, 8455716864 字节，16515072 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节


磁盘 /dev/mapper/centos-home：25.1 GB, 25052577792 字节，48930816 个扇区
Units = 扇区 of 1 * 512 = 512 bytes
扇区大小(逻辑/物理)：512 字节 / 512 字节
I/O 大小(最小/最佳)：512 字节 / 512 字节
```


> CentOS 默认挂载盘无法超过 2T， 需要挂载超过 2T 的磁盘，需要先对磁盘的分区方式进行转换成 GPT

转换方式：

```shell
    parted /dev/vdb
    
    mklabel
    gtp
    quit

```


可以看到一个 **/dev/vdb** 的设备没有使用

2. 执行分区:
  - fdisk /dev/vdb
  -  m   显示命令列表
  -   n   新增分区
  -  p 主分区
  -   1
  -   enter
  -   enter
  -  w 写入并退出

```bash
[root@localhost core]# fdisk /dev/vdb
欢迎使用 fdisk (util-linux 2.23.2)。

更改将停留在内存中，直到您决定将更改写入磁盘。
使用写入命令前请三思。

Device does not contain a recognized partition table
使用磁盘标识符 0xc83c3572 创建新的 DOS 磁盘标签。

命令(输入 m 获取帮助)：n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
分区号 (1-4，默认 1)：
起始 扇区 (2048-3145727999，默认为 2048)：
将使用默认值 2048
Last 扇区, +扇区 or +size{K,M,G} (2048-3145727999，默认为 3145727999)：
将使用默认值 3145727999
分区 1 已设置为 Linux 类型，大小设为 1.5 TiB

命令(输入 m 获取帮助)：w
The partition table has been altered!

Calling ioctl() to re-read partition table.
正在同步磁盘。
```



#### 第二步: 格式化磁盘
通知内核重新读取分区信息 `partprobe /dev/vdb`

先执行 blkid 查看磁盘的格式

如果是 xfs 格式，执行下面的命令

`mkfs -t xfs /dev/vdb1`

如果是 ext4 的话

`mkfs -t ext4 /dev/vdb1`

```bash
[root@localhost core]# mkfs -t xfs /dev/vdb1
meta-data=/dev/vdb1              isize=512    agcount=4, agsize=98303936 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=393215744, imaxpct=5
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=191999, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```



#### 第四步: 创建目录并挂载

```bash
[root@localhost core]# mkdir /data
[root@localhost core]# mount /dev/vdb1 /data
```



#### 第五步: 永久挂载

`vim /etc/fstab`

在最后添加如下一行:

```bash
/dev/vdb1               /data                   xfs     defaults        0 0
```

保存生效: mount -a



#### 最后: 查看磁盘挂载情况

`lsblk -f`

```bash
[root@localhost core]# lsblk -f
NAME            FSTYPE      LABEL UUID                                   MOUNTPOINT
sr0                                                                      
vda                                                                      
├─vda1          xfs               cf67c6bc-85c1-4859-a9a2-a3af7641605f   /boot
└─vda2          LVM2_member       b1HmqI-N1Hq-7cyC-kHUK-iz2K-fzCx-f8Rq2T 
  ├─centos-root xfs               cf439706-cf84-4396-a2af-df169a13bdc0   /
  ├─centos-swap swap              700878b0-cf1b-406d-bb8f-db6af815f83a   [SWAP]
  └─centos-home xfs               8c6b2b1b-48c4-4860-bc96-a5a0101b1c91   /home
vdb                                                                      
└─vdb1          xfs               654bab72-7006-4341-a0f6-889130cb15e9   /data
```





### 扩展现有磁盘 （LVM 格式）
比如在虚拟机情况下，原来给虚拟机分配的磁盘大小是 100G，后来发现不够用了，在虚拟机操作界面将 100G 扩容到了 200G，然后多出来的 100G, 扩容到现有系统的 /home 目录下

按以下操作即可实现

#### 扩展分区

```fdisk -l```

```
fdisk /dev/sda
n
p
3
回车
回车
t
L
8e
w
```

#### 加载分区表
`partprobe`

#### 创建物理卷
`pvcreate /dev/sda3`

使用 `pvdisplay` 可查看当前物理卷的相关信息

#### 将物理卷扩容到现有的卷组
`vgextend centos /dev/sda3`

使用 `vgdisplay` 可查看卷组的信息


#### 将卷组中空闲空间扩容到 home 分区
`lvextend /dev/mapper/centos-home /dev/sda3`

使用 `lvdisplay` 可查看逻辑卷的信息

#### 刷新 home 分区，在线扩容
`xfs_growfs /dev/mapper/centos-home`

使用 `df -kh` 和 `lsblk` 查看磁盘挂载情况


### 扩展现有磁盘 （非 LVM 格式）
在现有的环境中 /data 目录下挂载一块 1T 的存储盘， 非 LVM 格式，现在，新加了一块 2T 的硬盘，想要扩展到 /data 目录下，如下：

```bash
[root@server-62 ~]# lsblk
NAME            MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sr0              11:0    1 1024M  0 rom  
vda             252:0    0   50G  0 disk 
├─vda1          252:1    0    1G  0 part /boot
└─vda2          252:2    0   49G  0 part 
  ├─centos-root 253:0    0 45.1G  0 lvm  /
  └─centos-swap 253:1    0  3.9G  0 lvm  [SWAP]
vdb             252:16   0   64M  0 disk 
└─vdb1          252:17   0   63M  0 part 
vdc             252:32   0 1000G  0 disk 
└─vdc1          252:33   0 1000G  0 part /data
vdd             252:48   0    2T  0 disk 
```

简单说下处理方式，还是转为 LVM 格式，将 2 块硬盘都加入逻辑卷，然后将原来数据花园

备份现有 /data 目录的数据，注意原先目录的权限， 比如
```cp -a /data/ /home/backup/```

卸载原先磁盘，并删除分区
```shell
umout /dev/vdc1
fdisk /dev/vdc
d
w
```

编辑 **/etc/fstab** 注释掉目录挂载

创建物理卷

```shell
pvcreate /dev/vdd
pvcreate /dev/vdc
```

创建卷组， 并命名为 vg_data
```shell
vgcreate vg_data /dev/vddd
```

将物理卷 /dev/vdc 加入卷组

```shell
vgextend vg_data /dev/vdc
```

查看信息

```shell
pvdisplay
vgdisplay
vgs
```

创建逻辑卷， 并命名为 lv_data， 100% 使用
```shell
lvcreate -l 100%VG -n lv_data vg_data
```

查看信息
```shell
lvdisplay
```

格式化
```shell
mkfs -t xfs /dev/vg_data/lv_data
```

最后，创建目录挂载
```shell
vim /etc/fstab
/dev/mapper/vg_data-lv_data   /data                   xfs     defaults        0 0

mount -a
lsblk
```

如果 `mount -a` 发现挂载不上， 可执行 `systemctl daemon-reload` 或重启解决

