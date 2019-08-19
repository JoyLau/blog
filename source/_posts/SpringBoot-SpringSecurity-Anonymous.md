---
title: Spring Security 禁用匿名用户（anonymous().disable()）后无限重定向到登录页的问题解决
date: 2019-08-19 15:06:48
description: 最近做了一个小 demo，需要使用到 spring security，于是就把以前写过的 spring security 的代码直接 copy 过来用了，没想到却出现了问题.....
categories: [SpringSecurity篇]
tags: [SpringSecurity,SpringBoot]
---

<!-- more -->
## 背景
最近做了一个小 demo，需要使用到 spring security，于是就把以前写过的 spring security 的代码直接 copy 过来用了，没想到却出现了问题.....

## 问题
小 demo 直接使用 spring boot 构建，前后端不分离，于是自己写的登录界面，在 spring security 里配置好 loginPage 后，发现只要打开登录页就会无限重定向到登录页，其他任何请求都是如此

## 配置

```java
    @Configuration
    @EnableWebSecurity
    public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http
                    .anonymous().disable()
                    .csrf().disable()
                    .authorizeRequests()
                    .antMatchers("/").permitAll()
                    .anyRequest().authenticated()//其他请求必须授权后访问
                    .and()
                    .formLogin()
                    .loginPage("/")
                    .loginProcessingUrl("/login")
                    .permitAll();//登录请求可以直接访问
        }
    
        @Override
        public void configure(AuthenticationManagerBuilder auth) throws Exception {
            auth.inMemoryAuthentication().passwordEncoder(passwordEncoder()).withUser("admin").password(passwordEncoder().encode("123456")).roles("ADMIN");
        }
    
        @Bean
        public SessionRegistry sessionRegistry(){
            return new SessionRegistryImpl();
        }
    
        @Bean
        public BCryptPasswordEncoder passwordEncoder() {
            return new BCryptPasswordEncoder();
        }
    
    
        @Bean
        public AuthenticationSuccess authenticationSuccessHandler(){
            return new AuthenticationSuccess();
        }
    
        @Bean
        public AuthenticationFailureHandler authenticationFailureHandler(){
            return new AuthenticationFailure();
        }
    }
```

## 分析
一开始的直觉告诉我，登录页的请求 **"/"** 没有认证，而没有认证的请求会重定向到登录页，也就还是 **"/"**,于是就造成了重定向

于是我先添加请求 **"/"**, 不进行认证即可访问，也就是上面配置的 `.antMatchers("/").permitAll()`

重启后发现不起作用，依旧无限重定向

然而可怕的是控制台没有打印任何日志....

一下子懵逼了，不知如何解决....

冷静下来分析后---

我是这样解决的

### 打开 debug 日志
配置 spring security 的日志级别

```yaml
    logging:
      level:
        org.springframework.security: debug
```

启动时看到日志截取如下

```text
    2019-08-19 15:19:06.628 DEBUG 19133 --- [           main] edFilterInvocationSecurityMetadataSource : Adding web access control expression 'permitAll', for ExactUrl [processUrl='/?error']
    2019-08-19 15:19:06.631 DEBUG 19133 --- [           main] edFilterInvocationSecurityMetadataSource : Adding web access control expression 'permitAll', for ExactUrl [processUrl='/login']
    2019-08-19 15:19:06.631 DEBUG 19133 --- [           main] edFilterInvocationSecurityMetadataSource : Adding web access control expression 'permitAll', for ExactUrl [processUrl='/']
    2019-08-19 15:19:06.631 DEBUG 19133 --- [           main] edFilterInvocationSecurityMetadataSource : Adding web access control expression 'permitAll', for Ant [pattern='/']
    2019-08-19 15:19:06.632 DEBUG 19133 --- [           main] edFilterInvocationSecurityMetadataSource : Adding web access control expression 'authenticated', for any request
    2019-08-19 15:19:06.646 DEBUG 19133 --- [           main] o.s.s.w.a.i.FilterSecurityInterceptor    : Validated configuration attributes
    2019-08-19 15:19:06.648 DEBUG 19133 --- [           main] o.s.s.w.a.i.FilterSecurityInterceptor    : Validated configuration attributes
    
    2019-08-19 15:34:24.451  INFO 22575 --- [           main] o.s.s.web.DefaultSecurityFilterChain     : Creating filter chain: any request, [org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter@32c6d164, org.springframework.security.web.context.SecurityContextPersistenceFilter@390a7532, org.springframework.security.web.header.HeaderWriterFilter@5ebf776c, org.springframework.security.web.authentication.logout.LogoutFilter@523ade68, org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter@652f26da, org.springframework.security.web.savedrequest.RequestCacheAwareFilter@7d49a1a0, org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter@3a12f3e7, org.springframework.security.web.session.SessionManagementFilter@54ae1240, org.springframework.security.web.access.ExceptionTranslationFilter@3c62f69a, org.springframework.security.web.access.intercept.FilterSecurityInterceptor@2b3242a5]
```

