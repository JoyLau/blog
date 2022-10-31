---
title: SpringCloud Gateway --- 获取请求体数据并记录日志
date: 2022-10-15 08:45:35
description: SpringCloud Gateway 获取请求体数据并记录日志
categories: [SpringCloud篇]
tags: [SpringCloud]
---

<!-- more -->

SpringCloud Gateway 中想要获取请求体数据，这里介绍一种优雅的处理方法，就是使用 框架自带的 ModifyRequestBodyGatewayFilterFactory

## 使用

新建类 RequestLogFilter

```java
   @Slf4j
   @Component
   @AllArgsConstructor
   public class RequestLogFilter implements GlobalFilter, Ordered {
   
      private final ModifyRequestBodyGatewayFilterFactory modifyRequestBodyGatewayFilterFactory;
   
      private final AsyncRequestHandler asyncRequestHandle;
   
      @Override
      public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
         // 不解析 body
         if (Utils.isUploadRequest(exchange)) {
            process(exchange, null);
            return chain.filter(exchange);
         }
         ModifyRequestBodyGatewayFilterFactory.Config modifyRequestConfig =
                 new ModifyRequestBodyGatewayFilterFactory.Config()
                         .setRewriteFunction(byte[].class, byte[].class, (e, bytes) -> {
                            process(e, bytes);
                            return Mono.justOrEmpty(bytes);
                         });
         return modifyRequestBodyGatewayFilterFactory.apply(modifyRequestConfig).filter(exchange, chain);
      }
   
      @Override
      public int getOrder() {
         return -100;
      }
   
      private void process(ServerWebExchange exchange, byte[] bytes) {
         // 设置当前请求时间
         exchange.getAttributes().put(Constant.REQUEST_START_TIME_ATTR, System.currentTimeMillis());
         exchange.getAttributes().put(Constant.ACCESS_LOG_REQUEST_FUTURE_ATTR,
                 asyncRequestHandle.handle(exchange, bytes));
      }
   }
```

``` java
       /**
       * 判断是否文件上传请求
       *
       * @param exchange ServerWebExchange
       * @return boolean
       */
      public static boolean isUploadRequest(ServerWebExchange exchange){
        return MediaType.MULTIPART_FORM_DATA.isCompatibleWith(requestContentType(exchange));
     }
```


新建 AsyncRequestHandler 类

```java
   @Component
   @Slf4j
   @AllArgsConstructor
   public class AsyncRequestHandler {
      @Async("logTaskPool")
      public Future<AccessLog> handle(ServerWebExchange exchange, byte[] bytes) {
         return new AsyncResult<>(wrapperAccessLog(exchange, bytes));
      }
   
      /**
       * 保证访问日志请求体
       *
       * @param exchange ServerWebExchange
       * @param bytes    data to send
       * @return log
       */
      private AccessLog wrapperAccessLog(ServerWebExchange exchange, byte[] bytes) {
         ServerHttpRequest request = exchange.getRequest();
         AccessLog accessLog = new AccessLog();
         accessLog.setToken(Utils.getToken(exchange));
         accessLog.setTime(LocalDateTime.now());
         accessLog.setApplication(getApplicationName(exchange));
         accessLog.setIp(Utils.getIp(exchange));
         accessLog.setUri(request.getURI().toString());
         accessLog.setHttpMethod(HttpMethod.valueOf(request.getMethodValue()));
         // 临时设置当前时间，后面替换成真正耗时
         accessLog.setTakenTime((long) exchange.getAttributes().get(Constant.REQUEST_START_TIME_ATTR));
         accessLog.setRequestHeaders(request.getHeaders().toSingleValueMap().toString());
         if(Utils.isUploadRequest(exchange)) {
            accessLog.setRequest("二进制文件");
         }
         Optional.ofNullable(bytes).ifPresent(bs -> {
            if (bytes.length <= DataSize.ofKilobytes(256).toBytes()) {
               // 小于指定大小的报文进行转化(考虑到文件上传的请求报文)
               accessLog.setRequest(new String(bytes, StandardCharsets.UTF_8));
            } else {
               accessLog.setRequest("报文过长");
            }
         });
         return accessLog;
      }
   
      /**
       * 获取服务名称
       *
       * @param exchange ServerWebExchange
       * @return name of the application
       */
      private String getApplicationName(ServerWebExchange exchange) {
         String routingId =
                 (String) exchange.getAttributes().get(ServerWebExchangeUtils.GATEWAY_PREDICATE_MATCHED_PATH_ROUTE_ID_ATTR);
         // 自动注册的微服务
         if (routingId.startsWith(Constant.MODULE_SUB_PREFIX)) {
            return routingId.substring(Constant.MODULE_SUB_PREFIX.length());
         } else {
            return routingId;
         }
      }
   
   }
```

