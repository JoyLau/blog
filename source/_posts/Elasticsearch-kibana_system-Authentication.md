---
title: "Elasticsearch Authentication of [kibana_system] was terminated by realm [reserved] 报错解决"
date: 2023-08-26 16:58:24
description: "Elasticsearch Authentication of [kibana_system] was terminated by realm [reserved] 报错解决"
categories: [Elasticsearch]
tags: [Elasticsearch]
---

<!-- more -->

## 解决
问题原因是 kibana_system 的用户名密码不正确

修改密码方式

进入 elasticsearch docker 容器内部, 执行

```bash
curl -X POST --cacert config/certs/ca/ca.crt -u "elastic:${ES_PASS}" -H "Content-Type: application/json" 
http://es01:9200/_security/user/kibana_system/_password -d "{\"password\":\"${KIBANA_PASS}\"}"
```

修改密码