可以看到 **"/"** 添加成功了，可是为什么好像没有生效呢？

### 错误信息
继续往下走，刷新登录页，发现控制台打印了错误信息如下“

```text
    2019-08-19 15:21:16.813 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 1 of 10 in additional filter chain; firing Filter: 'WebAsyncManagerIntegrationFilter'
    2019-08-19 15:21:16.815 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 2 of 10 in additional filter chain; firing Filter: 'SecurityContextPersistenceFilter'
    2019-08-19 15:21:16.816 DEBUG 19133 --- [nio-8080-exec-2] w.c.HttpSessionSecurityContextRepository : No HttpSession currently exists
    2019-08-19 15:21:16.817 DEBUG 19133 --- [nio-8080-exec-2] w.c.HttpSessionSecurityContextRepository : No SecurityContext was available from the HttpSession: null. A new one will be created.
    2019-08-19 15:21:16.822 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 3 of 10 in additional filter chain; firing Filter: 'HeaderWriterFilter'
    2019-08-19 15:21:16.825 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 4 of 10 in additional filter chain; firing Filter: 'LogoutFilter'
    2019-08-19 15:21:16.825 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.web.util.matcher.OrRequestMatcher  : Trying to match using Ant [pattern='/logout', GET]
    2019-08-19 15:21:16.825 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.w.u.matcher.AntPathRequestMatcher  : Checking match of request : '/'; against '/logout'
    2019-08-19 15:21:16.826 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.web.util.matcher.OrRequestMatcher  : Trying to match using Ant [pattern='/logout', POST]
    2019-08-19 15:21:16.826 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.w.u.matcher.AntPathRequestMatcher  : Request 'GET /' doesn't match 'POST /logout'
    2019-08-19 15:21:16.826 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.web.util.matcher.OrRequestMatcher  : Trying to match using Ant [pattern='/logout', PUT]
    2019-08-19 15:21:16.826 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.w.u.matcher.AntPathRequestMatcher  : Request 'GET /' doesn't match 'PUT /logout'
    2019-08-19 15:21:16.826 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.web.util.matcher.OrRequestMatcher  : Trying to match using Ant [pattern='/logout', DELETE]
    2019-08-19 15:21:16.827 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.w.u.matcher.AntPathRequestMatcher  : Request 'GET /' doesn't match 'DELETE /logout'
    2019-08-19 15:21:16.827 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.web.util.matcher.OrRequestMatcher  : No matches found
    2019-08-19 15:21:16.827 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 5 of 10 in additional filter chain; firing Filter: 'UsernamePasswordAuthenticationFilter'
    2019-08-19 15:21:16.827 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.w.u.matcher.AntPathRequestMatcher  : Request 'GET /' doesn't match 'POST /login'
    2019-08-19 15:21:16.828 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 6 of 10 in additional filter chain; firing Filter: 'RequestCacheAwareFilter'
    2019-08-19 15:21:16.828 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.w.s.HttpSessionRequestCache        : saved request doesn't match
    2019-08-19 15:21:16.829 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 7 of 10 in additional filter chain; firing Filter: 'SecurityContextHolderAwareRequestFilter'
    2019-08-19 15:21:16.832 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 8 of 10 in additional filter chain; firing Filter: 'SessionManagementFilter'
    2019-08-19 15:21:16.833 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 9 of 10 in additional filter chain; firing Filter: 'ExceptionTranslationFilter'
    2019-08-19 15:21:21.085 DEBUG 19133 --- [nio-8080-exec-2] o.s.security.web.FilterChainProxy        : / at position 10 of 10 in additional filter chain; firing Filter: 'FilterSecurityInterceptor'
    2019-08-19 15:21:21.440 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.w.a.i.FilterSecurityInterceptor    : Secure object: FilterInvocation: URL: /; Attributes: [permitAll]
    2019-08-19 15:21:21.450 DEBUG 19133 --- [nio-8080-exec-2] o.s.s.w.a.ExceptionTranslationFilter     : Authentication exception occurred; redirecting to authentication entry point
    
    org.springframework.security.authentication.AuthenticationCredentialsNotFoundException: An Authentication object was not found in the SecurityContext
    	at org.springframework.security.access.intercept.AbstractSecurityInterceptor.credentialsNotFound(AbstractSecurityInterceptor.java:379) ~[spring-security-core-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.access.intercept.AbstractSecurityInterceptor.beforeInvocation(AbstractSecurityInterceptor.java:223) ~[spring-security-core-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.access.intercept.FilterSecurityInterceptor.invoke(FilterSecurityInterceptor.java:124) ~[spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.access.intercept.FilterSecurityInterceptor.doFilter(FilterSecurityInterceptor.java:91) ~[spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.access.ExceptionTranslationFilter.doFilter(ExceptionTranslationFilter.java:119) ~[spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.session.SessionManagementFilter.doFilter(SessionManagementFilter.java:137) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.servletapi.SecurityContextHolderAwareRequestFilter.doFilter(SecurityContextHolderAwareRequestFilter.java:170) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.savedrequest.RequestCacheAwareFilter.doFilter(RequestCacheAwareFilter.java:63) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter.doFilter(AbstractAuthenticationProcessingFilter.java:200) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.authentication.logout.LogoutFilter.doFilter(LogoutFilter.java:116) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.header.HeaderWriterFilter.doFilterInternal(HeaderWriterFilter.java:74) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:118) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.context.SecurityContextPersistenceFilter.doFilter(SecurityContextPersistenceFilter.java:105) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.context.request.async.WebAsyncManagerIntegrationFilter.doFilterInternal(WebAsyncManagerIntegrationFilter.java:56) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:118) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:334) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy.doFilterInternal(FilterChainProxy.java:215) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.security.web.FilterChainProxy.doFilter(FilterChainProxy.java:178) [spring-security-web-5.1.6.RELEASE.jar:5.1.6.RELEASE]
    	at org.springframework.web.filter.DelegatingFilterProxy.invokeDelegate(DelegatingFilterProxy.java:357) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.springframework.web.filter.DelegatingFilterProxy.doFilter(DelegatingFilterProxy.java:270) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.springframework.web.filter.RequestContextFilter.doFilterInternal(RequestContextFilter.java:99) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:118) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.springframework.web.filter.FormContentFilter.doFilterInternal(FormContentFilter.java:92) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:118) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.springframework.web.filter.HiddenHttpMethodFilter.doFilterInternal(HiddenHttpMethodFilter.java:93) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:118) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.springframework.web.filter.CharacterEncodingFilter.doFilterInternal(CharacterEncodingFilter.java:200) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:118) [spring-web-5.1.9.RELEASE.jar:5.1.9.RELEASE]
    	at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:193) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:166) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.StandardWrapperValve.invoke(StandardWrapperValve.java:202) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.StandardContextValve.__invoke(StandardContextValve.java:96) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.StandardContextValve.invoke(StandardContextValve.java:41002) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.authenticator.AuthenticatorBase.invoke(AuthenticatorBase.java:490) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.StandardHostValve.invoke(StandardHostValve.java:139) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.valves.ErrorReportValve.invoke(ErrorReportValve.java:92) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.core.StandardEngineValve.invoke(StandardEngineValve.java:74) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.catalina.connector.CoyoteAdapter.service(CoyoteAdapter.java:343) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.coyote.http11.Http11Processor.service(Http11Processor.java:408) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.coyote.AbstractProcessorLight.process(AbstractProcessorLight.java:66) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.coyote.AbstractProtocol$ConnectionHandler.process(AbstractProtocol.java:853) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.tomcat.util.net.NioEndpoint$SocketProcessor.doRun(NioEndpoint.java:1587) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at org.apache.tomcat.util.net.SocketProcessorBase.run(SocketProcessorBase.java:49) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1135) [na:na]
    	at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:635) [na:na]
    	at org.apache.tomcat.util.threads.TaskThread$WrappingRunnable.run(TaskThread.java:61) [tomcat-embed-core-9.0.22.jar:9.0.22]
    	at java.base/java.lang.Thread.run(Thread.java:844) [na:na]
```

