---
title: 重剑无锋,大巧不工 SpringBoot --- Elasticsearch health check failed
date: 2019-01-16 17:24:38
description: springboot 使用 actuator 造成 elasticsearch health check failed
categories: [SpringBoot篇]
tags: [SpringBoot,Elasticsearch]
---

<!-- more -->

### 版本环境
1. spring boot : 2.1.2.RELEASE
2. spring-data-elasticsearch :3.1.4.RELEASE
3. elasticsearch: 6.4.3

### 问题描述
使用 spring data elasticsearch 来连接使用 elasticsearch, 配置如下:

``` yaml
    spring:
      data:
        elasticsearch:
          cluster-name: docker-cluster
          cluster-nodes: 192.168.10.68:9300
```

已经确认 elasticsearch 的 9300 和 9200 端口无任何问题,均可进行连接

可是在启动项目是报出如下错误:

``` bash
    2019-01-16 17:17:35.376  INFO 36410 --- [           main] o.elasticsearch.plugins.PluginsService   : no modules loaded
    2019-01-16 17:17:35.378  INFO 36410 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.index.reindex.ReindexPlugin]
    2019-01-16 17:17:35.378  INFO 36410 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.join.ParentJoinPlugin]
    2019-01-16 17:17:35.378  INFO 36410 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.percolator.PercolatorPlugin]
    2019-01-16 17:17:35.378  INFO 36410 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.script.mustache.MustachePlugin]
    2019-01-16 17:17:35.378  INFO 36410 --- [           main] o.elasticsearch.plugins.PluginsService   : loaded plugin [org.elasticsearch.transport.Netty4Plugin]
    2019-01-16 17:17:36.045  INFO 36410 --- [           main] o.s.d.e.c.TransportClientFactoryBean     : Adding transport node : 192.168.10.68:9300
    2019-01-16 17:17:36.740  INFO 36410 --- [           main] o.s.s.concurrent.ThreadPoolTaskExecutor  : Initializing ExecutorService 'applicationTaskExecutor'
    2019-01-16 17:17:36.987  INFO 36410 --- [           main] o.s.b.a.e.web.EndpointLinksResolver      : Exposing 15 endpoint(s) beneath base path '/actuator'
    2019-01-16 17:17:37.041  INFO 36410 --- [           main] org.xnio                                 : XNIO version 3.3.8.Final
    2019-01-16 17:17:37.049  INFO 36410 --- [           main] org.xnio.nio                             : XNIO NIO Implementation Version 3.3.8.Final
    2019-01-16 17:17:37.091  INFO 36410 --- [           main] o.s.b.w.e.u.UndertowServletWebServer     : Undertow started on port(s) 8080 (http) with context path ''
    2019-01-16 17:17:37.094  INFO 36410 --- [           main] cn.joylau.code.EsDocOfficeApplication    : Started EsDocOfficeApplication in 3.517 seconds (JVM running for 4.124)
    2019-01-16 17:17:37.641  INFO 36410 --- [on(4)-127.0.0.1] io.undertow.servlet                      : Initializing Spring DispatcherServlet 'dispatcherServlet'
    2019-01-16 17:17:37.641  INFO 36410 --- [on(4)-127.0.0.1] o.s.web.servlet.DispatcherServlet        : Initializing Servlet 'dispatcherServlet'
    2019-01-16 17:17:37.660  INFO 36410 --- [on(4)-127.0.0.1] o.s.web.servlet.DispatcherServlet        : Completed initialization in 19 ms
    2019-01-16 17:17:37.704  WARN 36410 --- [on(5)-127.0.0.1] s.b.a.e.ElasticsearchRestHealthIndicator : Elasticsearch health check failed
    
    java.net.ConnectException: Connection refused
    	at org.elasticsearch.client.RestClient$SyncResponseListener.get(RestClient.java:943) ~[elasticsearch-rest-client-6.4.3.jar:6.4.3]
    	at org.elasticsearch.client.RestClient.performRequest(RestClient.java:227) ~[elasticsearch-rest-client-6.4.3.jar:6.4.3]
    	at org.springframework.boot.actuate.elasticsearch.ElasticsearchRestHealthIndicator.doHealthCheck(ElasticsearchRestHealthIndicator.java:61) ~[spring-boot-actuator-2.1.2.RELEASE.jar:2.1.2.RELEASE]
    	at org.springframework.boot.actuate.health.AbstractHealthIndicator.health(AbstractHealthIndicator.java:84) ~[spring-boot-actuator-2.1.2.RELEASE.jar:2.1.2.RELEASE]
    	at org.springframework.boot.actuate.health.CompositeHealthIndicator.health(CompositeHealthIndicator.java:98) [spring-boot-actuator-2.1.2.RELEASE.jar:2.1.2.RELEASE]
    	at org.springframework.boot.actuate.health.HealthEndpoint.health(HealthEndpoint.java:50) [spring-boot-actuator-2.1.2.RELEASE.jar:2.1.2.RELEASE]
    	at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method) ~[na:1.8.0_131]
    	at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62) ~[na:1.8.0_131]
    	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43) ~[na:1.8.0_131]
    	at java.lang.reflect.Method.invoke(Method.java:498) ~[na:1.8.0_131]
    	at org.springframework.util.ReflectionUtils.invokeMethod(ReflectionUtils.java:246) [spring-core-5.1.4.RELEASE.jar:5.1.4.RELEASE]
    	at org.springframework.boot.actuate.endpoint.invoke.reflect.ReflectiveOperationInvoker.invoke(ReflectiveOperationInvoker.java:76) [spring-boot-actuator-2.1.2.RELEASE.jar:2.1.2.RELEASE]
    	at org.springframework.boot.actuate.endpoint.annotation.AbstractDiscoveredOperation.invoke(AbstractDiscoveredOperation.java:61) [spring-boot-actuator-2.1.2.RELEASE.jar:2.1.2.RELEASE]
    	at org.springframework.boot.actuate.endpoint.jmx.EndpointMBean.invoke(EndpointMBean.java:126) [spring-boot-actuator-2.1.2.RELEASE.jar:2.1.2.RELEASE]
    	at org.springframework.boot.actuate.endpoint.jmx.EndpointMBean.invoke(EndpointMBean.java:99) [spring-boot-actuator-2.1.2.RELEASE.jar:2.1.2.RELEASE]
    	at com.sun.jmx.interceptor.DefaultMBeanServerInterceptor.invoke(DefaultMBeanServerInterceptor.java:819) [na:1.8.0_131]
    	at com.sun.jmx.mbeanserver.JmxMBeanServer.invoke(JmxMBeanServer.java:801) [na:1.8.0_131]
    	at javax.management.remote.rmi.RMIConnectionImpl.doOperation(RMIConnectionImpl.java:1468) [na:1.8.0_131]
    	at javax.management.remote.rmi.RMIConnectionImpl.access$300(RMIConnectionImpl.java:76) [na:1.8.0_131]
    	at javax.management.remote.rmi.RMIConnectionImpl$PrivilegedOperation.run(RMIConnectionImpl.java:1309) [na:1.8.0_131]
    	at javax.management.remote.rmi.RMIConnectionImpl.doPrivilegedOperation(RMIConnectionImpl.java:1401) [na:1.8.0_131]
    	at javax.management.remote.rmi.RMIConnectionImpl.invoke(RMIConnectionImpl.java:829) [na:1.8.0_131]
    	at sun.reflect.GeneratedMethodAccessor32.invoke(Unknown Source) ~[na:na]
    	at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43) ~[na:1.8.0_131]
    	at java.lang.reflect.Method.invoke(Method.java:498) ~[na:1.8.0_131]
    	at sun.rmi.server.UnicastServerRef.dispatch(UnicastServerRef.java:346) [na:1.8.0_131]
    	at sun.rmi.transport.Transport$1.run(Transport.java:200) [na:1.8.0_131]
    	at sun.rmi.transport.Transport$1.run(Transport.java:197) [na:1.8.0_131]
    	at java.security.AccessController.doPrivileged(Native Method) [na:1.8.0_131]
    	at sun.rmi.transport.Transport.serviceCall(Transport.java:196) [na:1.8.0_131]
    	at sun.rmi.transport.tcp.TCPTransport.handleMessages(TCPTransport.java:568) [na:1.8.0_131]
    	at sun.rmi.transport.tcp.TCPTransport$ConnectionHandler.run0(TCPTransport.java:826) [na:1.8.0_131]
    	at sun.rmi.transport.tcp.TCPTransport$ConnectionHandler.lambda$run$0(TCPTransport.java:683) [na:1.8.0_131]
    	at java.security.AccessController.doPrivileged(Native Method) [na:1.8.0_131]
    	at sun.rmi.transport.tcp.TCPTransport$ConnectionHandler.run(TCPTransport.java:682) [na:1.8.0_131]
    	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142) ~[na:1.8.0_131]
    	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617) ~[na:1.8.0_131]
    	at java.lang.Thread.run(Thread.java:748) ~[na:1.8.0_131]
    Caused by: java.net.ConnectException: Connection refused
    	at sun.nio.ch.SocketChannelImpl.checkConnect(Native Method) ~[na:1.8.0_131]
    	at sun.nio.ch.SocketChannelImpl.finishConnect(SocketChannelImpl.java:717) ~[na:1.8.0_131]
    	at org.apache.http.impl.nio.reactor.DefaultConnectingIOReactor.processEvent(DefaultConnectingIOReactor.java:171) ~[httpcore-nio-4.4.10.jar:4.4.10]
    	at org.apache.http.impl.nio.reactor.DefaultConnectingIOReactor.processEvents(DefaultConnectingIOReactor.java:145) ~[httpcore-nio-4.4.10.jar:4.4.10]
    	at org.apache.http.impl.nio.reactor.AbstractMultiworkerIOReactor.execute(AbstractMultiworkerIOReactor.java:348) ~[httpcore-nio-4.4.10.jar:4.4.10]
    	at org.apache.http.impl.nio.conn.PoolingNHttpClientConnectionManager.execute(PoolingNHttpClientConnectionManager.java:221) ~[httpasyncclient-4.1.4.jar:4.1.4]
    	at org.apache.http.impl.nio.client.CloseableHttpAsyncClientBase$1.run(CloseableHttpAsyncClientBase.java:64) ~[httpasyncclient-4.1.4.jar:4.1.4]
    	... 1 common frames omitted
    

```

