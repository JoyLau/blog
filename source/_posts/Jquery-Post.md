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
dataType	可选。规定预期的服务器响应的数据类型。默认执行智能判断（xml、json、script 或 html)

该语法等价于:

```js
    $.ajax({
        type: 'POST',
        url: url,
        data: {
            pageNumber: 10
        },
        success: function (res, status) {
            console.info(res)
        },
    });
```

总结需要注意的是: 
- 请求的 Content-Type 是 `application/x-www-form-urlencoded; charset=UTF-8` 就是表单提交的, dataType 指得是规定服务器的响应方式
- 第二个参数 data 的类型是键值对的对象,不能为 JSON.stringify 后的 json 字符串
- 传数组会有问题,会将数组中每个对象的拆开然后堆到一起作为键值对传输数据, 可以通过 `jQuery.ajaxSettings.traditional = true;` 在 post 请求之前设置,防止这样的情况发生,但是对象不会被序列化,会变成 Object 这样的格式,这也不是我们想要的结果
- `traditional` 可在 `$.ajax` 的配置项里显式声明

注意:

> Content-Type 是 `application/x-www-form-urlencoded; charset=UTF-8` 传参时
> Spirng Boot 后台的接受的参数的形式可以为对象, 不需要加注解
> 该对象的属性需要包含 data 里的值, 否则的话,接受到的对象里的属性为空

### $.ajax()
很传统的使用方式了:
发送 post 请求
我们的 points 的是数组,里面是多个对象
数据传输使用 Request Payload 方式


```javascript
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

这种请求的 Content-Type 是 `application/json; charset=UTF-8`, 后台必须用 `@RequestBody` 注解接受参数
这种方式容错性比较高, `@RequestBody` 注解的对象可以是 HashMap, JSONObject, JSONArray, String, Object 都可以获取到数据
不像 `application/x-www-form-urlencoded`, 需要对象和传的值一一对应才能获取到值


### 强行使用 $.post() 
这个时候我们参数还是传输的键值对方式,只不过将值转化为 json 字符串进行传输

```javascript
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


@RequestParam("points") 显式指定了接受 points 的值, 即字符串 JSON.stringify(points)
其实完全可以在后台定义一个 Points 对象, 属性和前台的传的数据属性一一对应, 用来接受前台传过来的数据

### 总结
1. 表单提交方式,如果后台有相应的对象的来接受参数的话,直接在方法是使用对象即可,这种方式需要事先定义一个对象, 前台传的数据就按照这个对象的属性来, 这种方式看起来数据很清晰
2. `application/json` 需要注解 `@RequestBody`, 注解的对象可以是 HashMap, JSONObject, JSONArray, String, Object 都可以获取到数据, 灵活性高
