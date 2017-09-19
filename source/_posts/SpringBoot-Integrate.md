---
title: 重剑无锋,大巧不工 SpringBoot --- 环境集成
date: 2017-3-14 13:49:11
description: <center><img src = '//image.joylau.cn/blog/SpringBoot-Integrate.png' alt='环境集成'></center>
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->
![build-better-enterprise](//image.joylau.cn/blog/SpringBoot-build-better-enterprise.png)

## SpringBoot文章推荐
- [重剑无锋,大巧不工 SpringBoot --- 基础篇](/2017/03/13/SpringBoot-Basic/)
- [重剑无锋,大巧不工 SpringBoot --- 探索篇](/2017/03/14/SpringBoot-Research/)
- [重剑无锋,大巧不工 SpringBoot --- 环境集成](/2017/03/14/SpringBoot-Integrate/)
- [重剑无锋,大巧不工 SpringBoot --- 批处理SpringBatch](/2017/03/21/SpringBoot-SpringBatch/)
- [重剑无锋,大巧不工 SpringBoot --- @RequestBody JSON参数处理](/2017/06/12/SpringBoot-RequestBody/)
- [重剑无锋,大巧不工 SpringBoot --- 项目问题汇总及解决](/2017/06/12/SpringBoot-Question-Tips/)
- [重剑无锋,大巧不工 SpringBoot --- 属性注入](/2017/06/13/SpringBoot-ConfigurationProperties/)
- [重剑无锋,大巧不工 SpringBoot --- 整合RabbitMQ](/2017/06/16/SpringBoot-RabbitMQ/)
- [重剑无锋,大巧不工 SpringBoot --- RESTful API](/2017/06/18/SpringBoot-RESTfulAPI/)
- [重剑无锋,大巧不工 SpringBoot --- 整合使用MongoDB](/2017/07/18/SpringBoot-MongoDB/)
- [重剑无锋,大巧不工 SpringBoot --- 推荐使用CaffeineCache](/2017/09/19/SpringBoot-CaffeineCache/)

## SpringBoot项目实战
- [重剑无锋,大巧不工 SpringBoot --- 实战项目 JoyMedia （ 分析篇 ）](/2017/07/24/SpringBoot-JoyMedia/)
- [重剑无锋,大巧不工 SpringBoot --- 实战项目 JoyMedia （ Node篇 ）](/2017/07/29/SpringBoot-JoyMedia-Node/)
- [重剑无锋,大巧不工 SpringBoot --- 实战项目 JoyMedia （ 搜索篇 ）](/2017/08/06/SpringBoot-JoyMedia-Search/)
- [重剑无锋,大巧不工 SpringBoot --- 实战项目 JoyMedia （ MV 篇 ）](/2017/08/20/SpringBoot-JoyMedia-MV/)
- [重剑无锋,大巧不工 SpringBoot --- 实战项目 JoyMedia （ NoReferer篇 ）](/2017/08/29/SpringBoot-JoyMedia-NoReferer/)


> 不啰嗦，直接上代码

## 集成Druid
### DruidConfig:
``` java 
    /**
     * Created by LiuFa on 2016/9/14.
     * cn.lfdevelopment.www.sys.druid
     * DevelopmentApp
     */
    @Configuration
    public class DruidConfig{
    
        private Logger logger = LoggerFactory.getLogger(getClass());
    
        @Bean(initMethod = "init", destroyMethod = "close")
        @ConfigurationProperties(prefix="spring.datasource")
        public DataSource druidDataSource(){
            return new DruidDataSource() {
                @Override
                public void setUsername(String username) {
                    try {
                        username = ConfigTools.decrypt(username);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    super.setUsername(username);
                }
    
                @Override
                public void setUrl(String jdbcUrl) {
                    try {
                        jdbcUrl = ConfigTools.decrypt(jdbcUrl);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    super.setUrl(jdbcUrl);
                }
            };
        }
    }
```

### DruidStatViewConfig:
``` java 
    /**
     * Created by LiuFa on 2016/8/8.
     * cn.lfdevelopment.www.sys.druid
     * DevelopmentApp
     * 这样的方式不需要添加注解：@ServletComponentScan
     */
    @Configuration
    public class DruidStatViewConfig {
    
        @Value("${spring.druid.loginUsername}")
        private String loginUsername;
    
        @Value("${spring.druid.loginPassword}")
        private String loginPassword;
    
        /**
         * 注册一个StatViewServlet
         * 使用Druid的内置监控页面
         */
        @Bean
        public ServletRegistrationBean DruidStatViewServlet() {
            ServletRegistrationBean servletRegistrationBean = new ServletRegistrationBean(new StatViewServlet(),
                    "/druid/*");
            //添加初始化参数：initParams
            //白名单
            //ip配置规则
            //配置的格式
            //<IP> 或者 <IP>/<SUB_NET_MASK_size> 多个ip地址用逗号隔开
            //其中
            //128.242.127.1/24
            //24表示，前面24位是子网掩码，比对的时候，前面24位相同就匹配。
            //由于匹配规则不支持IPV6，配置了allow或者deny之后，会导致IPV6无法访问。
            servletRegistrationBean.addInitParameter("allow", "");
    
            //deny优先于allow，如果在deny列表中，就算在allow列表中，也会被拒绝。
            //如果allow没有配置或者为空，则允许所有访问
            //IP黑名单 (存在共同时，deny优先于allow) : 如果满足deny的话提示:Sorry, you are not permitted to view this page.
            servletRegistrationBean.addInitParameter("deny", "");
    
            //登录查看信息的账号密码.
            try {
                servletRegistrationBean.addInitParameter("loginUsername", ConfigTools.decrypt(loginUsername));
                servletRegistrationBean.addInitParameter("loginPassword", ConfigTools.decrypt(loginPassword));
            } catch (Exception e) {
                e.printStackTrace();
            }
    
            //是否能够重置数据.
            servletRegistrationBean.addInitParameter("resetEnable", "true");
    
            return servletRegistrationBean;
        }
    
        /**
         * 注册一个：filterRegistrationBean
         * 内置监控中的Web关联监控的配置
         */
        @Bean
        public FilterRegistrationBean druidStatFilter() {
            FilterRegistrationBean filterRegistrationBean = new FilterRegistrationBean(new WebStatFilter());
    
            //添加过滤规则.
            filterRegistrationBean.addUrlPatterns("/*");
    
            //排除一些不必要的url
            filterRegistrationBean.addInitParameter("exclusions", "*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*");
            //缺省sessionStatMaxCount是1000个,这里设置了3000个
            filterRegistrationBean.addInitParameter("sessionStatMaxCount", "3000");
            //可以配置principalCookieName，使得druid知道指定的sessionName是谁
    //        filterRegistrationBean.addInitParameter("principalSessionName", "sessionId");
            //druid 0.2.7版本开始支持profile，配置profileEnable能够监控单个url调用的sql列表。
            filterRegistrationBean.addInitParameter("profileEnable", "true");
            return filterRegistrationBean;
        }
    
        /**
         * 注册一个:druidStatInterceptor
         */
        /*@Bean
        public DruidStatInterceptor druidStatInterceptor(){
            return new DruidStatInterceptor();
        }*/
    
        /**
         * 注册一个：beanNameAutoProxyCreator
         * 内置监控中的spring关联监控的配置
         * 该方法使用的是按照BeanId来拦截配置，还有2种方法，分别是
         * 按类型拦截配置
         * 方法名正则匹配拦截配置
         */
        /*@Bean
        public BeanNameAutoProxyCreator beanNameAutoProxyCreator(){
            BeanNameAutoProxyCreator beanNameAutoProxyCreator = new BeanNameAutoProxyCreator();
            beanNameAutoProxyCreator.setProxyTargetClass(true);
            beanNameAutoProxyCreator.setBeanNames("*Controller");
            beanNameAutoProxyCreator.setInterceptorNames("druidStatInterceptor");
            return beanNameAutoProxyCreator;
        }*/
    }

```
### application-dev:
``` properties
    #druid配置
    spring.datasource.type=com.alibaba.druid.pool.DruidDataSource
    spring.datasource.driver-class-name=com.mysql.jdbc.Driver
    spring.datasource.url=G11Jor+OrLz9MFztdkOfqRnrJKVrFCDdBbYJFmB0qGjUARxPr2tiyRzUn4xbnk/XqPgM8PMjdIJ/pO8UF4aeVg==
    spring.datasource.username=bNVOqb7WKLX5Bjnw+LMv92taj25KOxDimXxILPQjw42wgv+1lHzOH8kr97xDwWdhpY67QuYCS7sWN4W46YbkFA==
    spring.datasource.password=l65GeQaXVXxx2ogcQeZLAFM7VcPwgzc9202vxql4hjCbjM8dVm/sD4osdvaBdVkC+BiYdnYL2EzpaCysXAZ5Gw==
    
    
    # 下面为连接池的补充设置，应用到上面所有数据源中
    # 初始化大小，最小，最大
    spring.datasource.initialSize=10
    spring.datasource.minIdle=25
    spring.datasource.maxActive=250
    
    # 配置获取连接等待超时的时间
    spring.datasource.maxWait=60000
    
    # 配置间隔多久才进行一次检测，检测需要关闭的空闲连接，单位是毫秒
    spring.datasource.timeBetweenEvictionRunsMillis=1200000
    
    # 配置一个连接在池中最小生存的时间，单位是毫秒
    spring.datasource.minEvictableIdleTimeMillis=1800000
    
    spring.datasource.validationQuery=SELECT 'x'
    
    #建议配置为true，不影响性能，并且保证安全性。申请连接的时候检测，如果空闲时间大于timeBetweenEvictionRunsMillis，执行validationQuery检测连接是否有效。
    spring.datasource.testWhileIdle=true
    
    #申请连接时执行validationQuery检测连接是否有效，做了这个配置会降低性能。
    spring.datasource.testOnBorrow=false
    
    #归还连接时执行validationQuery检测连接是否有效，做了这个配置会降低性能
    spring.datasource.testOnReturn=false
    
    # 打开PSCache，并且指定每个连接上PSCache的大小  如果用Oracle，则把poolPreparedStatements配置为true，mysql可以配置为false。分库分表较多的数据库，建议配置为false 在mysql5.5以下的版本中没有PSCache功能，建议关闭掉。5.5及以上版本有PSCache，建议开启。
    spring.datasource.poolPreparedStatements=true
    
    # 配置监控统计拦截的filters，去掉后监控界面sql无法统计，'wall'用于防火墙,'stat'用于监控，‘log4j’用于日志,'config'是指ConfigFilter
    spring.datasource.filters=wall,stat,config
    
    # 通过connectProperties属性来打开mergeSql功能；慢SQL记录,超过3秒就是慢sql
    spring.datasource.connectionProperties=druid.stat.mergeSql=true;druid.stat.slowSqlMillis=3000;config.decrypt=true
    
    # 合并多个DruidDataSource的监控数据,缺省多个DruidDataSource的监控数据是各自独立的，在Druid-0.2.17版本之后，支持配置公用监控数据
    spring.datasource.useGlobalDataSourceStat=true
    
    #druid登陆用户名
    spring.druid.loginUsername=lCzd9geWAuAuJtLhpaG/J+d28H8KiMFAWopxXkYpMNdUai6Xe/LsPqMQeg5MIrmvtMa+hzycdRhWs29ZUPU1IQ==
    
    #druid登录密码
    spring.druid.loginPassword=hf96/2MU+Q12fdb9oZN9ghub1OHmUBa8YuW7NJf8Pll/sawcaRVscHTpr4t5SB39+KbJn31Lqy76uEDvj+sgMw==
```

## 集成Mybatis
### MyBatisConfig
``` java 
    /**
     * Created by LiuFa on 2016/8/8.
     * cn.lfdevelopment.www.sys.mybatis
     * DevelopmentApp
     * DataSource 交由Druid自动根据配置创建
     */
    @Configuration
    @EnableTransactionManagement
    public class MyBatisConfig implements TransactionManagementConfigurer {
    
        @Autowired
        private DataSource dataSource;
    
    
        @Bean
        public SqlSessionFactory sqlSessionFactory() throws Exception {
            SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
            bean.setDataSource(dataSource);
            bean.setTypeAliasesPackage("cn.lfdevelopment.www.app.**.pojo");
            //支持属性使用驼峰的命名,mapper配置不需要写字段与属性的配置，会自动映射。
            org.apache.ibatis.session.Configuration configuration = new org.apache.ibatis.session.Configuration();
            configuration.setMapUnderscoreToCamelCase(true);
            bean.setConfiguration(configuration);
    
            //分页插件
            PageHelper pageHelper = new PageHelper();
            Properties properties = new Properties();
            /* 3.3.0版本可用 - 分页参数合理化，默认false禁用
             启用合理化时，如果pageNum<1会查询第一页，如果pageNum>pages会查询最后一页
             禁用合理化时，如果pageNum<1或pageNum>pages会返回空数据
             在EXTjs里面配置与否无所谓，因为在前台传过来的分页数据已经进行合理化了 */
            properties.setProperty("reasonable", "true");
            properties.setProperty("supportMethodsArguments", "true");
            properties.setProperty("returnPageInfo", "check");
           /* 3.5.0版本可用 - 为了支持startPage(Object params)方法
             增加了一个`params`参数来配置参数映射，用于从Map或ServletRequest中取值
             可以配置pageNum,pageSize,count,pageSizeZero,reasonable,orderBy,不配置映射的用默认值
             不理解该含义的前提下，不要随便复制该配置 -->*/
    
    //        properties.setProperty("params", "count=countSql");
            pageHelper.setProperties(properties);
    
            //添加插件
            bean.setPlugins(new Interceptor[]{pageHelper});
    
            //添加XML目录
            ResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
            try {
                bean.setMapperLocations(resolver.getResources("classpath*:mapperxml/**/*Mapper.xml"));
                return bean.getObject();
            } catch (Exception e) {
                e.printStackTrace();
                throw new RuntimeException(e);
            }
        }
    
        @Bean
        public SqlSessionTemplate sqlSessionTemplate(SqlSessionFactory sqlSessionFactory) {
            return new SqlSessionTemplate(sqlSessionFactory);
        }
    
        @Bean
        @Override
        public PlatformTransactionManager annotationDrivenTransactionManager() {
            try {
                return new DataSourceTransactionManager(dataSource);
            } catch (Exception e) {
                e.printStackTrace();
                return null;
            }
        }
    }

```

### MyBatisMapperScannerConfig
``` java 
    /**
     * MyBatis扫描接口，使用的tk.mybatis.spring.mapper.MapperScannerConfigurer，如果你不使用通用Mapper，可以改为org.xxx...
     */
    @Configuration
    //由于MapperScannerConfigurer执行的比较早
    public class MyBatisMapperScannerConfig {
    
        @Bean
        public static MapperScannerConfigurer mapperScannerConfigurer() {
            MapperScannerConfigurer mapperScannerConfigurer = new MapperScannerConfigurer();
            mapperScannerConfigurer.setSqlSessionFactoryBeanName("sqlSessionFactory");
            mapperScannerConfigurer.setBasePackage("cn.lfdevelopment.www.app.**.mapper");
            Properties properties = new Properties();
            properties.setProperty("mappers", "cn.lfdevelopment.www.sys.base.BaseMapper");
            properties.setProperty("notEmpty", "false");
            properties.setProperty("IDENTITY", "MYSQL");
            mapperScannerConfigurer.setProperties(properties);
            return mapperScannerConfigurer;
        }
    
    }
```

## 集成Redis

### RedisConfig
``` java 
    
/**
 * Created by LiuFa on 2016/9/5.
 * cn.lfdevelopment.www.sys.redis
 * DevelopmentApp
 */
@Configuration
@EnableCaching
public class RedisConfig extends CachingConfigurerSupport {
    @Bean
    public KeyGenerator keyGenerator() {
        return (target, method, params) -> {
            StringBuilder sb = new StringBuilder();
            sb.append(target.getClass().getName());
            sb.append(method.getName());
            for (Object obj : params) {
                sb.append(obj.toString());
            }
            return sb.toString();
        };
    }

    @Bean
    public CacheManager cacheManager(RedisTemplate redisTemplate) {
        return new RedisCacheManager(redisTemplate);
    }

    /**
     * StringRedisTemplate
     * @param factory
     * @return
     */
    @Bean
    public RedisTemplate<String, String> redisTemplate(RedisConnectionFactory factory) {
        StringRedisTemplate template = new StringRedisTemplate(factory);
        Jackson2JsonRedisSerializer<Object> jackson2JsonRedisSerializer = new Jackson2JsonRedisSerializer<>(Object.class);
        ObjectMapper om = new ObjectMapper();
        om.setVisibility(PropertyAccessor.ALL, JsonAutoDetect.Visibility.ANY);
        om.enableDefaultTyping(ObjectMapper.DefaultTyping.NON_FINAL);
        jackson2JsonRedisSerializer.setObjectMapper(om);
        template.setValueSerializer(jackson2JsonRedisSerializer);
        template.afterPropertiesSet();
        return template;
    }


    /**
     * redisTemplateForShiro
     * @param factory
     * @return
     */
    @Bean
    public RedisTemplate<byte[], Object> redisTemplateForShiro(RedisConnectionFactory factory) {
        RedisTemplate<byte[], Object> redisTemplateForShiro = new RedisTemplate<>();
        redisTemplateForShiro.setConnectionFactory(factory);
        return redisTemplateForShiro;
    }

}
```

## 集成Shiro
### ShiroConfiguration
``` java 
    /**
     * Created by LiuFa on 2016/9/13.
     * cn.lfdevelopment.www.sys.shiro
     * DevelopmentApp
     */
    @Configuration
    public class ShiroConfiguration {
        /**
         * FilterRegistrationBean
         * @return
         */
        @Autowired
        private RedisTemplate redisTemplate;
    
        @Bean
        public FilterRegistrationBean filterRegistrationBean() {
            FilterRegistrationBean filterRegistration = new FilterRegistrationBean();
            filterRegistration.setFilter(new DelegatingFilterProxy("shiroFilter"));
            filterRegistration.addInitParameter("targetFilterLifecycle","true");
            filterRegistration.addUrlPatterns("/*");
            filterRegistration.addInitParameter("exclusions", "*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*");
    //        filterRegistration.setAsyncSupported(true);
            filterRegistration.setDispatcherTypes(DispatcherType.REQUEST);
            return filterRegistration;
        }
    
        /**
         * @see org.apache.shiro.spring.web.ShiroFilterFactoryBean
         * @return
         */
        @Bean(name = "shiroFilter")
        public ShiroFilterFactoryBean shiroFilter(){
            ShiroFilterFactoryBean bean = new ShiroFilterFactoryBean();
            bean.setSecurityManager(securityManager());
            bean.setLoginUrl("/login");
            bean.setSuccessUrl("/main");
            //验证不具备权限后的转向页面
            bean.setUnauthorizedUrl("/main");
    
            Map<String, Filter> filters = new LinkedHashMap<>();
            filters.put("authc",shiroFormAuthenticationFilter());
            filters.put("session",sessionFilter());
            filters.put("rolesOr",rolesAuthorizationFilter());
            bean.setFilters(filters);
    
            Map<String, String> chains = new LinkedHashMap<>();
            chains.put("/favicon.ico","anon");
            chains.put("/","anon");
            chains.put("/index","anon");
            chains.put("/blog","anon");
            chains.put("/blog/**","anon");
            chains.put("/weixin","anon");
            chains.put("/weixin/**","anon");
            chains.put("/static/**", "anon");
            chains.put("/getGifCode","anon");
            chains.put("/404", "anon");
            chains.put("/druid/**","anon");
            chains.put("/logout", "logout");
    
            chains.put("/login", "authc");
            chains.put("/main","authc");
            chains.put("/**", "session,user");
            bean.setFilterChainDefinitionMap(chains);
            return bean;
        }
    
    
        /**
         * @see org.apache.shiro.mgt.SecurityManager
         * @return
         */
        @Bean(name="securityManager")
        public DefaultWebSecurityManager securityManager() {
            DefaultWebSecurityManager manager = new DefaultWebSecurityManager();
            manager.setRealm(userRealm());
            manager.setCacheManager(redisCacheManager());
            manager.setSessionManager(defaultWebSessionManager());
            return manager;
        }
    
        /**
         * @see DefaultWebSessionManager
         * @return
         */
        @Bean(name="sessionManager")
        public DefaultWebSessionManager defaultWebSessionManager() {
            DefaultWebSessionManager sessionManager = new DefaultWebSessionManager();
            sessionManager.setCacheManager(redisCacheManager());
            sessionManager.setGlobalSessionTimeout(1800000);
            sessionManager.setDeleteInvalidSessions(true);
            sessionManager.setSessionValidationSchedulerEnabled(true);
            sessionManager.setSessionValidationInterval(600000);
            sessionManager.setSessionIdUrlRewritingEnabled(false);
            return sessionManager;
        }
    
    
        /**
         * @return
         */
        @Bean
        @DependsOn(value={"lifecycleBeanPostProcessor", "shrioRedisCacheManager"})
        public AuthorizingRealm userRealm() {
            AuthorizingRealm userRealm = new AuthorizingRealm();
            userRealm.setCacheManager(redisCacheManager());
            userRealm.setCachingEnabled(true);
            userRealm.setAuthenticationCachingEnabled(true);
            userRealm.setAuthorizationCachingEnabled(true);
            return userRealm;
        }
    
    
        @Bean(name="shrioRedisCacheManager")
        @DependsOn(value="redisTemplate")
        public ShrioRedisCacheManager redisCacheManager() {
            ShrioRedisCacheManager cacheManager = new ShrioRedisCacheManager(redisTemplate);
            return cacheManager;
        }
    
        @Bean
        public LifecycleBeanPostProcessor lifecycleBeanPostProcessor() {
            return new LifecycleBeanPostProcessor();
        }
    
        @Bean(name = "authcFilter")
        public FormAuthenticationFilter shiroFormAuthenticationFilter(){
            return new AuthcFilter();
        }
    
        @Bean
        public SessionFilter sessionFilter(){
            return new SessionFilter();
        }
    
    
        @Bean(name = "rolesOrFilter")
        public RolesAuthorizationFilter rolesAuthorizationFilter(){
            return new RolesAuthorizationFilter() {
                @Override
                public boolean isAccessAllowed(ServletRequest request,
                                               ServletResponse response, Object mappedValue) throws IOException {
                    Subject subject = getSubject(request, response);
                    String[] rolesArray = (String[]) mappedValue;
    
                    if ((rolesArray == null) || (rolesArray.length == 0)) {
                        return true;
                    }
                    for (String aRolesArray : rolesArray) {
                        if (subject.hasRole(aRolesArray)) {
                            //用户只要拥有任何一个角色则验证通过
                            return true;
                        }
                    }
                    return false;
                }
            };
        }
    }
```

### ShiroRedisCache
``` java 
    /**
     * Created by LiuFa on 2016/9/13.
     * cn.lfdevelopment.www.sys.shiro
     * DevelopmentApp
     */
    public class ShrioRedisCache<K, V> implements Cache<K, V> {
        private org.slf4j.Logger log = LoggerFactory.getLogger(getClass());
        @Autowired
        private RedisTemplate<byte[], V> redisTemplate;
        private String prefix = "shiro_redis:";
    
        public ShrioRedisCache(RedisTemplate<byte[], V> redisTemplate) {
            this.redisTemplate = redisTemplate;
        }
    
        public ShrioRedisCache(RedisTemplate<byte[], V> redisTemplate, String prefix) {
            this(redisTemplate);
            this.prefix = prefix;
        }
    
        @Override
        public V get(K key) throws CacheException {
            if(log.isDebugEnabled()) {
                log.debug("Key: {}", key);
            }
            if(key == null) {
                return null;
            }
    
            byte[] bkey = getByteKey(key);
            return redisTemplate.opsForValue().get(bkey);
        }
    
        @Override
        public V put(K key, V value) throws CacheException {
            if(log.isDebugEnabled()) {
                log.debug("Key: {}, value: {}", key, value);
            }
    
            if(key == null || value == null) {
                return null;
            }
    
            byte[] bkey = getByteKey(key);
            redisTemplate.opsForValue().set(bkey, value);
            return value;
        }
    
        @Override
        public V remove(K key) throws CacheException {
            if(log.isDebugEnabled()) {
                log.debug("Key: {}", key);
            }
    
            if(key == null) {
                return null;
            }
    
            byte[] bkey = getByteKey(key);
            ValueOperations<byte[], V> vo = redisTemplate.opsForValue();
            V value = vo.get(bkey);
            redisTemplate.delete(bkey);
            return value;
        }
    
        @Override
        public void clear() throws CacheException {
            redisTemplate.getConnectionFactory().getConnection().flushDb();
        }
    
        @Override
        public int size() {
            Long len = redisTemplate.getConnectionFactory().getConnection().dbSize();
            return len.intValue();
        }
    
        @SuppressWarnings("unchecked")
        @Override
        public Set<K> keys() {
            byte[] bkey = (prefix+"*").getBytes();
            Set<byte[]> set = redisTemplate.keys(bkey);
            Set<K> result = new HashSet<>();
    
            if(CollectionUtils.isEmpty(set)) {
                return Collections.emptySet();
            }
    
            for(byte[] key: set) {
                result.add((K)key);
            }
            return result;
        }
    
        @Override
        public Collection<V> values() {
            Set<K> keys = keys();
            List<V> values = new ArrayList<>(keys.size());
            for(K k: keys) {
                byte[] bkey = getByteKey(k);
                values.add(redisTemplate.opsForValue().get(bkey));
            }
            return values;
        }
    
        private byte[] getByteKey(K key){
            if(key instanceof String){
                String preKey = this.prefix + key;
                return preKey.getBytes();
            }else{
                return SerializeUtils.serialize(key);
            }
        }
    
        public String getPrefix() {
            return prefix;
        }
    
        public void setPrefix(String prefix) {
            this.prefix = prefix;
        }
    }
```

## 最后
- 本文暂未完结，后续将持续集成更多第三方框架，或接着更新，或另起新篇
- 详细代码内容可在GitHub上follow