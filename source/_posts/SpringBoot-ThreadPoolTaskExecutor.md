---
title: 重剑无锋,大巧不工 SpringBoot --- 理解 ThreadPoolTaskExecutor
date: 2018-11-24 14:35:07
description: 在我们日常开发中难免要使用多线程去执行任务,使用多线程的话我们通常会使用线程池
categories: [SpringBoot篇]
tags: [Spring,SpringBoot]
---

<!-- more -->
### spring 的线程池 ThreadPoolTaskExecutor
spring 为我们实现了一个基于 ThreadPoolExecutor 线程池

### 使用
1. yml 

``` yml
    traffic:
      executor:
        name: "trafficServiceExecutor"
        core-pool-size: 5
        max-pool-size: 10
        queue-capacity: 20
        thread-name-prefix: "traffic-service-"
```

2. Configuration

``` java 
    @Data
    @Configuration
    @ConfigurationProperties(prefix = "traffic.executor")
    public class Executor {
        private String name;
    
        private Integer corePoolSize;
    
        private Integer maxPoolSize;
    
        private Integer queueCapacity;
    
        private String threadNamePrefix;
    }
```

3. Bean

``` java 
    @Configuration
    @ConditionalOnBean(Executor.class)
    public class ExecutorConfig {
        @Bean
        public ThreadPoolTaskExecutor trafficServiceExecutor(@Autowired Executor executor) {
            ThreadPoolTaskExecutor threadPoolTaskExecutor = new ThreadPoolTaskExecutor();
            threadPoolTaskExecutor.setCorePoolSize(executor.getCorePoolSize());
            threadPoolTaskExecutor.setMaxPoolSize(executor.getMaxPoolSize());
            threadPoolTaskExecutor.setQueueCapacity(executor.getQueueCapacity());
            threadPoolTaskExecutor.setThreadNamePrefix(executor.getThreadNamePrefix());
            threadPoolTaskExecutor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
            threadPoolTaskExecutor.initialize();
            return threadPoolTaskExecutor;
        }
    }
```

仅此步骤,我们在使用的时候,只需要注解 @Async("trafficServiceExecutor") 配置好 name 即可

