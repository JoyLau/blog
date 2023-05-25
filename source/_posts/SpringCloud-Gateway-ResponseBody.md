---
title: SpringCloud Gateway --- 获取响应体数据并记录日志
date: 2022-10-25 18:45:35
description: SpringCloud Gateway 获取响应体数据并记录日志
categories: [SpringCloud篇]
tags: [SpringCloud]
---

<!-- more -->

## 注意
上篇中，我们获取到了请求数据报文，这篇继续获取响应报文并发往持久化存储  
这里获取响应报文需要排除掉文件下载的情况

## 使用
1. 新建类 ModifyResponseBodyGatewayFilterFactoryCopy
该类照抄子 spring 源码 ModifyResponseBodyGatewayFilterFactory 添加了判断，当请求返回的头信息非 json 响应时， 将不再解析报文

```java
    /**
     * 根据 spring 源码优化
     * 优化了文件下载请求解析报文带来的内存使用
     * 添加了如下代码判断，当请求返回的头信息非 json 响应时， 将不再解析报文
     * public Mono<Void> writeWith(Publisher<? extends DataBuffer> body)
     *    if (!Utils.isJsonResponse(exchange)) {
     *        config.getRewriteFunction().apply(exchange, null);
     *        return getDelegate().writeWith(body);
     *    }
     *
     */
    public class ModifyResponseBodyGatewayFilterFactoryCopy extends AbstractGatewayFilterFactory<ModifyResponseBodyGatewayFilterFactoryCopy.Config> {
    
        private final Map<String, MessageBodyDecoder> messageBodyDecoders;
    
        private final Map<String, MessageBodyEncoder> messageBodyEncoders;
    
        private final List<HttpMessageReader<?>> messageReaders;
    
        public ModifyResponseBodyGatewayFilterFactoryCopy(List<HttpMessageReader<?>> messageReaders,
                                                          Set<MessageBodyDecoder> messageBodyDecoders, Set<MessageBodyEncoder> messageBodyEncoders) {
            super(Config.class);
            this.messageReaders = messageReaders;
            this.messageBodyDecoders = messageBodyDecoders.stream()
                    .collect(Collectors.toMap(MessageBodyDecoder::encodingType, identity()));
            this.messageBodyEncoders = messageBodyEncoders.stream()
                    .collect(Collectors.toMap(MessageBodyEncoder::encodingType, identity()));
        }
    
        @Override
        public GatewayFilter apply(Config config) {
            ModifyResponseGatewayFilter gatewayFilter = new ModifyResponseGatewayFilter(config);
            gatewayFilter.setFactory(this);
            return gatewayFilter;
        }
    
        public static class Config {
    
            private Class inClass;
    
            private Class outClass;
    
            private Map<String, Object> inHints;
    
            private Map<String, Object> outHints;
    
            private String newContentType;
    
            private RewriteFunction rewriteFunction;
    
            public Class getInClass() {
                return inClass;
            }
    
            public Config setInClass(Class inClass) {
                this.inClass = inClass;
                return this;
            }
    
            public Class getOutClass() {
                return outClass;
            }
    
            public Config setOutClass(Class outClass) {
                this.outClass = outClass;
                return this;
            }
    
            public Map<String, Object> getInHints() {
                return inHints;
            }
    
            public Config setInHints(Map<String, Object> inHints) {
                this.inHints = inHints;
                return this;
            }
    
            public Map<String, Object> getOutHints() {
                return outHints;
            }
    
            public Config setOutHints(Map<String, Object> outHints) {
                this.outHints = outHints;
                return this;
            }
    
            public String getNewContentType() {
                return newContentType;
            }
    
            public Config setNewContentType(String newContentType) {
                this.newContentType = newContentType;
                return this;
            }
    
            public RewriteFunction getRewriteFunction() {
                return rewriteFunction;
            }
    
            public Config setRewriteFunction(RewriteFunction rewriteFunction) {
                this.rewriteFunction = rewriteFunction;
                return this;
            }
    
            public <T, R> Config setRewriteFunction(Class<T> inClass, Class<R> outClass,
                                                    RewriteFunction<T, R> rewriteFunction) {
                setInClass(inClass);
                setOutClass(outClass);
                setRewriteFunction(rewriteFunction);
                return this;
            }
    
        }
    
        public class ModifyResponseGatewayFilter implements GatewayFilter, Ordered {
    
            private final Config config;
    
            private GatewayFilterFactory<Config> gatewayFilterFactory;
    
            public ModifyResponseGatewayFilter(Config config) {
                this.config = config;
            }
    
            @Override
            public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
                return chain.filter(exchange.mutate().response(new ModifiedServerHttpResponse(exchange, config)).build());
            }
    
            @Override
            public int getOrder() {
                return NettyWriteResponseFilter.WRITE_RESPONSE_FILTER_ORDER - 1;
            }
    
            @Override
            public String toString() {
                Object obj = (this.gatewayFilterFactory != null) ? this.gatewayFilterFactory : this;
                return filterToStringCreator(obj).append("New content type", config.getNewContentType())
                        .append("In class", config.getInClass()).append("Out class", config.getOutClass()).toString();
            }
    
            public void setFactory(GatewayFilterFactory<Config> gatewayFilterFactory) {
                this.gatewayFilterFactory = gatewayFilterFactory;
            }
    
        }
    
        protected class ModifiedServerHttpResponse extends ServerHttpResponseDecorator {
    
            private final ServerWebExchange exchange;
    
            private final Config config;
    
            public ModifiedServerHttpResponse(ServerWebExchange exchange, Config config) {
                super(exchange.getResponse());
                this.exchange = exchange;
                this.config = config;
            }
    
            @SuppressWarnings("unchecked")
            @Override
            public Mono<Void> writeWith(Publisher<? extends DataBuffer> body) {
                if (!Utils.isJsonResponse(exchange)) {
                    config.getRewriteFunction().apply(exchange, null);
                    return getDelegate().writeWith(body);
                }
    
                Class inClass = config.getInClass();
                Class outClass = config.getOutClass();
    
                String originalResponseContentType = exchange.getAttribute(ORIGINAL_RESPONSE_CONTENT_TYPE_ATTR);
    
                HttpHeaders httpHeaders = new HttpHeaders();
                // explicitly add it in this way instead of
                // 'httpHeaders.setContentType(originalResponseContentType)'
                // this will prevent exception in case of using non-standard media
                // types like "Content-Type: image"
                httpHeaders.add(HttpHeaders.CONTENT_TYPE, originalResponseContentType);
    
                ClientResponse clientResponse = prepareClientResponse(body, httpHeaders);
    
                // TODO: flux or mono
                Mono modifiedBody = extractBody(exchange, clientResponse, inClass)
                        .flatMap(originalBody -> config.getRewriteFunction().apply(exchange, originalBody))
                        .switchIfEmpty(Mono.defer(() -> (Mono) config.getRewriteFunction().apply(exchange, null)));
    
                BodyInserter bodyInserter = BodyInserters.fromPublisher(modifiedBody, outClass);
                CachedBodyOutputMessage outputMessage = new CachedBodyOutputMessage(exchange,
                        exchange.getResponse().getHeaders());
                return bodyInserter.insert(outputMessage, new BodyInserterContext()).then(Mono.defer(() -> {
                    Mono<DataBuffer> messageBody = writeBody(getDelegate(), outputMessage, outClass);
                    HttpHeaders headers = getDelegate().getHeaders();
                    if (!headers.containsKey(HttpHeaders.TRANSFER_ENCODING)
                            || headers.containsKey(HttpHeaders.CONTENT_LENGTH)) {
                        messageBody = messageBody.doOnNext(data -> headers.setContentLength(data.readableByteCount()));
                    }
                    // TODO: fail if isStreamingMediaType?
                    return getDelegate().writeWith(messageBody);
                }));
            }
    
            @Override
            public Mono<Void> writeAndFlushWith(Publisher<? extends Publisher<? extends DataBuffer>> body) {
                return writeWith(Flux.from(body).flatMapSequential(p -> p));
            }
    
            private ClientResponse prepareClientResponse(Publisher<? extends DataBuffer> body, HttpHeaders httpHeaders) {
                ClientResponse.Builder builder;
                builder = ClientResponse.create(exchange.getResponse().getStatusCode(), messageReaders);
                return builder.headers(headers -> headers.putAll(httpHeaders)).body(Flux.from(body)).build();
            }
    
            private <T> Mono<T> extractBody(ServerWebExchange exchange, ClientResponse clientResponse, Class<T> inClass) {
                // if inClass is byte[] then just return body, otherwise check if
                // decoding required
                if (byte[].class.isAssignableFrom(inClass)) {
                    return clientResponse.bodyToMono(inClass);
                }
    
                List<String> encodingHeaders = exchange.getResponse().getHeaders().getOrEmpty(HttpHeaders.CONTENT_ENCODING);
                for (String encoding : encodingHeaders) {
                    MessageBodyDecoder decoder = messageBodyDecoders.get(encoding);
                    if (decoder != null) {
                        return clientResponse.bodyToMono(byte[].class).publishOn(Schedulers.parallel()).map(decoder::decode)
                                .map(bytes -> exchange.getResponse().bufferFactory().wrap(bytes))
                                .map(buffer -> prepareClientResponse(Mono.just(buffer),
                                        exchange.getResponse().getHeaders()))
                                .flatMap(response -> response.bodyToMono(inClass));
                    }
                }
    
                return clientResponse.bodyToMono(inClass);
            }
    
            private Mono<DataBuffer> writeBody(ServerHttpResponse httpResponse, CachedBodyOutputMessage message,
                                               Class<?> outClass) {
                Mono<DataBuffer> response = DataBufferUtils.join(message.getBody());
                if (byte[].class.isAssignableFrom(outClass)) {
                    return response;
                }
    
                List<String> encodingHeaders = httpResponse.getHeaders().getOrEmpty(HttpHeaders.CONTENT_ENCODING);
                for (String encoding : encodingHeaders) {
                    MessageBodyEncoder encoder = messageBodyEncoders.get(encoding);
                    if (encoder != null) {
                        DataBufferFactory dataBufferFactory = httpResponse.bufferFactory();
                        response = response.publishOn(Schedulers.parallel()).map(buffer -> {
                            byte[] encodedResponse = encoder.encode(buffer);
                            DataBufferUtils.release(buffer);
                            return encodedResponse;
                        }).map(dataBufferFactory::wrap);
                        break;
                    }
                }
    
                return response;
            }
    
        }
    
    }
```

