---
title: Docker Stats 的一些统计备忘
date: 2025-04-24 09:03:36
description: 记录一些 docker 信息统计方法的命令
categories: [Docker篇]
tags: [Docker]
---


### 按内存占用统计容器

```shell
docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}" | sort -k2 -h -r

```

### 统计所有容器内存占用总和

```shell
docker stats --no-stream --format "{{.MemUsage}}" | \
awk '{
    split($1, a, "/");  # 分割 "100MiB / 2GiB" 这样的字符串
    mem = a[1];  # 提取第一部分（实际使用量）
    
    if (mem ~ /GiB/) {
        gsub(/GiB/, "", mem);
        sum += mem;
    } else if (mem ~ /MiB/) {
        gsub(/MiB/, "", mem);
        sum += mem / 1024;  # 1 GiB = 1024 MiB
    } else if (mem ~ /KiB/) {
        gsub(/KiB/, "", mem);
        sum += mem / (1024 * 1024);  # 1 GiB = 1024 * 1024 KiB
    } else if (mem ~ /B/) {
        gsub(/B/, "", mem);
        sum += mem / (1024 * 1024 * 1024);  # 1 GiB = 1024^3 B
    }
} 
END {
    printf "Total Memory Usage: %.2f GiB\n", sum
}'

```

<!-- more -->