---
title: $.post() 和 $.ajax() 的问题记录
date: 2018-12-04 11:02:40
description: 想着写个 demo, 用个简单的 jq 的 post 请求传递数组,却发现遇到了不少问题...
categories: [前端篇]
tags: [Jquery]
---

<!-- more -->
### 背景
想着写个 demo, 用个简单的 jq 的 post 请求传递数组,却发现遇到了不少问题...
一顿研究,总结如下:

### $.post()
语法:
$.post(url,data,success(data, textStatus, jqXHR),dataType)

url	必需。规定把请求发送到哪个 URL。
data	可选。映射或字符串值。规定连同请求发送到服务器的数据。
success(data, textStatus, jqXHR)	可选。请求成功时执行的回调函数。
dataType	可选。规定预期的服务器响应的数据类型。默认执行智能判断（xml、json、script 或 html

总结需要注意的是: 
- 1. 请求的 Content-Type 是 `application/x-www-form-urlencoded; charset=UTF-8` 就是表单提交的,dataType值得是规定服务器的响应方式
- 2. 第二个参数 data 的类型是键值对的对象,不能为 JSON.stringify 后的 json 字符串,序列化后也是 key 的数据
- 3. 传数组会有问题,会将数组中每个对象的拆开然后堆到一起作为键值对传输数据, 可以通过 `jQuery.ajaxSettings.traditional = true;` 在 post 请求之前设置,防止这样的情况发生,但是对象不会被序列化,会变成 Object 这样的格式,这也不是我们想要的结果


### $.ajax()
很传统的使用方式了:
发送 post 请求
我们的 points 的是数组,里面是多个对象
数据传输使用 Request Payload 方式


``` javascript
    $.ajax({
        type: 'POST',
        url: location.origin + "/trafficService/pixelToLngLat",
        data: JSON.stringify(points),
        contentType: "application/json; charset=UTF-8",
        success: function (res, status) {
            res.map(point => {
                console.info(point)
            });
        },
    });
```

后台使用方式:

``` java
    @PostMapping("/pixelToLngLat")
    public JSONArray pixelToLngLat(@RequestBody JSONArray points){
        return restTemplate.postForObject(baiduApi.getNodeService() + "/traffic/pixelToLngLat",points,JSONArray.class);
    }
```

很传统的使用方式

### 强行使用 $.post() 
这个时候我们参数还是传输的键值对方式,只不过将值转化为 json 字符串进行传输

``` javascript
    jQuery.ajaxSettings.traditional = true;
    $.post(location.origin + "/trafficService/pixelToLngLat", {points:JSON.stringify(points)},function (res, status) {
        res.map(point => {
            console.info(point)
        });
    },"json")
```

后台使用

``` java 
    @PostMapping("/pixelToLngLat")
    public JSONArray pixelToLngLat(@RequestParam("points") String points){
        JSONArray array = JSONArray.parseArray(points);
        return restTemplate.postForObject(baiduApi.getNodeService() + "/traffic/pixelToLngLat",array,JSONArray.class);
    }
```

### 总结
> 表单提交方式,如果后台有相应的对象的来接受参数的话,直接在方法是使用对象即可,不需要再通过 JSONObject 将字符串转数组了,这种方式 $.ajax() 同样也适用
