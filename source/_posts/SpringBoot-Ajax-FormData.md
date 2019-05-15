---
title: 重剑无锋,大巧不工 SpringBoot --- 使用 Ajax FromData 上传文件并传参
date: 2019-04-15 17:04:19
description: SpringBoot 使用 Ajax From Data 来上传文件和参数并进行处理
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->
### 页面

``` javascript
    const formData = new FormData();
    
    fileList.forEach(file => {
        formData.append('file', file.originFileObj);
    });


    // 每个表单是否填写完成
    let params = [];
    
    .....
    
    
    let data = {};
    data.filePath = "";
    data.markers = params;
    formData.append("params", data);

    $.ajax({
        url: "/marker/file",
        type: "POST",
        processData: false,
        contentType: false,
        data: formData,
        success: function (data) {
        },
        error: function (err) {
        }
    });
```

### spring boot 处理

``` java
    @PostMapping("/file")
    public Object markerFile(@RequestParam("file") MultipartFile multipartFile, Params params){
        return markerService.marker(multipartFile,params);
    }
```

### 注意
1. antd 上传组件里,真正的文件是 file.originFileObj
2. params 是复杂的对象的话, spring boot 接受的 Params 对象需要使用 String 字符串进行序列化成对象; 或者将 Params 对象的属性分开来写, 如果某个属性又是复杂对象的话通用需要序列化