连接被拒绝???

发现无法进行 elasticsearch 的健康检查,于是想到我使用了 actuator 进行端点健康监控

经过调试发现如下代码为返回数据:
ElasticsearchRestHealthIndicator 类中

``` java
    	@Override
    	protected void doHealthCheck(Health.Builder builder) throws Exception {
    		Response response = this.client
    				.performRequest(new Request("GET", "/_cluster/health/"));
    		StatusLine statusLine = response.getStatusLine();
    		if (statusLine.getStatusCode() != HttpStatus.SC_OK) {
    			builder.down();
    			builder.withDetail("statusCode", statusLine.getStatusCode());
    			builder.withDetail("reasonPhrase", statusLine.getReasonPhrase());
    			return;
    		}
    		try (InputStream inputStream = response.getEntity().getContent()) {
    			doHealthCheck(builder,
    					StreamUtils.copyToString(inputStream, StandardCharsets.UTF_8));
    		}
    	}
```

`new Request("GET", "/_cluster/health/")` 正是 elasticsearch 健康的请求,但是没有看到 host 和 port

于是用抓包工具发现其请求的是 `127.0.0.1:9200`

那这肯定是 springboot 的默认配置了

### 问题解决
查看 `spring-boot-autoconfigure-2.1.2.RELEASE.jar`
找到 elasticsearch 的配置 `org.springframework.boot.autoconfigure.elasticsearch`
在找到类 `RestClientProperties`
看到如下源码:

