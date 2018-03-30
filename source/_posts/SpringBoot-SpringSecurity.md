---
title: 重剑无锋,大巧不工 SpringBoot --- 整合使用 SpringSecurity
date: 2018-3-28 09:20:38
description: 公司近期有个项目的安全框架是用 Spring Security 搭建的，现在项目做完了，是时候总结一下 SpringBoot 整合 SpringSecurity 的使用了
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->

## 引入依赖
``` xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>

    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-test</artifactId>
        <scope>test</scope>
    </dependency>
```


## SpringSecurity 配置类
``` java 
    @EqualsAndHashCode(callSuper = true)
    @Data
    @Configuration
    @EnableWebSecurity
    @EnableGlobalMethodSecurity(prePostEnabled = true, securedEnabled = true, jsr250Enabled = true)
    @ConfigurationProperties(prefix = "spring.security.ignore")
    public class WebSecurityConfig extends WebSecurityConfigurerAdapter {
        private List<String[]> marchers;
    
        @Bean
        public UserService userService(){
            return new UserService();
        }
    
        @Override
        protected void configure(HttpSecurity http) throws Exception {
            http
                    .anonymous().disable()
                    .csrf().disable()
                    .authorizeRequests()
    //                .requestMatchers(CorsUtils::isPreFlightRequest).permitAll() //解决PreFlight请求问题
                    .anyRequest().authenticated()//其他请求必须授权后访问
                    .and()
                    .formLogin()
    //                .loginPage("/login")
                    .loginProcessingUrl("/login")
                    .successHandler(authenticationSuccessHandler())
                    .failureHandler(authenticationFailureHandler())
                    .permitAll()//登录请求可以直接访问
                    .and()
                    .logout()
                    .invalidateHttpSession(true)
                    .deleteCookies("JSESSIONID")
                    .logoutSuccessHandler(new LogoutSuccess())
                    .permitAll()//注销请求可直接访问
                    .and()
                    .sessionManagement()
                    .invalidSessionStrategy(new InvalidSessionStrategyImpl())
                    .maximumSessions(-1).expiredSessionStrategy(expiredSessionStrategy())//配置并发登录，-1表示不限制
                    .sessionRegistry(sessionRegistry())
                    .and()
                    .and()
                    .exceptionHandling()
                    .authenticationEntryPoint(new UnauthenticatedEntryPoint())
                    .accessDeniedHandler(new AuthorizationFailure())
                    .and()
                    .addFilterBefore(new AuthorizationFilter(new AuthorizationMetadataSource(), new
                    AuthorizationAccessDecisionManager()), FilterSecurityInterceptor.class);
    
        }
    
        @Override
        public void configure(AuthenticationManagerBuilder auth) {
            auth.authenticationProvider(authenticationProvider());
        }
    
        @Bean
        public SessionRegistry sessionRegistry(){
            return new SessionRegistryImpl();
        }
    
        @Bean
        public ExpiredSessionStrategyImpl expiredSessionStrategy(){
            return new ExpiredSessionStrategyImpl();
        }
    
        @Bean
        public BCryptPasswordEncoder passwordEncoder() {
            return SecurityUtils.getPasswordEncoder();
        }
    
        @Override
        public void configure(WebSecurity web) {
            for (String[] marcher : marchers) {
                web.ignoring().antMatchers(marcher);
            }
        }
    
        @Bean
        public DaoAuthenticationProvider authenticationProvider() {
            DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
            /*不将UserNotFoundExceptions转换为BadCredentialsException*/
            provider.setHideUserNotFoundExceptions(false);
            provider.setUserDetailsService(userService());
            provider.setPasswordEncoder(passwordEncoder());
            return provider;
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

## 自定义 userService
``` java 
    public class UserService implements UserDetailsService {
        @Autowired
        private WebSecurityConfig securityConfig;
    
        @Autowired
        private SysUserMapper userMapper;
    
        @Override
        public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
            if (StringUtils.isEmpty(username)) {
                throw new UsernameNotFoundException("用户名不能为空!");
            }
            SysUser user = new SysUser();
            user.setLoginName(username);
            SysUser queryUser = userMapper.selectOne(user);
            if (null == queryUser) {
                throw new UsernameNotFoundException("用户  " + username + " 不存在!");
            }
            if (!queryUser.getPermissionIpList().contains("0.0.0.0") && !queryUser.getPermissionIpList().contains
                    (SecurityUtils.getRemoteAddress())) {
                throw new InvalidIpAddrException("登录 IP 地址不合法");
            }
    
            return new SecurityUser(queryUser);
        }
    
        /**
         * 重新授权
         */
        public void reAuthorization(){
            SecurityUser user = SecurityUtils.currentUser();
            assert user != null;
            String username = user.getUsername();
            user.setRoles(userMapper.findRolesByName(username));
            user.setMenus(userMapper.findMenusByName(username));
            user.setFunctions(userMapper.findFunctionsByName(username));
    
            List<GrantedAuthority> authorities = new ArrayList<>();
            for (Function function : user.getFunctions()) {
                for (String url : function.getFunctionUrl().split(",")) {
                    authorities.add(new SimpleGrantedAuthority(url));
                }
            }
            user.setAuthorities(authorities.stream().distinct().collect(Collectors.toList()));
            // 得到当前的认证信息
            Authentication auth = SecurityUtils.getAuthentication();
            // 生成新的认证信息
            Authentication newAuth = new UsernamePasswordAuthenticationToken(auth.getPrincipal(), auth.getCredentials(), authorities);
            // 重置认证信息
            SecurityContextHolder.getContext().setAuthentication(newAuth);
    
        }
    
    
        /**
         * 根据用户名 将该用户登录的所有账户踢下线
         * @param userNames userNames
         */
        public void kickOutUser(String... userNames) {
            SessionRegistry sessionRegistry = securityConfig.sessionRegistry();
            for (Object o : sessionRegistry.getAllPrincipals()) {
                SecurityUser user = (SecurityUser) o;
                for (String username : userNames) {
                    if (user.getLoginName().equals(username)) {
                        for (SessionInformation sessionInformation : sessionRegistry.getAllSessions(user, false)) {
                            sessionInformation.expireNow();
                        }
                    }
                }
            }
        }
    }