看到2个关键的错误信息：
1. **Authentication exception occurred; redirecting to authentication entry point**
2. **An Authentication object was not found in the SecurityContext**

意思是认证异常，重定向到认证入口点，异常的原因是在 SecurityContext 没有找到认证信息对象

### 排查
根据错误信息，我先到 `ExceptionTranslationFilter` 类中去查看问题出在什么地方

``` java
   public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
   			throws IOException, ServletException {
   		HttpServletRequest request = (HttpServletRequest) req;
   		HttpServletResponse response = (HttpServletResponse) res;
   
   		try {
   			chain.doFilter(request, response);
   
   			logger.debug("Chain processed normally");
   		}
   		catch (IOException ex) {
   			throw ex;
   		}
   		catch (Exception ex) {
   			// Try to extract a SpringSecurityException from the stacktrace
   			Throwable[] causeChain = throwableAnalyzer.determineCauseChain(ex);
   			RuntimeException ase = (AuthenticationException) throwableAnalyzer
   					.getFirstThrowableOfType(AuthenticationException.class, causeChain);
   
   			if (ase == null) {
   				ase = (AccessDeniedException) throwableAnalyzer.getFirstThrowableOfType(
   						AccessDeniedException.class, causeChain);
   			}
   
   			if (ase != null) {
   				if (response.isCommitted()) {
   					throw new ServletException("Unable to handle the Spring Security Exception because the response is already committed.", ex);
   				}
   				handleSpringSecurityException(request, response, chain, ase);
   			}
   			else {
   				// Rethrow ServletExceptions and RuntimeExceptions as-is
   				if (ex instanceof ServletException) {
   					throw (ServletException) ex;
   				}
   				else if (ex instanceof RuntimeException) {
   					throw (RuntimeException) ex;
   				}
   
   				// Wrap other Exceptions. This shouldn't actually happen
   				// as we've already covered all the possibilities for doFilter
   				throw new RuntimeException(ex);
   			}
   		}
   	} 
```