AccessLog

```java
   public class AccessLog extends AbstractLog {
   
      /**
       * 所属服务
       */
      private String application;
   
      /**
       * ip
       */
      private String ip;
   
      /**
       * uri
       */
      private String uri;
   
      /**
       * 请求方法
       */
      private HttpMethod httpMethod;
   
      /**
       * 消耗时间，单位毫秒
       */
      private Long takenTime;
   
      /**
       * http 状态码
       */
      private Integer httpCode;
   
      /**
       * 请求报文
       */
      private String request;
   
      /**
       * 响应报文
       */
      private String response;
   
      /**
       * 请求头信息
       */
      private String requestHeaders;
   
      /**
       * 响应头信息
       */
      private String responseHeaders;
   
   
      public String getApplication() {
         return application;
      }
   
      public void setApplication(String application) {
         this.application = application;
      }
   
      public String getIp() {
         return ip;
      }
   
      public void setIp(String ip) {
         this.ip = ip;
      }
   
      public String getUri() {
         return uri;
      }
   
      public void setUri(String uri) {
         this.uri = uri;
      }
   
      public HttpMethod getHttpMethod() {
         return httpMethod;
      }
   
      public void setHttpMethod(HttpMethod httpMethod) {
         this.httpMethod = httpMethod;
      }
   
      public Long getTakenTime() {
         return takenTime;
      }
   
      public void setTakenTime(Long takenTime) {
         this.takenTime = takenTime;
      }
   
      public Integer getHttpCode() {
         return httpCode;
      }
   
      public void setHttpCode(Integer httpCode) {
         this.httpCode = httpCode;
      }
   
      public String getRequest() {
         return request;
      }
   
      public void setRequest(String request) {
         this.request = request;
      }
   
      public String getResponse() {
         return response;
      }
   
      public void setResponse(String response) {
         this.response = response;
      }
   
      public String getRequestHeaders() {
         return requestHeaders;
      }
   
      public void setRequestHeaders(String requestHeaders) {
         this.requestHeaders = requestHeaders;
      }
   
      public String getResponseHeaders() {
         return responseHeaders;
      }
   
      public void setResponseHeaders(String responseHeaders) {
         this.responseHeaders = responseHeaders;
      }
   }
```

AbstractLog

```java
   public abstract class AbstractLog {

      /**
       * 日志 id
       */
      private String id;
   
      /**
       * 访问 token
       */
      private String token;
   
      /**
       * 用户 id
       */
      private String userid;
   
      /**
       * 用户名（用户账号)
       */
      private String username;
   
      /**
       * 用户姓名
       */
      private String name;
   
      /**
       * 操作时间
       */
      private LocalDateTime time;
   
      /**
       * 操作来源
       */
      private OriginType originType;
   
   
      public String getId() {
         return id;
      }
   
      public void setId(String id) {
         this.id = id;
      }
   
      public String getToken() {
         return token;
      }
   
      public void setToken(String token) {
         this.token = token;
      }
   
      public String getUserid() {
         return userid;
      }
   
      public void setUserid(String userid) {
         this.userid = userid;
      }
   
      public String getUsername() {
         return username;
      }
   
      public void setUsername(String username) {
         this.username = username;
      }
   
      public String getName() {
         return name;
      }
   
      public void setName(String name) {
         this.name = name;
      }
   
      public LocalDateTime getTime() {
         return time;
      }
   
      public void setTime(LocalDateTime time) {
         this.time = time;
      }
   
      public OriginType getOriginType() {
         return originType;
      }
   
      public void setOriginType(OriginType originType) {
         this.originType = originType;
      }
   }
```

注意：  
这里对请求的数据进行了拦截并包装成日志对象存储在 exchange 的一个 ACCESS_LOG_REQUEST_FUTURE_ATTR 属性中，后面再拿到响应时，在从 exchange 拿回请求数据和响应数据一并使用