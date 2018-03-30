---
title: SpringSecurity Session并发过期后会重定向到 /login (入口点问题)问题的解决
date: 2018-3-30 09:49:25
description: 解决一个在使用 SpringSecurity 时遇到的一个问题
categories: [SpringSecurity篇]
tags: [SpringSecurity,SpringBoot]
---

<!-- more -->
## 问题描述
在 SpringSecurity 中，我想配置一个关于session并发的控制，于是我是这样配置的

``` java 
     @Override
        protected void configure(HttpSecurity http) throws Exception {
            http
                    .sessionManagement()
                    .invalidSessionStrategy(new InvalidSessionStrategyImpl())
                    .maximumSessions(-1).expiredSessionStrategy(expiredSessionStrategy())//配置并发登录，-1表示不限制
                    .sessionRegistry(sessionRegistry());
        }
```

上下文的配置我在此省略了

这里设置 maximumSessions 为 -1,表示不限制同一账号登录的客户端数

session过期后执行的逻辑是进入我自定义的类 expiredSessionStrategy() 中

因为我是构建的 rest 服务，所以我是返回的 http 状态码

``` java
    public class ExpiredSessionStrategyImpl implements SessionInformationExpiredStrategy {
    
        @Override
        public void onExpiredSessionDetected(SessionInformationExpiredEvent event) throws IOException {
            event.getResponse().sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED,
                    JSONObject.toJSONString(MessageBody.failure(405,"not login or login has been expired")));
        }
    }
```

在这里，问题就来了

我测试的时候，把 -1 改成了 1，之后登录同一个用户，后面登录的用户会把前面一个已经登录的用户挤下线，就是说之前登录的那个用户的session 会过期

就是说他所在的页面再发送任何请求的话会收到我返回的 405 状态码

在这里是没问题的

问题就在发完一个请求后，在发一个请求，在浏览器的 network 上会看到发出的请求会被重定向的 /login 请求上

后续再发任何请求都会被重定向到 /login 上

## 问题思考
为什么会出现这样的情况呢？

为什么会第一个请求会收到405的状态码，后续的请求会被重定向到 /login 呢？

通过 debug 断点，我定位到过滤器的前置执行方法 beforeInvocation() 上

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

问题出在了 SecurityContextHolder.getContext().getAuthentication() == null

getAuthentication() 为 null，于是进入了credentialsNotFound(),抛出了 AuthenticationCredentialsNotFoundException 异常

确实，在控制台上也能看到抛出的异常信息


## 问题深入
AuthenticationCredentialsNotFoundException 是 AuthenticationException 异常的子类

不仅仅是 AuthenticationCredentialsNotFoundException 还有其他很多异常都是异常的子类

既然抛出了异常，猜测肯定是被某个处理器给处理了而且处理的默认机制是重定向到 /login 

于是继续搜索 SpringSecurity 异常处理器

我找到的答案是 ExceptionTranslationFilter 

ExceptionTranslationFilter 是Spring Security的核心filter之一，用来处理AuthenticationException和AccessDeniedException两种异常（由FilterSecurityInterceptor认证请求返回的异常）

ExceptionTranslationFilter 对异常的处理是通过这两个处理类实现的，处理规则很简单：

规则1. 如果异常是 AuthenticationException，使用 AuthenticationEntryPoint 处理  
规则2. 如果异常是 AccessDeniedException 且用户是匿名用户，使用 AuthenticationEntryPoint 处理  
规则3. 如果异常是 AccessDeniedException 且用户不是匿名用户，如果否则交给 AccessDeniedHandler 处理。  

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
    								"Full authentication is required to access this resource"));
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
```

我们这里的异常是 AuthenticationException ，紧接着就找 sendStartAuthentication() 方法

``` java
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

上面的方法是先保存请求，之后执行 authenticationEntryPoint.commence(request, response, reason)， 再深入来看

默认实现 commence 接口的是 LoginUrlAuthenticationEntryPoint 类

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

我们看到了 redirectUrl = buildRedirectUrlToLoginPage(request, response, authException)

这下总算是知道了为什么会重定向了 /login 请求了

## 问题
知道问题的原因了，解决问题就很简单了，重新实现 commence 接口，返回http 状态码就可以了，于是加上这样的配置

``` java 
    @Override
        protected void configure(HttpSecurity http) throws Exception {
            http
                    .sessionManagement()
                    .invalidSessionStrategy(new InvalidSessionStrategyImpl())
                    .maximumSessions(-1).expiredSessionStrategy(expiredSessionStrategy())//配置并发登录，-1表示不限制
                    .sessionRegistry(sessionRegistry())
                    .and()
                    .and()
                    .exceptionHandling()
                    .authenticationEntryPoint(new UnauthenticatedEntryPoint())
                    .accessDeniedHandler(new AuthorizationFailure());
        }
```

``` java 
    public class UnauthenticatedEntryPoint implements AuthenticationEntryPoint {
        @Override
        public void commence(HttpServletRequest request, HttpServletResponse response, AuthenticationException authException) throws IOException {
            if (!response.isCommitted()) {
                response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED,"未认证的用户:" + authException.getMessage());
            }
        }
    }
```

再次重试，发现会返回 405状态码了，不会在重定向到 /login 了

问题解决