2. 新建自动导入类

```java
    @Configuration
    public class ModifyResponseBodyGatewayFilterAutoConfiguration {
    
        @Bean
        @ConditionalOnEnabledFilter
        public ModifyResponseBodyGatewayFilterFactoryCopy modifyResponseBodyGatewayFilterFactoryCopy(
                ServerCodecConfigurer codecConfigurer, Set<MessageBodyDecoder> bodyDecoders,
                Set<MessageBodyEncoder> bodyEncoders) {
            return new ModifyResponseBodyGatewayFilterFactoryCopy(codecConfigurer.getReaders(), bodyDecoders, bodyEncoders);
        }
    }
```

3. 新建响应日志全局拦截类

```java
    @Slf4j
    @Component
    @AllArgsConstructor
    public class ResponseLogFilter implements GlobalFilter, Ordered {
        private final ModifyResponseBodyGatewayFilterFactoryCopy modifyResponseBodyGatewayFilterFactoryCopy;
    
        private final AsyncResponseHandler asyncResponseHandler;
    
        @Override
        public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
            ModifyResponseBodyGatewayFilterFactoryCopy.Config config = new ModifyResponseBodyGatewayFilterFactoryCopy.Config()
                    .setRewriteFunction(byte[].class, byte[].class, (e, bytes) -> {
                        asyncResponseHandler.handle(e, bytes);
                        return Mono.justOrEmpty(bytes);
                    });
            return modifyResponseBodyGatewayFilterFactoryCopy.apply(config).filter(exchange, chain);
        }
    
        @Override
        public int getOrder() {
            return NettyWriteResponseFilter.WRITE_RESPONSE_FILTER_ORDER - 98;
        }
    }

```

