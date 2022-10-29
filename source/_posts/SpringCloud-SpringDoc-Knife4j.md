---
title: SpringCloud --- OpenApi3 + SpringCloud Gateway 聚合文档 
date: 2022-08-22 18:45:35
description: 记录下 OpenApi3 + SpringCloud Gateway 聚合文档的过程
categories: [SpringCloud篇]
tags: [SpringCloud]
---

<!-- more -->

记录下 OpenApi3 + SpringCloud Gateway 聚合文档的过程

## 组件选型
1. SpringDoc
2. Knife4j
3. SpringCloud Gateway

## 项目配置
在所有的 spring boot 项目中引入 SpringDoc

```xml
   <dependency>
      <groupId>org.springdoc</groupId>
      <artifactId>springdoc-openapi-ui</artifactId>
      <version>${springdoc.version}</version>
   </dependency>
```

在 gateway 项目中引入 SpringDoc

```xml
   <dependency>
      <groupId>org.springdoc</groupId>
      <artifactId>springdoc-openapi-webflux-ui</artifactId>
      <version>${springdoc.version}</version>
   </dependency>
```

并且需要排除 springdoc-openapi-ui 的依赖

## OpenAPI 配置
```java
    @Configuration
    @AllArgsConstructor
    public class SwaggerConfiguration {
        private final Environment environment;
    
        @Bean
        public OpenAPI openAPI() {
            return new OpenAPI()
                    .info(info());
        }
    
        private Info info() {
            return new Info()
                    .title("xxxx")
                    .description(environment.getProperty("spring.application.name") + " 服务 API 文档")
                    .version("xx")
                    .contact(new Contact().name("xxx").url("xxx").email("xxxxx"))
                    .summary("OpenAPI 文档");
        }
    }
```

## 文档聚合
聚合 swagger 添加分组

```java
    @Component
    @AllArgsConstructor
    public class SwaggerConfig {
        public static final String MODULE_SUB_PREFIX = "ReactiveCompositeDiscoveryClient_";
    
        private final SwaggerUiConfigParameters swaggerUiConfigParameters;
    
        private final RouteLocator routeLocator;
    
        @Scheduled(fixedDelay = 20000)
        public void apis() {
            swaggerUiConfigParameters.getUrls().clear();
            routeLocator.getRoutes().subscribe(routeDefinition -> {
                if (routeDefinition.getId().contains(MODULE_SUB_PREFIX)) {
                    String name = routeDefinition.getId().substring(MODULE_SUB_PREFIX.length());
                    swaggerUiConfigParameters.addGroup(name);
                }
            });
        }
    }
```

修改 /v3/api-docs/ 报文添加 basePath 使得 Knife4j 在聚合文档下能正常调试

```java
    @Component
    public class AddBasePathFilterFactory extends AbstractGatewayFilterFactory<AddBasePathFilterFactory.Config> {
    
        private final ModifyResponseBodyGatewayFilterFactory modifyResponseBodyGatewayFilterFactory;
    
        public AddBasePathFilterFactory(ModifyResponseBodyGatewayFilterFactory modifyResponseBodyGatewayFilterFactory) {
            super(Config.class);
            this.modifyResponseBodyGatewayFilterFactory = modifyResponseBodyGatewayFilterFactory;
        }
    
        @Override
        public GatewayFilter apply(Config config) {
            ModifyResponseBodyGatewayFilterFactory.Config cf = new ModifyResponseBodyGatewayFilterFactory.Config()
                    .setRewriteFunction(JsonNode.class, JsonNode.class,
                            (e, jsonNode) -> Mono.justOrEmpty(addBasePath(e, jsonNode)));
            return modifyResponseBodyGatewayFilterFactory.apply(cf);
        }
    
        @Override
        public String name() {
            return "AddBasePath";
        }
    
        @Setter
        public static class Config {
        }
    
        private JsonNode addBasePath(ServerWebExchange exchange, JsonNode jsonNode) {
            if (jsonNode.isObject()) {
                ObjectNode node = (ObjectNode) jsonNode;
                String basePath = exchange.getRequest().getPath().subPath(4).value();
                node.put("basePath", basePath);
                return node;
            }
            return jsonNode;
        }
    }
```

## 网关路由配置
```yaml
  spring:
    cloud:
      gateway:
        routes:
          # openapi /v3/api-docs/组名 转 /组名/v3/api-docs； 再加 basePath 属性
          - id: openapi
            uri: http://localhost:${server.port}
            predicates:
              - Path=/v3/api-docs/**
            filters:
              - RewritePath=/v3/api-docs/(?<path>.*), /$\{path}/v3/api-docs
              - AddBasePath
          # 主页面重定向到文档聚合页面
          - id: doc
            uri: http://localhost:${server.port}
            predicates:
              - Path=/
            filters:
              - RedirectTo=302, /doc.html
```

