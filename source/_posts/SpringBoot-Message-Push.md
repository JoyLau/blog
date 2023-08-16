---
title: SpringBoot --- 实现实时消息推送的解决方案汇总
date: 2023-08-16 09:35:48
description: SpringBoot 实现实时消息推送的解决方案汇总
categories: [SpringBoot篇]
tags: [SpringBoot]
---

<!-- more -->

# 方案
1. 短轮询
2. 长轮询: 可以使用 Spring 提供的 `DeferredResult` 实现
3. iframe流
4. SSE: 服务器响应 `text/event-stream` 类型的数据流信息，思路类似于在线视频播放

```javascript
<script>
    let source = null;
    let userId = 7777
    if (window.EventSource) {
        // 建立连接
        source = new EventSource('http://localhost:7777/sse/sub/'+userId);
        setMessageInnerHTML("连接用户=" + userId);
        /**
         * 连接一旦建立，就会触发open事件
         * 另一种写法：source.onopen = function (event) {}
         */
        source.addEventListener('open', function (e) {
            setMessageInnerHTML("建立连接。。。");
        }, false);
        /**
         * 客户端收到服务器发来的数据
         * 另一种写法：source.onmessage = function (event) {}
         */
        source.addEventListener('message', function (e) {
            setMessageInnerHTML(e.data);
        });
    } else {
        setMessageInnerHTML("你的浏览器不支持SSE");
    }
</script>
```

```java
    private static Map<String, SseEmitter> sseEmitterMap = new ConcurrentHashMap<>();
    
    /**
     * 创建连接
     *
     * @date: 2022/7/12 14:51
     * @auther: 程序员小富
     */
    public static SseEmitter connect(String userId) {
        try {
            // 设置超时时间，0表示不过期。默认30秒
            SseEmitter sseEmitter = new SseEmitter(0L);
            // 注册回调
            sseEmitter.onCompletion(completionCallBack(userId));
            sseEmitter.onError(errorCallBack(userId));
            sseEmitter.onTimeout(timeoutCallBack(userId));
            sseEmitterMap.put(userId, sseEmitter);
            count.getAndIncrement();
            return sseEmitter;
        } catch (Exception e) {
            log.info("创建新的sse连接异常，当前用户：{}", userId);
        }
        return null;
    }
    
    /**
     * 给指定用户发送消息
     *
     * @date: 2022/7/12 14:51
     * @auther: 程序员小富
     */
    public static void sendMessage(String userId, String message) {
    
        if (sseEmitterMap.containsKey(userId)) {
            try {
                sseEmitterMap.get(userId).send(message);
            } catch (IOException e) {
                log.error("用户[{}]推送异常:{}", userId, e.getMessage());
                removeUser(userId);
            }
        }
    }
```
5. MQTT
6. WebSocket

> 转载地址: https://mp.weixin.qq.com/s/DlW5XnpG7v0eIiIz9XzDvg