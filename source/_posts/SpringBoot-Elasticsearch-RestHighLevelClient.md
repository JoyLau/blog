---
title: 重剑无锋,大巧不工 SpringBoot --- 使用 rest-high-level-client 连接 Elasticsearch
date: 2020-04-29 15:02:01
description: SpringBoot 使用 rest-high-level-client 连接 Elasticsearch
categories: [SpringBoot篇]
tags: [SpringBoot,Elasticsearch]
---

<!-- more -->

### 版本环境
1. Elasticsearch 6.4.3
2. SpringBoot 2.1.2.RELEASE

### 引入依赖

```groovy
    compile group: 'org.elasticsearch.client', name: 'elasticsearch-rest-high-level-client', version: '6.4.3'
```

### 配置
其实引入这依赖后, `spring-boot-autoconfigure-2.1.2.RELEASE.jar` 这个依赖你会为你自动配置 `RestHighLevelClient`, 而不需要手动创建 `RestHighLevelClient`

代码具体位置:

org.springframework.boot.autoconfigure.elasticsearch.rest.RestClientAutoConfiguration

```java
    /*
     * Copyright 2012-2018 the original author or authors.
     *
     * Licensed under the Apache License, Version 2.0 (the "License");
     * you may not use this file except in compliance with the License.
     * You may obtain a copy of the License at
     *
     *      http://www.apache.org/licenses/LICENSE-2.0
     *
     * Unless required by applicable law or agreed to in writing, software
     * distributed under the License is distributed on an "AS IS" BASIS,
     * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     * See the License for the specific language governing permissions and
     * limitations under the License.
     */
    
    package org.springframework.boot.autoconfigure.elasticsearch.rest;
    
    import org.apache.http.HttpHost;
    import org.apache.http.auth.AuthScope;
    import org.apache.http.auth.Credentials;
    import org.apache.http.auth.UsernamePasswordCredentials;
    import org.apache.http.client.CredentialsProvider;
    import org.apache.http.impl.client.BasicCredentialsProvider;
    import org.elasticsearch.client.RestClient;
    import org.elasticsearch.client.RestClientBuilder;
    import org.elasticsearch.client.RestHighLevelClient;
    
    import org.springframework.beans.factory.ObjectProvider;
    import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
    import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
    import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
    import org.springframework.boot.context.properties.EnableConfigurationProperties;
    import org.springframework.boot.context.properties.PropertyMapper;
    import org.springframework.context.annotation.Bean;
    import org.springframework.context.annotation.Configuration;
    
    /**
     * {@link EnableAutoConfiguration Auto-configuration} for Elasticsearch REST clients.
     *
     * @author Brian Clozel
     * @since 2.1.0
     */
    @Configuration
    @ConditionalOnClass(RestClient.class)
    @EnableConfigurationProperties(RestClientProperties.class)
    public class RestClientAutoConfiguration {
    
    	private final RestClientProperties properties;
    
    	private final ObjectProvider<RestClientBuilderCustomizer> builderCustomizers;
    
    	public RestClientAutoConfiguration(RestClientProperties properties,
    			ObjectProvider<RestClientBuilderCustomizer> builderCustomizers) {
    		this.properties = properties;
    		this.builderCustomizers = builderCustomizers;
    	}
    
    	@Bean
    	@ConditionalOnMissingBean
    	public RestClient restClient(RestClientBuilder builder) {
    		return builder.build();
    	}
    
    	@Bean
    	@ConditionalOnMissingBean
    	public RestClientBuilder restClientBuilder() {
    		HttpHost[] hosts = this.properties.getUris().stream().map(HttpHost::create)
    				.toArray(HttpHost[]::new);
    		RestClientBuilder builder = RestClient.builder(hosts);
    		PropertyMapper map = PropertyMapper.get();
    		map.from(this.properties::getUsername).whenHasText().to((username) -> {
    			CredentialsProvider credentialsProvider = new BasicCredentialsProvider();
    			Credentials credentials = new UsernamePasswordCredentials(
    					this.properties.getUsername(), this.properties.getPassword());
    			credentialsProvider.setCredentials(AuthScope.ANY, credentials);
    			builder.setHttpClientConfigCallback((httpClientBuilder) -> httpClientBuilder
    					.setDefaultCredentialsProvider(credentialsProvider));
    		});
    		this.builderCustomizers.orderedStream()
    				.forEach((customizer) -> customizer.customize(builder));
    		return builder;
    	}
    
    	@Configuration
    	@ConditionalOnClass(RestHighLevelClient.class)
    	public static class RestHighLevelClientConfiguration {
    
    		@Bean
    		@ConditionalOnMissingBean
    		public RestHighLevelClient restHighLevelClient(
    				RestClientBuilder restClientBuilder) {
    			return new RestHighLevelClient(restClientBuilder);
    		}
    
    	}
    
    }

```