ExceptionTranslationFilter 没有什么逻辑，都是对异常的处理， 然后直接进入下一个过滤器了，

那么这时我们就需要了解 spring security 的过滤器链的顺序

我们来看最开始打印的 debug 的日志信息，我整理一下，有如下顺序：

**WebAsyncManagerIntegrationFilter**
**SecurityContextPersistenceFilter**
**HeaderWriterFilter**
**LogoutFilter**
**UsernamePasswordAuthenticationFilter**
**RequestCacheAwareFilter**
**SecurityContextHolderAwareRequestFilter**
**SessionManagementFilter**
**ExceptionTranslationFilter**
**FilterSecurityInterceptor**

这是spring security 的默认过滤器链，完整的过滤器链可以通过查看源码详细看到， 在类 FilterComparator 中：

``` java
    FilterComparator() {
    		Step order = new Step(INITIAL_ORDER, ORDER_STEP);
    		put(ChannelProcessingFilter.class, order.next());
    		put(ConcurrentSessionFilter.class, order.next());
    		put(WebAsyncManagerIntegrationFilter.class, order.next());
    		put(SecurityContextPersistenceFilter.class, order.next());
    		put(HeaderWriterFilter.class, order.next());
    		put(CorsFilter.class, order.next());
    		put(CsrfFilter.class, order.next());
    		put(LogoutFilter.class, order.next());
    		filterToOrder.put(
    			"org.springframework.security.oauth2.client.web.OAuth2AuthorizationRequestRedirectFilter",
    				order.next());
    		put(X509AuthenticationFilter.class, order.next());
    		put(AbstractPreAuthenticatedProcessingFilter.class, order.next());
    		filterToOrder.put("org.springframework.security.cas.web.CasAuthenticationFilter",
    				order.next());
    		filterToOrder.put(
    			"org.springframework.security.oauth2.client.web.OAuth2LoginAuthenticationFilter",
    				order.next());
    		put(UsernamePasswordAuthenticationFilter.class, order.next());
    		put(ConcurrentSessionFilter.class, order.next());
    		filterToOrder.put(
    				"org.springframework.security.openid.OpenIDAuthenticationFilter", order.next());
    		put(DefaultLoginPageGeneratingFilter.class, order.next());
    		put(DefaultLogoutPageGeneratingFilter.class, order.next());
    		put(ConcurrentSessionFilter.class, order.next());
    		put(DigestAuthenticationFilter.class, order.next());
    		filterToOrder.put(
    				"org.springframework.security.oauth2.server.resource.web.BearerTokenAuthenticationFilter", order.next());
    		put(BasicAuthenticationFilter.class, order.next());
    		put(RequestCacheAwareFilter.class, order.next());
    		put(SecurityContextHolderAwareRequestFilter.class, order.next());
    		put(JaasApiIntegrationFilter.class, order.next());
    		put(RememberMeAuthenticationFilter.class, order.next());
    		put(AnonymousAuthenticationFilter.class, order.next());
    		filterToOrder.put(
    			"org.springframework.security.oauth2.client.web.OAuth2AuthorizationCodeGrantFilter",
    				order.next());
    		put(SessionManagementFilter.class, order.next());
    		put(ExceptionTranslationFilter.class, order.next());
    		put(FilterSecurityInterceptor.class, order.next());
    		put(SwitchUserFilter.class, order.next());
    	}
```

