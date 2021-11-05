---
title: k8s 挂载外部 nfs 存储
date: 2021-09-20 10:08:23
description: k8s 挂载外部 nfs 存储
categories: [K8s篇]
tags: [K8s]
---

<!-- more -->

暴露挂载点的机器：

```yum -y install nfs-utils```


```mkdir -p /nfs/data/```

```chmod -R 777 /nfs/data```

```vim /etc/exports```

写入以下内容：

```/nfs/data *(rw,no_root_squash,sync)```

生效配置并查看

```exportfs -r```
```exportfs```

启动服务：

```systemctl restart rpcbind && systemctl enable rpcbind```
```systemctl restart nfs-server && systemctl enable nfs-server```


其他需要进行挂载的机器：

```shell
yum -y install nfs-utils
systemctl start nfs rpcbind
systemctl enable nfs rpcbind
```

测试挂载：
```showmount -e 192.168.1.2```

直接挂载到本地查看：
```mount 192.168.1.2:/nfs/data /opt```


卸载挂载：
```umount /opt```


Pod 挂载使用：

```yaml
apiVersion: v1
kind: Pod
metadata:
labels:
run: nginx
name: podxx
spec:
volumes:
- name: nfs
  nfs:
  server: 192.168.1.244
  path: /nfs/data
  containers:
- image: nginx
  name: nginx
  volumeMounts:
- mountPath: /usr/share/nginx/html
  name: nfs
```