不过需要先配置 spring.elasticsearch.rest 配置

```yaml
    spring:
      elasticsearch:
        rest:
          uris: 
          username: 
          password: 
```


默认只配置了 hosts 和 username password, 如果要加更多配置的话, 建议重新添加 `RestClientBuilder` 的配置

当然也可以全部手动配置, 我这里给一个参考:

```java
    package cn.joylau.code.config.elasticsearch.highLevelClient;
    
    import org.apache.http.HttpHost;
    import org.elasticsearch.client.RestClient;
    import org.elasticsearch.client.RestClientBuilder;
    import org.elasticsearch.client.RestHighLevelClient;
    import org.springframework.beans.factory.annotation.Value;
    import org.springframework.context.annotation.Bean;
    import org.springframework.context.annotation.Configuration;
    
    import java.util.ArrayList;
    import java.util.List;
    
    /**
     * Created by joylau on 2020/4/27.
     * cn.joylau.code.config.elasticsearch.highLevelClient
     * 2587038142.liu@gmail.com
     */
    @Configuration
    public class ElasticSearchClient {
        /** 协议 */
        @Value("${elasticsearch.schema:http}")
        private String schema;
    
        /** 集群地址，如果有多个用“,”隔开 */
        @Value("${elasticsearch.address}")
        private String address;
    
        /** 连接超时时间 */
        @Value("${elasticsearch.connectTimeout:5000}")
        private int connectTimeout;
    
        /** Socket 连接超时时间 */
        @Value("${elasticsearch.socketTimeout:10000}")
        private int socketTimeout;
    
        /** 获取连接的超时时间 */
        @Value("${elasticsearch.connectionRequestTimeout:5000}")
        private int connectionRequestTimeout;
    
        /** 最大连接数 */
        @Value("${elasticsearch.maxConnectNum:100}")
        private int maxConnectNum;
    
        /** 最大路由连接数 */
        @Value("${elasticsearch.maxConnectPerRoute:100}")
        private int maxConnectPerRoute;
    
        @Bean
        public RestHighLevelClient restHighLevelClient() {
            // 拆分地址
            List<HttpHost> hostLists = new ArrayList<>();
            String[] hostList = address.split(",");
            for (String addr : hostList) {
                String host = addr.split(":")[0];
                String port = addr.split(":")[1];
                hostLists.add(new HttpHost(host, Integer.parseInt(port), schema));
            }
            // 转换成 HttpHost 数组
            HttpHost[] httpHost = hostLists.toArray(new HttpHost[]{});
            // 构建连接对象
            RestClientBuilder builder = RestClient.builder(httpHost);
            // 异步连接延时配置
            builder.setRequestConfigCallback(requestConfigBuilder -> {
                requestConfigBuilder.setConnectTimeout(connectTimeout);
                requestConfigBuilder.setSocketTimeout(socketTimeout);
                requestConfigBuilder.setConnectionRequestTimeout(connectionRequestTimeout);
                return requestConfigBuilder;
            });
            // 异步连接数配置
            builder.setHttpClientConfigCallback(httpClientBuilder -> {
                httpClientBuilder.setMaxConnTotal(maxConnectNum);
                httpClientBuilder.setMaxConnPerRoute(maxConnectPerRoute);
                return httpClientBuilder;
            });
            return new RestHighLevelClient(builder);
        }
    }

```