回到原来的问题， `ExceptionTranslationFilter` 过滤器后是 `FilterSecurityInterceptor` 过滤器

再来看 `FilterSecurityInterceptor` 的源码

``` java
    public void doFilter(ServletRequest request, ServletResponse response,
            FilterChain chain) throws IOException, ServletException {
        FilterInvocation fi = new FilterInvocation(request, response, chain);
        invoke(fi);
    }
    
    public void invoke(FilterInvocation fi) throws IOException, ServletException {
    		if ((fi.getRequest() != null)
    				&& (fi.getRequest().getAttribute(FILTER_APPLIED) != null)
    				&& observeOncePerRequest) {
    			// filter already applied to this request and user wants us to observe
    			// once-per-request handling, so don't re-do security checking
    			fi.getChain().doFilter(fi.getRequest(), fi.getResponse());
    		}
    		else {
    			// first time this request being called, so perform security checking
    			if (fi.getRequest() != null && observeOncePerRequest) {
    				fi.getRequest().setAttribute(FILTER_APPLIED, Boolean.TRUE);
    			}
    
    			InterceptorStatusToken token = super.beforeInvocation(fi);
    
    			try {
    				fi.getChain().doFilter(fi.getRequest(), fi.getResponse());
    			}
    			finally {
    				super.finallyInvocation(token);
    			}
    
    			super.afterInvocation(token, null);
    		}
    	}
```

这里的看的主要方法是 `invoke（fi）`

通过调试看到， 问题出在 beforeInvocation（fi） 方法里：

``` java
    protected InterceptorStatusToken beforeInvocation(Object object) {
    		Assert.notNull(object, "Object was null");
    		final boolean debug = logger.isDebugEnabled();
    
    		if (!getSecureObjectClass().isAssignableFrom(object.getClass())) {
    			throw new IllegalArgumentException(
    					"Security invocation attempted for object "
    							+ object.getClass().getName()
    							+ " but AbstractSecurityInterceptor only configured to support secure objects of type: "
    							+ getSecureObjectClass());
    		}
    
    		Collection<ConfigAttribute> attributes = this.obtainSecurityMetadataSource()
    				.getAttributes(object);
    
    		if (attributes == null || attributes.isEmpty()) {
    			if (rejectPublicInvocations) {
    				throw new IllegalArgumentException(
    						"Secure object invocation "
    								+ object
    								+ " was denied as public invocations are not allowed via this interceptor. "
    								+ "This indicates a configuration error because the "
    								+ "rejectPublicInvocations property is set to 'true'");
    			}
    
    			if (debug) {
    				logger.debug("Public object - authentication not attempted");
    			}
    
    			publishEvent(new PublicInvocationEvent(object));
    
    			return null; // no further work post-invocation
    		}
    
    		if (debug) {
    			logger.debug("Secure object: " + object + "; Attributes: " + attributes);
    		}
    
    		if (SecurityContextHolder.getContext().getAuthentication() == null) {
    			credentialsNotFound(messages.getMessage(
    					"AbstractSecurityInterceptor.authenticationNotFound",
    					"An Authentication object was not found in the SecurityContext"),
    					object, attributes);
    		}
    
    		Authentication authenticated = authenticateIfRequired();
    
    		// Attempt authorization
    		try {
    			this.accessDecisionManager.decide(authenticated, object, attributes);
    		}
    		catch (AccessDeniedException accessDeniedException) {
    			publishEvent(new AuthorizationFailureEvent(object, attributes, authenticated,
    					accessDeniedException));
    
    			throw accessDeniedException;
    		}
    
    		if (debug) {
    			logger.debug("Authorization successful");
    		}
    
    		if (publishAuthorizationSuccess) {
    			publishEvent(new AuthorizedEvent(object, attributes, authenticated));
    		}
    
    		// Attempt to run as a different user
    		Authentication runAs = this.runAsManager.buildRunAs(authenticated, object,
    				attributes);
    
    		if (runAs == null) {
    			if (debug) {
    				logger.debug("RunAsManager did not change Authentication object");
    			}
    
    			// no further work post-invocation
    			return new InterceptorStatusToken(SecurityContextHolder.getContext(), false,
    					attributes, object);
    		}
    		else {
    			if (debug) {
    				logger.debug("Switching to RunAs Authentication: " + runAs);
    			}
    
    			SecurityContext origCtx = SecurityContextHolder.getContext();
    			SecurityContextHolder.setContext(SecurityContextHolder.createEmptyContext());
    			SecurityContextHolder.getContext().setAuthentication(runAs);
    
    			// need to revert to token.Authenticated post-invocation
    			return new InterceptorStatusToken(origCtx, true, attributes, object);
    		}
    	}
```

