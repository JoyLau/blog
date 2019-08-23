---
title: Java 开启子线程执行其他操作，并获取结果
date: 2019-08-23 10:01:43
description: Java 开启子线程执行其他操作，并获取结果
categories: [Java篇]
tags: [Java]
---
<!-- more -->

示例代码，10后抛出超时错误，并且取消子线程任务的执行


``` java
    ExecutorService executorService = Executors.newSingleThreadExecutor();
    Future<String> future = executorService.submit(() -> {
                ....
            }
    );

    try {
        return future.get(10, TimeUnit.SECONDS);
    } catch (Exception e) {
        future.cancel(true);
        executorService.shutdown();
        return new ArrayList<>();
    }
```
