---
title: Docker 鸿蒙 Flutter 打包基础 Docker 镜像
date: 2025-01-21 17:33:45
description: 这里记录下构建使用 Flutter 在鸿蒙环境上用 Docker 打包的基础镜像
categories: [Docker篇]
tags: [Docker]
---

这里记录下构建使用 Flutter 在鸿蒙环境上用 Docker 打包的基础镜像
<!-- more -->

## Dockerfile

```dockerfile
FROM 192.168.1.231:6117/ubuntu:25.04
LABEL desc=鸿蒙flutter打包基础镜像
LABEL author=liufa

WORKDIR /hf
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y vim git curl unzip clang cmake ninja-build pkg-config libgl1 libgtk-3-dev openjdk-21-jdk
RUN curl -o commandline-tools.zip http://192.168.1.231:6119/repository/raw-public/harmonyos/command-line-tools/commandline-tools-linux-x64-5.0.5.310.zip
RUN unzip commandline-tools.zip
RUN git clone -b 3.7.12-ohos-1.0.3 https://gitee.com/openharmony-sig/flutter_flutter.git flutter
ENV PATH="/hf/flutter/bin:/hf/command-line-tools/bin:/hf/command-line-tools/tool/node/bin:/hf/command-line-tools/hvigor/bin:$PATH"
RUN flutter config --ohos-sdk /hf/command-line-tools/sdk
RUN flutter doctor
RUN cd /opt && curl -o test.zip http://192.168.1.231:6119/repository/raw-public/harmonyos-flutter/test-demo/test-demo-2025-01-21.zip && unzip test.zip
RUN cd /opt/test && flutter build hap --release
```


这里的 **commandline-tools-linux-x64-5.0.5.310.zip** 从鸿蒙官网下载 https://developer.huawei.com/consumer/cn/download/
flutter SDK 从 Gitee 下载 https://gitee.com/openharmony-sig/flutter_flutter
最后是构建了一个 test-demo 测试能否在镜像容器中打出 hap 包

构建完成后包大小有点离谱 18GB, 最后是推到私服中，无所谓了