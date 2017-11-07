---
title: npm install 居然出错了
date: 2017-11-7 10:55:01
description: "在 npm install 居然出错了。。。npm: relocation error: npm: symbol SSL_set_cert_cb, version libssl.so.10 not defined in file libssl."
categories: [Node篇]
tags: [Nodejs]
---

<!-- more -->


今天在安装完nodejs后执行 npm install 居然出错了

npm: relocation error: npm: symbol SSL_set_cert_cb, version libssl.so.10 not defined in file libssl.

npm: relocation error: npm: symbol SSL_set_cert_cb, version libssl.so.10 not defined in file libssl.so.10 with link time reference", "rc": 127, "stderr": "npm: relocation error: npm: symbol SSL_set_cert_cb, version libssl.so.10 not defined in file libssl.so.10 with link time reference\n", "stderr_lines": ["npm: relocation error: npm: symbol SSL_set_cert_cb, version libssl.so.10 not defined in file libssl.so.10 with link time reference


解决办法：

  yum -y install openssl

  如果已经安装，就更新一下

  yum -y update openssl