---
title: Validated 注解的 groups 使用记录
date: 2019-01-26 22:06:25
description: 记录下 Spring Boot 中 @Validated 注解的 groups 使用记录
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->

### @Valid 和 @Validated
1. `@Valid` 和 `@Validated` 注解都用于字段校验
2. `@Valid` 所属包为：`javax.validation.Valid` ; `@Validated` 所属包为 `org.springframework.validation.annotation.Validated`
3. `@Validated` 是 `@Valid` 的一次封装，是Spring提供的校验机制使用。`@Valid` 不提供分组功能


### @Validated的特殊用法
当一个实体类需要多种验证方式时，例：对于一个实体类的id来说，新增的时候是不需要的，对于更新时是必须的

```java
    public class Attachment {
        @Id
        @NotBlank(message = "id can not be blank!", groups = {All.class, Update.class})
        private String id;
    
        @NotBlank(message = "fileName can not be blank!", groups = {All.class})
        private String fileName;
    
        @NotBlank(message = "filePath can not be blank!", groups = {All.class})
        private String filePath;
    
        @Field
        private byte[] data;
    
        @NotBlank(message = "metaData can not be empty!", groups = {All.class})
        private String metaData;
    
        @NotBlank(message = "uploadTime can not be blank!", groups = {All.class})
        private String uploadTime;
    
        public Attachment(@NotBlank(message = "id can not be blank!", groups = {All.class, Update.class}) String id) {
            this.id = id;
        }
    
        public interface All {
        }
    
        public interface Update {
        }
    }
```

单独对 `groups` 进行校验

``` java
    /**
     * 添加附件
     */
    @PostMapping("addAttachment")
    public MessageBody addAttachment(@RequestParam("file") final MultipartFile multipartFile,
                                     @Validated(Attachment.All.class) Attachment attachment,
                                     BindingResult results){
        return attachmentApiService.addAttachment(multipartFile,attachment,results);
    }
    
    /**
     * 更新单个附件
     */
    @PostMapping("updateAttachment")
    public MessageBody updateAttachment(@RequestParam(value = "file",required = false) final MultipartFile multipartFile,
                                        @Validated(Attachment.Update.class) Attachment attachment){
        return attachmentApiService.updateAttachment(multipartFile,attachment);
    }
```

### 使用注意
1. 校验的注解中不分配 groups，默认每次都要进行验证
2. @Validated 没有添加 groups 属性时，默认验证没有分组的验证属性
3. @Validated 添加特定 groups 属性时,只校验该注解中分配了该 groups 的属性
4. 一个功能方法上处理多个模型对象时，需添加多个验证结果对象,如下所示

``` java
    @RequestMapping("/addPeople")  
    public @ResponseBody String addPeople(@Validated People p,BindingResult result,@Validated Person p2,BindingResult result2)  {
    } 
```