继续调试，问题定位在了 `if (SecurityContextHolder.getContext().getAuthentication() == null) `

也就打印出了日志 `An Authentication object was not found in the SecurityContext`，这也就对的上号了

继续分析

为什么 `SecurityContext` 里的 `Authentication` 会为空呢？

据官方文档解释 spring security 默认是会有匿名的 Authentication 的啊

一想到这里，马上看下配置，原来是我禁用了匿名用户， `.anonymous().disable()` 怪不得这样。。。。

可是一想，为什么以前项目这么配置就没有出现这个问题呢？？？

对比发现，以前的项目是前后端分离的，不需要配置 `loginPage`, 而且登录成功和登录失败都是返回状态码和错误信息的，和我的这个小 demo 不一样，这个是前后端不分离的，需要做页面的跳转

### 为什么如此
这时搞清楚之后，我把 `.anonymous().disable()` 注释掉再重启，刷新下页面，果然登录页出来了，问题不再了

那么为什么会这样呢？？？

我仔细分析了一下， 看下注释掉配置会有说明不同

首先从过滤器链来看， 这里我不再贴日志信息了， 过滤器链整理如下：

**WebAsyncManagerIntegrationFilter**
**SecurityContextPersistenceFilter**
**HeaderWriterFilter**
**LogoutFilter**
**UsernamePasswordAuthenticationFilter**
**RequestCacheAwareFilter**
**SecurityContextHolderAwareRequestFilter**
`AnonymousAuthenticationFilter`
**SessionManagementFilter**
**ExceptionTranslationFilter**
**FilterSecurityInterceptor**

对比发现，过滤器链里多了一个过滤器 `AnonymousAuthenticationFilter`，来看看 `AnonymousAuthenticationFilter` 做了什么事情

``` java
    	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
    			throws IOException, ServletException {
    
    		if (SecurityContextHolder.getContext().getAuthentication() == null) {
    			SecurityContextHolder.getContext().setAuthentication(
    					createAuthentication((HttpServletRequest) req));
    
    			if (logger.isDebugEnabled()) {
    				logger.debug("Populated SecurityContextHolder with anonymous token: '"
    						+ SecurityContextHolder.getContext().getAuthentication() + "'");
    			}
    		}
    		else {
    			if (logger.isDebugEnabled()) {
    				logger.debug("SecurityContextHolder not populated with anonymous token, as it already contained: '"
    						+ SecurityContextHolder.getContext().getAuthentication() + "'");
    			}
    		}
    
    		chain.doFilter(req, res);
    	}
    
    	protected Authentication createAuthentication(HttpServletRequest request) {
    		AnonymousAuthenticationToken auth = new AnonymousAuthenticationToken(key,
    				principal, authorities);
    		auth.setDetails(authenticationDetailsSource.buildDetails(request));
    
    		return auth;
    	}
```