### 个人理解
理解图
![](//s3.joylau.cn:9000/blog/springboot-ThreadPoolTaskExecutor.jpg)

### 看点数据
在线程池整个运作过程中,想看下运行状态的话可以这么做:
常用状态：

- `taskCount`：线程需要执行的任务个数。
- `completedTaskCount`：线程池在运行过程中已完成的任务数。
- `largestPoolSize`：线程池曾经创建过的最大线程数量。
- `getPoolSize`: 获取当前线程池的线程数量。
- `getActiveCount`：获取活动的线程的数量

通过继承线程池，重写beforeExecute，afterExecute和terminated方法来在线程执行任务前，线程执行任务结束，和线程终结前获取线程的运行情况，根据具体情况调整线程池的线程数量

### 重写一波

``` java
    @Slf4j
    public class MyExecutor extends ExecutorConfigurationSupport
            implements AsyncListenableTaskExecutor, SchedulingTaskExecutor {
    
        private final Object poolSizeMonitor = new Object();
    
        private int corePoolSize = 1;
    
        private int maxPoolSize = Integer.MAX_VALUE;
    
        private int keepAliveSeconds = 60;
    
        private int queueCapacity = Integer.MAX_VALUE;
    
        private boolean allowCoreThreadTimeOut = false;
    
        @Nullable
        private TaskDecorator taskDecorator;
    
        @Nullable
        private ThreadPoolExecutor threadPoolExecutor;
    
        // Runnable decorator to user-level FutureTask, if different
        private final Map<Runnable, Object> decoratedTaskMap =
                new ConcurrentReferenceHashMap<>(16, ConcurrentReferenceHashMap.ReferenceType.WEAK);
    
    
        public void setCorePoolSize(int corePoolSize) {
            synchronized (this.poolSizeMonitor) {
                this.corePoolSize = corePoolSize;
                if (this.threadPoolExecutor != null) {
                    this.threadPoolExecutor.setCorePoolSize(corePoolSize);
                }
            }
        }
    
        public int getCorePoolSize() {
            synchronized (this.poolSizeMonitor) {
                return this.corePoolSize;
            }
        }
    
        public void setMaxPoolSize(int maxPoolSize) {
            synchronized (this.poolSizeMonitor) {
                this.maxPoolSize = maxPoolSize;
                if (this.threadPoolExecutor != null) {
                    this.threadPoolExecutor.setMaximumPoolSize(maxPoolSize);
                }
            }
        }
    
        public int getMaxPoolSize() {
            synchronized (this.poolSizeMonitor) {
                return this.maxPoolSize;
            }
        }
    
        public void setKeepAliveSeconds(int keepAliveSeconds) {
            synchronized (this.poolSizeMonitor) {
                this.keepAliveSeconds = keepAliveSeconds;
                if (this.threadPoolExecutor != null) {
                    this.threadPoolExecutor.setKeepAliveTime(keepAliveSeconds, TimeUnit.SECONDS);
                }
            }
        }
    
        public int getKeepAliveSeconds() {
            synchronized (this.poolSizeMonitor) {
                return this.keepAliveSeconds;
            }
        }
    
        public void setQueueCapacity(int queueCapacity) {
            this.queueCapacity = queueCapacity;
        }
    
        public void setAllowCoreThreadTimeOut(boolean allowCoreThreadTimeOut) {
            this.allowCoreThreadTimeOut = allowCoreThreadTimeOut;
        }
    
        public void setTaskDecorator(TaskDecorator taskDecorator) {
            this.taskDecorator = taskDecorator;
        }
    
    
        @Override
        protected ExecutorService initializeExecutor(
                ThreadFactory threadFactory, RejectedExecutionHandler rejectedExecutionHandler) {
    
            BlockingQueue<Runnable> queue = createQueue(this.queueCapacity);
    
            ThreadPoolExecutor executor;
            if (this.taskDecorator != null) {
                executor = new ThreadPoolExecutor(
                        this.corePoolSize, this.maxPoolSize, this.keepAliveSeconds, TimeUnit.SECONDS,
                        queue, threadFactory, rejectedExecutionHandler) {
                    @Override
                    public void execute(Runnable command) {
                        Runnable decorated = taskDecorator.decorate(command);
                        if (decorated != command) {
                            decoratedTaskMap.put(decorated, command);
                        }
                        super.execute(decorated);
                    }
    
                };
            }
            else {
                executor = new ThreadPoolExecutor(
                        this.corePoolSize, this.maxPoolSize, this.keepAliveSeconds, TimeUnit.SECONDS,
                        queue, threadFactory, rejectedExecutionHandler){
                    @Override
                    public void beforeExecute(Thread t, Runnable r) {
    //                    log.error("线程开始......");
    //                    log.error("当前线程池的线程数量:{}",MyExecutor.this.getPoolSize());
    //                    log.error("活动的线程的数量:{}",MyExecutor.this.getActiveCount());
    //                    log.error("线程需要执行的任务个数:{}",getTaskCount());
    //                    log.error("线程池在运行过程中已完成的任务数:{}",getCompletedTaskCount());
                    }
                    @Override
                    public void afterExecute(Runnable r, Throwable t) {
                        log.error("线程池在运行过程中已完成的任务数:{}",getCompletedTaskCount());
                    }
                };
    
            }
    
            if (this.allowCoreThreadTimeOut) {
                executor.allowCoreThreadTimeOut(true);
            }
    
            this.threadPoolExecutor = executor;
            return executor;
        }
    
        protected BlockingQueue<Runnable> createQueue(int queueCapacity) {
            if (queueCapacity > 0) {
                return new LinkedBlockingQueue<>(queueCapacity);
            }
            else {
                return new SynchronousQueue<>();
            }
        }
    
        public ThreadPoolExecutor getThreadPoolExecutor() throws IllegalStateException {
            Assert.state(this.threadPoolExecutor != null, "ThreadPoolTaskExecutor not initialized");
            return this.threadPoolExecutor;
        }
    
        public int getPoolSize() {
            if (this.threadPoolExecutor == null) {
                // Not initialized yet: assume core pool size.
                return this.corePoolSize;
            }
            return this.threadPoolExecutor.getPoolSize();
        }
    
        public int getActiveCount() {
            if (this.threadPoolExecutor == null) {
                // Not initialized yet: assume no active threads.
                return 0;
            }
            return this.threadPoolExecutor.getActiveCount();
        }
    
    
        @Override
        public void execute(Runnable task) {
            Executor executor = getThreadPoolExecutor();
            try {
                executor.execute(task);
            }
            catch (RejectedExecutionException ex) {
                throw new TaskRejectedException("Executor [" + executor + "] did not accept task: " + task, ex);
            }
        }
    
        @Override
        public void execute(Runnable task, long startTimeout) {
            execute(task);
        }
    
        @Override
        public Future<?> submit(Runnable task) {
            ExecutorService executor = getThreadPoolExecutor();
            try {
                return executor.submit(task);
            }
            catch (RejectedExecutionException ex) {
                throw new TaskRejectedException("Executor [" + executor + "] did not accept task: " + task, ex);
            }
        }
    
        @Override
        public <T> Future<T> submit(Callable<T> task) {
            ExecutorService executor = getThreadPoolExecutor();
            try {
                return executor.submit(task);
            }
            catch (RejectedExecutionException ex) {
                throw new TaskRejectedException("Executor [" + executor + "] did not accept task: " + task, ex);
            }
        }
    
        @Override
        public ListenableFuture<?> submitListenable(Runnable task) {
            ExecutorService executor = getThreadPoolExecutor();
            try {
                ListenableFutureTask<Object> future = new ListenableFutureTask<>(task, null);
                executor.execute(future);
                return future;
            }
            catch (RejectedExecutionException ex) {
                throw new TaskRejectedException("Executor [" + executor + "] did not accept task: " + task, ex);
            }
        }
    
        @Override
        public <T> ListenableFuture<T> submitListenable(Callable<T> task) {
            ExecutorService executor = getThreadPoolExecutor();
            try {
                ListenableFutureTask<T> future = new ListenableFutureTask<>(task);
                executor.execute(future);
                return future;
            }
            catch (RejectedExecutionException ex) {
                throw new TaskRejectedException("Executor [" + executor + "] did not accept task: " + task, ex);
            }
        }
    
        @Override
        protected void cancelRemainingTask(Runnable task) {
            super.cancelRemainingTask(task);
            // Cancel associated user-level Future handle as well
            Object original = this.decoratedTaskMap.get(task);
            if (original instanceof Future) {
                ((Future<?>) original).cancel(true);
            }
        }
    }

```

主要看 `initializeExecutor` 方法,我重写了 `ThreadPoolExecutor` 的 `beforeExecute` 和 `afterExecute` 打印了一些信息,可以帮助理解整个过程

### 配置参考
- 如果是CPU密集型任务，那么线程池的线程个数应该尽量少一些，一般为CPU的个数+1条线程。 linux 查看 CPU 信息 : `cat /proc/cpuinfo`
- 如果是IO密集型任务，那么线程池的线程可以放的很大，如2*CPU的个数。
- 对于混合型任务，如果可以拆分的话，通过拆分成CPU密集型和IO密集型两种来提高执行效率；如果不能拆分的的话就可以根据实际情况来调整线程池中线程的个数。