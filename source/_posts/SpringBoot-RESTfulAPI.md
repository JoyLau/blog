---
title: 重剑无锋,大巧不工 SpringBoot --- RESTful API
date: 2017-6-18 10:36:21
img: <center><img src='//image.joylau.cn/blog/spring-boot-swagger.png' alt='spring-boot-swagger'></center>
description: 最近在写将ZeroC Ice接口包装成RESTful API以供其他端调用，接口太多奈何要写的文档也太多，想在提供接口时就展示相应的说明文档
categories: [SpringBoot篇]
tags: [Spring,SpringBoot,Swagger2]
---

<!-- more -->

## 前言

- 使用很简单
- 关注业务开发
- 熟悉提供的注解


## 开始

### 引入依赖

``` xml
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger2</artifactId>
        <version>2.7.0</version>
    </dependency>
    <dependency>
        <groupId>io.springfox</groupId>
        <artifactId>springfox-swagger-ui</artifactId>
        <version>2.7.0</version>
    </dependency>
```


### 配置启动

``` java
    @SpringBootApplication
    @EnableSwagger2
    public class JoylauSwagger2Application {
    
    	public static void main(String[] args) {
    		SpringApplication.run(JoylauSwagger2Application.class, args);
    	}
    
    	@Bean
    	public Docket createRestApi() {
    		return new Docket(DocumentationType.SWAGGER_2)
    				.apiInfo(apiInfo())
    				.select()
    				.apis(RequestHandlerSelectors.basePackage("cn.joylau.code"))
    				.paths(PathSelectors.any())
    				.build();
    	}
    
    	private ApiInfo apiInfo() {
    		return new ApiInfoBuilder()
    				.title("Spring Boot构建RESTful APIs")
    				.description("将每一个注解的@RestController和@ResponseBody的类和方法生成API，点击即可展开")
    				.termsOfServiceUrl("http://blog.joylau.cn")
    				.contact(new Contact("joylau","http://blog.joylau.cn","2587038142@qq.com"))
    				.license("The Apache License, Version 2.0")
    				.licenseUrl("http://www.apache.org/licenses/LICENSE-2.0.html")
    				.version("1.0")
    				.build();
    	}
    }
```

### 注解说明

``` java 
    @RestController
    @RequestMapping(value="/users")     // 通过这里配置使下面的映射都在/users下，可去除
    public class UserController {
    
        static Map<Long, User> users = Collections.synchronizedMap(new HashMap<Long, User>());
    
        @ApiOperation(value="获取用户列表", notes="")
        @RequestMapping(value={""}, method= RequestMethod.GET)
        public List<User> getUserList() {
            List<User> r = new ArrayList<User>(users.values());
            return r;
        }
    
        @ApiOperation(value="创建用户", notes="根据User对象创建用户")
        @ApiImplicitParam(name = "user", value = "用户详细实体user", required = true, dataType = "User")
        @RequestMapping(value="", method=RequestMethod.POST)
        public String postUser(@RequestBody User user) {
            users.put(user.getId(), user);
            return "success";
        }
    
        @ApiOperation(value="获取用户详细信息", notes="根据url的id来获取用户详细信息")
        @ApiImplicitParam(name = "id", value = "用户ID", required = true, dataType = "Long")
        @RequestMapping(value="/{id}", method=RequestMethod.GET)
        public User getUser(@PathVariable Long id) {
            return users.get(id);
        }
    
        @ApiOperation(value="更新用户详细信息", notes="根据url的id来指定更新对象，并根据传过来的user信息来更新用户详细信息")
        @ApiImplicitParams({
                @ApiImplicitParam(name = "id", value = "用户ID", required = true, dataType = "Long"),
                @ApiImplicitParam(name = "user", value = "用户详细实体user", required = true, dataType = "User")
        })
        @RequestMapping(value="/{id}", method=RequestMethod.PUT)
        public String putUser(@PathVariable Long id, @RequestBody User user) {
            User u = users.get(id);
            u.setName(user.getName());
            u.setAge(user.getAge());
            users.put(id, u);
            return "success";
        }
    
        @ApiOperation(value="删除用户", notes="根据url的id来指定删除对象")
        @ApiImplicitParam(name = "id", value = "用户ID", required = true, dataType = "Long")
        @RequestMapping(value="/{id}", method=RequestMethod.DELETE)
        public String deleteUser(@PathVariable Long id) {
            users.remove(id);
            return "success";
        }
    
    }
```


### 常见注解
- `@Api`：修饰整个类，描述Controller的作用
- `@ApiOperation`：描述一个类的一个方法，或者说一个接口
- `@ApiParam`：单个参数描述
- `@ApiModel`：用对象来接收参数
- `@ApiProperty`：用对象接收参数时，描述对象的一个字段
- `@ApiResponse`：HTTP响应其中1个描述
- `@ApiResponses`：HTTP响应整体描述
- `@ApiIgnore`：使用该注解忽略这个API 
- `@ApiClass`
- `@ApiError`
- `@ApiErrors`
- `@ApiParamImplicit`
- `@ApiParamsImplicit`


## 最后

### 注意

- Swagger2默认将所有的Controller中的RequestMapping方法都会暴露，然而在实际开发中，我们并不一定需要把所有API都提现在文档中查看，这种情况下，使用注解@ApiIgnore来解决，如果应用在Controller范围上，则当前Controller中的所有方法都会被忽略，如果应用在方法上，则对应用的方法忽略暴露API

或者重写方法


``` java 
    public Docket createRestApi() {
            Predicate<RequestHandler> predicate = new Predicate<RequestHandler>() {
                @Override
                public boolean apply(RequestHandler input) {
                    Class<?> declaringClass = input.declaringClass();
                    if (declaringClass == BasicErrorController.class)// 排除
                        return false;
                    if(declaringClass.isAnnotationPresent(RestController.class)) // 被注解的类
                        return true;
                    if(input.isAnnotatedWith(ResponseBody.class)) // 被注解的方法
                        return true;
                    return false;
                }
            };
```