看到了关键信息 `createAuthentication` 和 `setAuthentication`， 那么在后续的过滤器链中就有了认证信息，不再报错了

这也就是为什么解决了这个问题的原因所在

### 重定向的原因
至于为什么会无限的重定向到登录页，还得再回过头来看 `ExceptionTranslationFilter` 类，这里有个处理异常的方法

``` java
    	private void handleSpringSecurityException(HttpServletRequest request,
    			HttpServletResponse response, FilterChain chain, RuntimeException exception)
    			throws IOException, ServletException {
    		if (exception instanceof AuthenticationException) {
    			logger.debug(
    					"Authentication exception occurred; redirecting to authentication entry point",
    					exception);
    
    			sendStartAuthentication(request, response, chain,
    					(AuthenticationException) exception);
    		}
    		else if (exception instanceof AccessDeniedException) {
    			Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
    			if (authenticationTrustResolver.isAnonymous(authentication) || authenticationTrustResolver.isRememberMe(authentication)) {
    				logger.debug(
    						"Access is denied (user is " + (authenticationTrustResolver.isAnonymous(authentication) ? "anonymous" : "not fully authenticated") + "); redirecting to authentication entry point",
    						exception);
    
    				sendStartAuthentication(
    						request,
    						response,
    						chain,
    						new InsufficientAuthenticationException(
    							messages.getMessage(
    								"ExceptionTranslationFilter.insufficientAuthentication",
    								"Full authentication is required to access this resource")));
    			}
    			else {
    				logger.debug(
    						"Access is denied (user is not anonymous); delegating to AccessDeniedHandler",
    						exception);
    
    				accessDeniedHandler.handle(request, response,
    						(AccessDeniedException) exception);
    			}
    		}
    	}
    
    	protected void sendStartAuthentication(HttpServletRequest request,
    			HttpServletResponse response, FilterChain chain,
    			AuthenticationException reason) throws ServletException, IOException {
    		// SEC-112: Clear the SecurityContextHolder's Authentication, as the
    		// existing Authentication is no longer considered valid
    		SecurityContextHolder.getContext().setAuthentication(null);
    		requestCache.saveRequest(request, response);
    		logger.debug("Calling Authentication entry point.");
    		authenticationEntryPoint.commence(request, response, reason);
    	}
```

通过调试， 发现进入了 `sendStartAuthentication` 方法，继续调试，进入 `authenticationEntryPoint.commence` 查看

实现类为 `LoginUrlAuthenticationEntryPoint`

``` java
    	public void commence(HttpServletRequest request, HttpServletResponse response,
    			AuthenticationException authException) throws IOException, ServletException {
    
    		String redirectUrl = null;
    
    		if (useForward) {
    
    			if (forceHttps && "http".equals(request.getScheme())) {
    				// First redirect the current request to HTTPS.
    				// When that request is received, the forward to the login page will be
    				// used.
    				redirectUrl = buildHttpsRedirectUrlForRequest(request);
    			}
    
    			if (redirectUrl == null) {
    				String loginForm = determineUrlToUseForThisRequest(request, response,
    						authException);
    
    				if (logger.isDebugEnabled()) {
    					logger.debug("Server side forward to: " + loginForm);
    				}
    
    				RequestDispatcher dispatcher = request.getRequestDispatcher(loginForm);
    
    				dispatcher.forward(request, response);
    
    				return;
    			}
    		}
    		else {
    			// redirect to login page. Use https if forceHttps true
    
    			redirectUrl = buildRedirectUrlToLoginPage(request, response, authException);
    
    		}
    
    		redirectStrategy.sendRedirect(request, response, redirectUrl);
    	}
```

这里的 `redirectUrl` 通过调试发现就是 `"/"`

于是无限重定向的原因也清楚了。

## 总结
解决方式有 2 种： 
1. 上面所说的注释掉 `.anonymous().disable()`
2. 配置 `webSecurity.ignoring().antMatchers("/")`

``` java
    @Override
    public void configure(WebSecurity web) {
        web.ignoring().antMatchers("/");
    }
```

这种方法一般是配置系统静态资源用，配置的请求根本不会进入 spring security 的过滤器链，直接放行，
而 `.antMatchers("/").permitAll()` 是会进入 spring security 的过滤器链的，这是 2 者的主要区别
结合实际情况，第二种方式不是太好，建议第一种方式。