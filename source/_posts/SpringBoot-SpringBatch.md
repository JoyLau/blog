---
title: 重剑无锋,大巧不工 SpringBoot --- 批处理SpringBatch
date: 2017-3-21 11:00:39
cover: //s3.joylau.cn:9000/blog/SpringBatch.jpg
description: SpringBatch是用来处理大量数据操作的一个框架，主要用来读取大量数据，然后进行一定处理后输出成指定的形式
categories: [SpringBoot篇]
tags: [Spring,SpringBoot,SpringBatch]
---

<!-- more -->
![SpringBatch](//s3.joylau.cn:9000/blog/SpringBatch.jpg)


## 组成部分
- `JobRepository`: 用来注册**Job**的容器
- `JobLauncher`: 用来启动**Job**的接口
- `Job` : 我要实际执行的任务，包含一个或多个Step
- `Step` : Step-步骤包含**ItemReader**，**ItemProcessor**，**ItemWrite**
- `ItemReader` : 用来读取数据的接口
- `ItemProcessor` : 用来处理数据的接口
- `ItemWrite` : 用来输出数据的接口

## 整合
>> SpringBoot 整合 SpringBatch 只需要引入依赖并注册成Spring 的 Bean 即可，若是想开启批处理的支持还需要在该配置类上添加 **@EnableBatchProcessing**

``` xml
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-batch</artifactId>
        <!-- SpringBatch会自动加载hsqldb，我们去除即可 -->
        <exclusions>
            <exclusion>
                <groupId>org.hsqldb</groupId>
                <artifactId>hsqldb</artifactId>
            </exclusion>
        </exclusions>
    </dependency>
```


来看代码 ：

``` java
    @Configuration
    @EnableBatchProcessing
    public class BatchConfig {
    @Bean
    	public JobRepository jobRepository(DataSource dataSource, PlatformTransactionManager transactionManager)
    			throws Exception {
    		JobRepositoryFactoryBean jobRepositoryFactoryBean = new JobRepositoryFactoryBean();
    		jobRepositoryFactoryBean.setDataSource(dataSource);
    		jobRepositoryFactoryBean.setTransactionManager(transactionManager);
    		jobRepositoryFactoryBean.setDatabaseType("oracle");
    		return jobRepositoryFactoryBean.getObject();
    	}
    
    	@Bean
    	public SimpleJobLauncher jobLauncher(DataSource dataSource, PlatformTransactionManager transactionManager)
    			throws Exception {
    		SimpleJobLauncher jobLauncher = new SimpleJobLauncher();
    		jobLauncher.setJobRepository(jobRepository(dataSource, transactionManager));
    		return jobLauncher;
    	}
    
    	@Bean
    	public Job importJob(JobBuilderFactory jobs, Step s1) {
    		return jobs.get("importJob")
    				.incrementer(new RunIdIncrementer())
    				.flow(s1) 
    				.end()
    				.listener(csvJobListener())
    				.build();
    	}
    
    	@Bean
    	public Step step1(StepBuilderFactory stepBuilderFactory, ItemReader<Person> reader, ItemWriter<Person> writer,
    			ItemProcessor<Person,Person> processor) {
    		return stepBuilderFactory
    				.get("step1")
    				.<Person, Person>chunk(65000) //1
    				.reader(reader)
    				.processor(processor)
    				.writer(writer)
    				.build();
    	}
    	
    	
    	
    	//接口分别实现
    	
    	@Bean
        	public ItemReader<Person> reader() throws Exception {
        	        //
        	        return reader;
        	}
        	
        	@Bean
        	public ItemProcessor<Person, Person> processor() {
        		//
        		return processor;
        	}
        	
        	
        
        	@Bean
        	public ItemWriter<Person> writer(DataSource dataSource) {//1
        		//
        		return writer;
        	}
    }
```


**貌似就这么简单的完成了......**

## 扩展
- 监听Job的执行情况，自定义类实现`JobExecutionListener`
- 执行计划任务，在普通的计划任务方法中执行JobLauncher的run方法即可