``` java
    @ConfigurationProperties(prefix = "spring.elasticsearch.rest")
    public class RestClientProperties {
    
    	/**
    	 * Comma-separated list of the Elasticsearch instances to use.
    	 */
    	private List<String> uris = new ArrayList<>(
    			Collections.singletonList("http://localhost:9200"));
    
    	/**
    	 * Credentials username.
    	 */
    	private String username;
    
    	/**
    	 * Credentials password.
    	 */
    	private String password;
    
    	public List<String> getUris() {
    		return this.uris;
    	}
    
    	public void setUris(List<String> uris) {
    		this.uris = uris;
    	}
    
    	public String getUsername() {
    		return this.username;
    	}
    
    	public void setUsername(String username) {
    		this.username = username;
    	}
    
    	public String getPassword() {
    		return this.password;
    	}
    
    	public void setPassword(String password) {
    		this.password = password;
    	}
    
    }
```

`Collections.singletonList("http://localhost:9200"));` 没错了,这就是错误的起因

顺藤摸瓜, 根据 `spring.elasticsearch.rest` 的配置,配置好 `uris` 即可

于是进行如下配置:

``` yaml
    spring:
      data:
        elasticsearch:
          cluster-name: docker-cluster
          cluster-nodes: 192.168.10.68:9300
      elasticsearch:
        rest:
          uris: ["http://192.168.10.68:9200"]
```

集群中的多个节点就写多个

启动,没有出现错误


还有一种方式也可以解决,但是并不是一种好的解决方式,那就是关闭 actuator 对 elasticsearch 的健康检查

``` yaml
    management:
      health:
        elasticsearch:
          enabled: false
```

