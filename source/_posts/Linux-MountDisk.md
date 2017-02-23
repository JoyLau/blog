---
title: Linux菜鸟到熟悉---数据盘的格式化和挂载
date: 2017-2-23 12:01:25
description: "我们通常在阿里云上购买实例时通常都会选择再购买一块或多块数据盘。</br>
在登录实例后，这些数据盘并不能直接使用，系统需要先格式化数据盘，然后挂载数据盘。"
categories: [Linux篇]
tags: [linux,磁盘挂载]
---

<!-- more -->
![Thymeleaf](http://image.lfdevelopment.cn/blog/Thymeleaf.png)


## 注意事项

- 云服务器 **ECS** 仅支持对**数据盘**进行二次分区，而不支持对 **系统盘** 进行二次分区（不管是 **Windows** 还是 **Linux** 系统）
- 强行使用第三方工具对系统盘进行二次分区操作，可能引发未知风险，如系统崩溃、数据丢失等。
- 对新购的数据盘可以选择分区或者不分区，这个根据自身的情况而定
- 下面内容的`xvdb`和 `vdb`分别对应非 I/O优化I/O 优化；非 I/O 优化和 I/O 优化的区别在于，前者比后者多一个字母 x
- 新数据盘的挂载可以自定义文件夹，本示例中用的是/mnt


## 开始

- 运行 `fdisk -l` 命令查看数据盘。注意：在没有分区和格式化数据盘之前，使用 `df -h` 命令是无法看到数据盘的。在下面的示例中，有一个 5 GB 的数据盘需要挂载。
- 如果执行了 `fdisk -l` 命令后，没有发现 /dev/xvdb，则表示您的实例没有数据盘，因此无需挂载

![Image1](http://image.lfdevelopment.cn/blog/linux1.jpg)

### 需要进行分区的情况
- 运行 `fdisk /dev/xvdb`，对数据盘进行分区。根据提示，依次输入 n，p，1，两次回车，wq，分区就开始了。

![Image2](http://image.lfdevelopment.cn/blog/linux2.png)

- 运行 `fdisk -l` 命令，查看新的分区。新分区 xvdb1 已经创建好。如下面示例中的/dev/xvdb1。

![Image3](http://image.lfdevelopment.cn/blog/linux3.png)


### 不需要进行分区的情况

> 一般情况下我都是直接格式化一整块数据盘，然后挂载的。

- 运行 `mkfs.ext3 /dev/xvdb1`，对新分区进行格式化。格式化所需时间取决于数据盘大小。您也可自主决定选用其他文件格式，如 `ext4` 等。

![Image4](http://image.lfdevelopment.cn/blog/linux4.png)

- 运行 `echo /dev/xvdb1 /mnt ext3 defaults 0 0 >> /etc/fstab` 写入新分区信息。完成后，可以使用 `cat /etc/fstab` 命令查看。

![Image5](http://image.lfdevelopment.cn/blog/linux5.png)

> Ubuntu 12.04 不支持 barrier，所以对该系统正确的命令是：`echo /dev/xvdb1 /mnt ext3 defaults 0 0 >> /etc/fstab` 
  如果需要把数据盘单独挂载到某个文件夹，比如单独用来存放网页，可以修改以上命令中的 /mnt 部分。
  
  
## 最后
- 运行   `mount /dev/xvdb1 /mnt` 挂载新分区，然后执行 `df -h` 查看分区。如果出现数据盘信息，说明挂载成功，可以使用新分区了。

    ``` bash
         mount /dev/xvdb1 /mnt
         df -h
         Filesystem      Size  Used Avail Use% Mounted on
         /dev/xvda1       40G  1.5G   36G   4% /
         tmpfs           498M     0  498M   0% /dev/shm
         /dev/xvdb1      5.0G  139M  4.6G   3% /mnt
    ```