4. 新建日志记录处理类

```java
@Slf4j
@Component
@AllArgsConstructor
public class AsyncResponseHandler {

    private final Jackson2HashMapper jackson2HashMapper;

    private final RedisTemplate<String, AbstractLog> logRedisTemplate;

    private final ObjectMapper objectMapper;

    @Async("logTaskPool")
    @SuppressWarnings("unchecked")
    public void handle(ServerWebExchange exchange, byte[] bytes) {
        ServerHttpResponse response = exchange.getResponse();
        try {
            Future<AccessLog> future =
                    (Future<AccessLog>) exchange.getAttributes().get(Constant.ACCESS_LOG_REQUEST_FUTURE_ATTR);
            AccessLog accessLog = future.get(10, TimeUnit.SECONDS);
            accessLog.setResponseHeaders(response.getHeaders().toSingleValueMap().toString());
            try {
                String aud = JwtUtils.verifyTokenSubject(accessLog.getToken());
                accessLog.setOriginType(OriginType.getByValue(aud));
            } catch (Exception e) {
                accessLog.setOriginType(OriginType.OTHER);
            }
            accessLog.setTakenTime(System.currentTimeMillis() - accessLog.getTakenTime());
            accessLog.setHttpCode(response.getRawStatusCode());
            if (!Utils.isJsonResponse(exchange)) {
                accessLog.setResponse("非 json 报文");
            }
            if (Utils.isDownloadResponse(exchange)) {
                accessLog.setResponse("二进制文件");
            }
            Optional.ofNullable(bytes).ifPresent(bs -> {
                if (bytes.length <= DataSize.ofKilobytes(256).toBytes()) {
                    // 小于指定大小报文进行转化(考虑到文件下载的响应报文)
                    accessLog.setResponse(new String(bytes, StandardCharsets.UTF_8));
                } else {
                    accessLog.setResponse("报文过长");
                }
            });
            logRedisTemplate.opsForStream().add(LogConstant.ACCESS_LOG_KEY_NAME, jackson2HashMapper.toHash(accessLog));
            // 进行修剪，限制其最大长度, 防止内存过高
            logRedisTemplate.opsForStream().trim(LogConstant.ACCESS_LOG_KEY_NAME, LogConstant.ACCESS_LOG_MAX_LENGTH,
                    true);
            if (log.isDebugEnabled()) {
                String logger = objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(accessLog);
                log.debug("log: \n{}", logger);
            }
        } catch (Exception e) {
            log.warn("access log save error: ", e);
        }
    }
}
```
