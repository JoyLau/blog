---
title: Typora 使用自定义 Node 脚本上传图片到 MinIO 图床上
date: 2022-03-18 15:26:00
description: Typora 使用自定义 Node 脚本上传图片到 MinIO 图床上
categories: [Node篇]
tags: [Nodejs]
---

<!-- more -->

### 脚本
```javascript
/* 
 * typora插入图片调用此脚本,上传图片到 MinIO
 */

const path = require('path')
// minio for node.js
const Minio = require('minio')
const { promises } = require('fs')

const endPoint = "xxxx"
const port = xxxx
const accessKey = "xxxx"
const secretKey = "xxxx"
const bucketName = "typora"
const filePath = new Date().getFullYear() + "-" + (new Date().getMonth() + 1) + "/" + new Date().getDate()


// 解析参数, 获取图片的路径,有可能是多张图片
const parseArgv = () => {
    const imageList = process.argv.slice(2).map(u => path.resolve(u))
    console.info("选择的文件列表:", imageList)
    return imageList
}
// 永久地址的策略
const policy = () => {
    return {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": [
                        "*"
                    ]
                },
                "Action": [
                    "s3:GetBucketLocation",
                    "s3:ListBucket",
                    "s3:ListBucketMultipartUploads"
                ],
                "Resource": [
                    "arn:aws:s3:::" + bucketName
                ]
            },
            {
                "Effect": "Allow",
                "Principal": {
                    "AWS": [
                        "*"
                    ]
                },
                "Action": [
                    "s3:ListMultipartUploadParts",
                    "s3:PutObject",
                    "s3:AbortMultipartUpload",
                    "s3:DeleteObject",
                    "s3:GetObject"
                ],
                "Resource": [
                    "arn:aws:s3:::" + bucketName + "/*"
                ]
            }
        ]
    }
}

// 入口
const uploadImageFile = async (imageList = []) => {
    // 创建连接
    const minioClient = new Minio.Client({
        endPoint: endPoint,
        port: port,
        useSSL: false,
        accessKey: accessKey,
        secretKey: secretKey
    })
    // 判断桶是否存在
    minioClient.bucketExists(bucketName, function (err, exists) {
        if (!exists) {
            // 创建桶
            minioClient.makeBucket(bucketName, '', function (err) {
                if (err) throw err
                // 设置桶策略
                minioClient.setBucketPolicy(bucketName, JSON.stringify(policy()), function (err) {
                    if (err) throw err
                })
            })
        }
        // 开始上传图片
        imageList.map(image => {
            // 图片重命名
            const name = `${Date.now()}${path.extname(image)}`
            // 将图片上传到 bucket 上
            minioClient.fPutObject(bucketName, filePath + "/" + name, image, {}, function(info) {
                const url = `http://${endPoint}:${port}/${bucketName}/${filePath}/${name}`
                // Typora会提取脚本的输出作为地址,将markdown上图片链接替换掉
                console.log(url)
            })
        })
    })
}

// 执行脚本
uploadImageFile(parseArgv())
```

在该脚本目录下执行
```npm intsall minio```

### 配置
在脚本中配置 MinIO 服务端的配置项

在 Typora 进行如下配置

![image-20220318152717467](http://112.29.246.234:6106/typora/2022-3/18/1647588437679.png)

该脚本支持
- 自动创建 bucket
- 多文件批量上传