---
title: React WebSocket 的一些配置
date: 2020-01-15 11:08:50
description: React WebSocket 的一些配置
categories: [React篇]
tags: [react]
---

<!-- more -->
### spring boot 后台的配置
这里记录一些坑
使用 gradle 配置, 其中移除了 Tomcat , 使用的是 Undertow
先引入依赖

`implementation ('org.springframework.boot:spring-boot-starter-websocket')`

提示报错 web 容器没有实现 JSR356 
undertow 肯定是实现了 JSR356, 在 undertow-websockets-jsr 这个依赖里
判断肯定是由于移除 Tomcat 的问题,查看依赖发现 `spring-boot-starter-websocket` 依赖了 web , 而 web 默认使用的就是 Tomcat
于是移除 web 依赖即可

``` groovy 
    implementation ('org.springframework.boot:spring-boot-starter-websocket'){
         exclude group: 'org.springframework.boot', module: 'spring-boot-starter-web'
    }
```

代码部分:

``` java
    @Configuration
    public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {
    
        @Override
        public void configureMessageBroker(MessageBrokerRegistry config) {
    //        config.enableSimpleBroker("/topic");
        }
    
        @Override
        public void registerStompEndpoints(StompEndpointRegistry registry) {
            registry.addEndpoint("/ws")
                    .setAllowedOrigins("*")
                    .withSockJS();
        }
    
    }
```

注意在启动类上加入: `@EnableWebSocketMessageBroker`

这里使用的是 stomp 协议, 于是也要前端使用 stomp 配合

发送消息可以加入 @SendTo 注解, 还有一种方式, 就是使用 SimpMessagingTemplate

``` java
    @RestController
    @RequestMapping("ws")
    public class PushMessage {
    
        private final SimpMessagingTemplate template;
    
        public PushMessage(SimpMessagingTemplate template) {
            this.template = template;
        }
    
        @GetMapping("/config")
        public void configMessage() {
            template.convertAndSend("/topic/public", MessageBody.success());
        }
    }
```

### React 配置
安装组件 npm install react-stomp
自行封装一个组件,如下:

``` js
    import React, {Component} from 'react';
    import SockJsClient from "react-stomp";
    import {message} from "antd";
    
    class Websocket extends Component {
    
        render() {
            return (
                <div>
                    <SockJsClient
                        url={'ws'}
                        topics={[]}
                        onMessage={(payload) => {
                            console.info(payload)
                        }}
                        onConnect={() => {
                            console.info("websocket connect success")
                        }}
                        onConnectFailure={() => {
                            message.error("websocket 连接失败!")
                        }}
                        onDisconnect={() => {
                            console.info("websocket disconnect")
                        }}
                        debug={false}
                        {...this.props}
                    />
                </div>
            );
        }
    }
    
    export default Websocket;
```

子组件使用: 

``` js
    <Websocket
        topics={['/topic/public']}
        debug={false}
        onMessage={(payload) => {
            // do somthing
        }}
    />
```

### 遇坑解决
以上方式看起来使用没有问题,但是现实情况往往开发时前后端分离,请求后端接口往往在 node 项目里配置代理, 这里涉及到 websocket 的代理

之前的配置都是在 package.json 配置, 比如: 

``` json
    "proxy": "http://localhost:8098"
```

但是这种方式对 websocket 的代理失败,会发现 websocket 连接不上

解决方式:
在新版的 customize-cra 的使用方式里:
先安装 http-proxy-middleware : npm install http-proxy-middleware
在 src 目录下新建文件 setupProxy.js, 名字不可改,一定要是这个文件名

```js
    const proxy = require("http-proxy-middleware");
    const pck = require('../package');
    
    module.exports = app => {
        app.use(
            proxy("/ws",
                {
                    target: pck.proxy,
                    ws: true
                })
        )
    };
```

这里开启 ws: true 即可完成 websocket 的代理.