---
title: Docker LibreOffice Online Requesting address is denied&#58; &#58;&#58; ffff&#58;172.xx.xx.xx 错误解决记录
date: 2020-04-12 12:37:17
description: Docker LibreOffice Online Requesting address is denied&#58; &#58;&#58;ffff&#58;172.xx.xx.xx 错误解决记录
categories: [Docker篇]
tags: [Docker]
---

<!-- more -->
### 解决
这是容器内使用 ipv6 造成的
解决方式:
添加参数

``` text
    - e 'extra_params=--o:ssl.enable=false --o:net.post_allow.host[0]=.\{1,99\}'
```

使用正则匹配所有 ip , 注意使用单引号, 否则反斜杠需要转义