```

## 用户实体类 SecurityUser
``` java 
    @Data
    public class SecurityUser extends SysUser implements UserDetails{
    
        /*角色*/
        private List<SysRole> roles;
    
        /*菜单*/
        private List<Menu> menus;
    
        /*功能权限*/
        private List<Function> functions;
    
        private Collection<? extends GrantedAuthority> authorities;
    
        SecurityUser(SysUser user) {
            this.setUserId(user.getUserId());
            this.setGlbm(user.getGlbm());
            this.setXh(user.getXh());
            this.setLoginName(user.getLoginName());
            this.setLoginPassword(user.getLoginPassword());
            this.setPermissionIpList(user.getPermissionIpList());
            this.setLatestLoginTime(user.getLatestLoginTime());
            this.setTotalLoginCounts(user.getTotalLoginCounts());
            this.setName(user.getName());
            this.setCreateTime(user.getCreateTime());
            this.setUpdateTime(user.getUpdateTime());
        }
    
    
        @Override
        public Collection<? extends GrantedAuthority> getAuthorities() {
            return authorities;
        }
    
        @Override
        public boolean isAccountNonExpired() {
            return true;
        }
    
        @Override
        public boolean isAccountNonLocked() {
            return true;
        }
    
        @Override
        public boolean isCredentialsNonExpired() {
            return true;
        }
    
        @Override
        public boolean isEnabled() {
            return true;
        }
    
        @Override
        public String getPassword() {
            return super.getLoginPassword();
        }
    
        @Override
        public String getUsername() {
            return super.getLoginName();
        }
    
        @Override
        public int hashCode() {
            return this.getLoginName().hashCode();
        }
    
        @Override
        public boolean equals(Object obj) {
            return obj instanceof SecurityUser && ((SecurityUser) obj).getLoginName().equals(this.getLoginName());
        }
    }
```

## 授权Filter
``` java 
    public class AuthorizationFilter extends AbstractSecurityInterceptor implements Filter {
    
        private AuthorizationMetadataSource metadataSource;
    
        public AuthorizationFilter(AuthorizationMetadataSource metadataSource, AuthorizationAccessDecisionManager
                accessDecisionManager) {
            this.metadataSource = metadataSource;
            this.setAccessDecisionManager(accessDecisionManager);
        }
    
        @Override
        public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain)
                throws IOException, ServletException {
            FilterInvocation fi = new FilterInvocation(servletRequest, servletResponse, filterChain);
            invoke(fi);
        }
    
        private void invoke(FilterInvocation fi) throws IOException, ServletException {
            InterceptorStatusToken token = super.beforeInvocation(fi);
            try {
                fi.getChain().doFilter(fi.getRequest(), fi.getResponse());
            } finally {
                super.afterInvocation(token, null);
            }
        }
    
    
        @Override
        public Class<?> getSecureObjectClass() {
            return FilterInvocation.class;
        }
    
        @Override
        public SecurityMetadataSource obtainSecurityMetadataSource() {
            return metadataSource;
        }
    
        @Override
        public void destroy() {
        }
    
        @Override
        public void init(FilterConfig filterConfig) {
        }
    }
