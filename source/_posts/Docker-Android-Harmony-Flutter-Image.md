---
title: 安卓和鸿蒙 Flutter 打包基础 Docker 镜像
date: 2025-01-23 10:02:50
description: 记录下构建使用 Flutter 在鸿蒙和安卓环境上用 Docker 打包的基础镜像
categories: [Docker篇]
tags: [Docker]
---

记录下构建使用 Flutter 在鸿蒙和安卓环境上用 Docker 打包的基础镜像
<!-- more -->

## 鸿蒙

```dockerfile
FROM 192.168.1.231:6117/ubuntu:25.04
LABEL desc=鸿蒙flutter打包基础镜像
LABEL author=liufa

WORKDIR /hf
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y vim git curl unzip clang cmake ninja-build pkg-config libgl1 libgtk-3-dev openjdk-21-jdk
ENV PATH="/hf/flutter/bin:/hf/command-line-tools/bin:/hf/command-line-tools/tool/node/bin:/hf/command-line-tools/hvigor/bin:$PATH"
RUN echo '#!/bin/bash\n\
git config --global --add safe.directory /hf/flutter\n\
flutter config --ohos-sdk /hf/command-line-tools/sdk\n\
exec "$@"' > /startup.sh
RUN chmod +x /startup.sh
ENTRYPOINT ["/startup.sh"]
CMD ["/bin/bash"]
```


容器运行时需要将本地 flutter sdk 和 鸿蒙 command-line-tools 分别挂在到 **/hf/flutter** 和 **/hf/command-line-tools** 目录下  
这里的 **commandline-tools-linux** 从鸿蒙官网下载 https://developer.huawei.com/consumer/cn/download/  
flutter SDK 从 Gitee 下载 https://gitee.com/openharmony-sig/flutter_flutter  



## 安卓
```dockerfile
FROM 192.168.1.231:6117/ubuntu:25.04
LABEL desc=安卓flutter打包基础镜像
LABEL author=liufa

WORKDIR /hf
ENV TZ=Asia/Shanghai
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y vim git curl unzip clang cmake ninja-build pkg-config libgl1 libgtk-3-dev openjdk-21-jdk
ENV ANDROID_SDK_ROOT="/hf/android-sdk"
ENV PATH="/hf/flutter/bin::$PATH"

RUN echo '#!/bin/bash\n\
git config --global --add safe.directory /hf/flutter\n\
flutter config --android-sdk /hf/android-sdk\n\
exec "$@"' > /startup.sh
RUN chmod +x /startup.sh
ENTRYPOINT ["/startup.sh"]
CMD ["/bin/bash"]
```

容器运行时需要将本地 flutter sdk 和 android sdk 分别挂在到 **/hf/flutter** 和 **/hf/android-sdk** 目录下