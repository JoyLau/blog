---
title: Docker ENTRYPOINT 和 CMD 组合使用
date: 2020-04-22 13:55:53
description: Docker ENTRYPOINT 和 CMD 组合使用
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->

### 前提
1. 清楚 ENTRYPOINT 和 CMD 的 shell 和 exec 的 2 种写法
2. 定义多个 CMD, 只有最后一个 CMD 生效
3. 同时定义 ENTRYPOINT 和 CMD, 那么 ENTRYPOINT 会覆盖 CMD

### 总结的结论
1. ENTRYPOINT 使用了 shell 模式，CMD 指令会被忽略
2. ENTRYPOINT 使用了 exec 模式，CMD 指定的内容被追加为 ENTRYPOINT 指定命令的参数
3. ENTRYPOINT 使用了 exec 模式，CMD 也应该使用 exec 模式
4. Dockerfile 里至少定义一个 ENTRYPOINT 或者 CMD

下面是官方文档里 2 种组合情况

|                                | No ENTRYPOINT                 | ENTRYPOINT exec\_entry p1\_entry  | ENTRYPOINT \[“exec\_entry”, “p1\_entry”\]           |
|--------------------------------|-------------------------------|-----------------------------------|-----------------------------------------------------|
| No CMD                         | error, not allowed            | /bin/sh \-c exec\_entry p1\_entry | exec\_entry p1\_entry                               |
| CMD \[“exec\_cmd”, “p1\_cmd”\] | exec\_cmd p1\_cmd             | /bin/sh \-c exec\_entry p1\_entry | exec\_entry p1\_entry exec\_cmd p1\_cmd             |
| CMD \[“p1\_cmd”, “p2\_cmd”\]   | p1\_cmd p2\_cmd               | /bin/sh \-c exec\_entry p1\_entry | exec\_entry p1\_entry p1\_cmd p2\_cmd               |
| CMD exec\_cmd p1\_cmd          | /bin/sh \-c exec\_cmd p1\_cmd | /bin/sh \-c exec\_entry p1\_entry | exec\_entry p1\_entry /bin/sh \-c exec\_cmd p1\_cmd |


### docker-entrypoint.sh 的使用
参照我 blog 的 Dockerfile 的 docker-entrypoint.sh

#### set -e
文件开头加上set -e, 这句语句告诉bash如果任何语句的执行结果不是true则应该退出

#### exec gosu www-data "$0" "$@"
使用 gosu 来切换身份,而不是 su
$0 代表当前的 shell 脚本名, $@ 代表 CMD 的第一个参数


#### exec "$@"
当在 docker-entrypoint.sh 执行了一些需要初始化的事情后,边去执行 CMD 定义的脚本


#### 综合

```bash
    #!/bin/bash
    set -e
    if [ "$1" = '/my-blog/bash/init.sh' -a "$(id -u)" = '0' ]; then
        service nginx start
        service fcgiwrap start
        echo "☆☆☆☆☆ base service has started. ☆☆☆☆☆"
        exec gosu www-data "$0" "$@"
    fi
    exec "$@"
```

解释: 如果 CMD 的第一个参数是 `/my-blog/bash/init.sh`,并且 当前用户是 root 的话, 那么启动 `nginx` 和 `fcgiwrap` 服务,并切换到 `www-data` 的身份,带上参数 `/my-blog/bash/init.sh`, 再次运行 `docker-entrypoint.sh`

当再次执行该脚本时由于已经不是 root 用户了, 会直接执行 `exec "$@"`,  于是直接执行带的参数,即 CMD 定义的脚本.

很多 Dockerfile 都是这样的做法,比如 MySQL , Redis 