```

## 授权访问决策器
``` java 
    public class AuthorizationAccessDecisionManager implements AccessDecisionManager {
    
        /**
         * 认证用户是否具有权限访问该url地址
         */
        @Override
        public void decide(Authentication authentication, Object object, Collection<ConfigAttribute> configAttributes)
                throws AccessDeniedException, InsufficientAuthenticationException {
            HttpServletRequest request = ((FilterInvocation) object).getRequest();
            String url = ((FilterInvocation) object).getRequestUrl();
            for (GrantedAuthority grantedAuthority : authentication.getAuthorities()) {
                SimpleGrantedAuthority authority = (SimpleGrantedAuthority) grantedAuthority;
                if (matches(authority.getAuthority(), request)) {
                    return;
                }
            }
            throw new AccessDeniedException("uri: " + url + ",无权限访问！");
        }
    
        /**
         * 当前AccessDecisionManager是否支持对应的ConfigAttribute
         */
        @Override
        public boolean supports(ConfigAttribute attribute) {
            return true;
        }
    
        /**
         * 当前AccessDecisionManager是否支持对应的受保护对象类型
         */
        @Override
        public boolean supports(Class<?> clazz) {
            return true;
        }
    
        private boolean matches(String url, HttpServletRequest request) {
            AntPathRequestMatcher matcher = new AntPathRequestMatcher(url);
            return matcher.matches(request);
        }
    }
```

## 授权元数据
``` java 
    public class AuthorizationMetadataSource implements FilterInvocationSecurityMetadataSource {
    
        /**
         * 加载 请求的url资源所需的权限
         * @param object object
         * @return Collection
         * @throws IllegalArgumentException Exception
         */
        @Override
        public Collection<ConfigAttribute> getAttributes(Object object) throws IllegalArgumentException {
            String url = ((FilterInvocation) object).getRequestUrl();
            Collection<ConfigAttribute> configAttributes = new ArrayList<>();
            configAttributes.add(new SecurityConfig(url));
            return configAttributes;
        }
    
        /**
         * 会在启动时加载所有 ConfigAttribute 集合
         * @return Collection
         */
        @Override
        public Collection<ConfigAttribute> getAllConfigAttributes() {
            return null;
        }
    
        @Override
        public boolean supports(Class<?> clazz) {
            return true;
        }
    }
```

## 封装一些 Security 工具类
``` java 
    public class SecurityUtils {
    
        public static Authentication getAuthentication(){
            return SecurityContextHolder.getContext().getAuthentication();
        }
    
        /**
         * 用户是否登录
         * @return boolean
         */
        public static boolean isAuthenticated(){
            return getAuthentication() != null || !(getAuthentication() instanceof AnonymousAuthenticationToken);
        }
    
        /**
         * 获取当前用户
         * @return user
         */
        public static SecurityUser currentUser(){
            if (isAuthenticated()) {
                return (SecurityUser) getAuthentication().getPrincipal();
            }
            return null;
        }
    
        /**
         * 获取 webAuthenticationDetails
         */
        private static WebAuthenticationDetails webAuthenticationDetails(){
            return (WebAuthenticationDetails)getAuthentication().getDetails();
        }
    
        /**
         * 获取session id
         */
        public static String getSessionId(){
            return webAuthenticationDetails().getSessionId();
        }
    
        /**
         * 获取远程访问地址
         */
        public static String getRemoteAddress(){
            return webAuthenticationDetails().getRemoteAddress();
        }
    
        /**
         * 获取密码编译器
         * @return BCryptPasswordEncoder
         */
        public static BCryptPasswordEncoder getPasswordEncoder(){
            return new BCryptPasswordEncoder(4);
        }
    
        /**
         * 根据明文加密 返回密文
         * @param rawPassword 明文
         * @return 密文
         */
        public static String createPassword(String rawPassword){
            return getPasswordEncoder().encode(rawPassword.trim());
        }
    
        /**
         * 传入明文和密文 检查是否匹配
         * @param rawPassword 明文
         * @param encodedPassword 密文
         * @return boolean
         */
        public static boolean isMatching(String rawPassword,String encodedPassword){
            return getPasswordEncoder().matches(rawPassword,encodedPassword);
        }
    
    }
```

主要的实现类都列举在内了，还有一些成功和失败的处理类，再次没有列举出来
因为该项目为构建纯restful风格的后台项目，这些成功或失败的处理类基本都是返回的http状态码