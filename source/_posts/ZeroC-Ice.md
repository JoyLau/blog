---
title: ZeroC Ice --- 高性能RPC技术王者
date: 2017-07-10 16:09:59
description: "<center><img src='//image.joylau.cn/blog/ZeroC-ICE.png' alt='ZeroC-ICE'></center><br>HTTP REST 风格的远程通信技术可谓风靡一时，但是其低效也为人诟病<br>高性能，多语言支持，跨平台，轻量级是ICE主打的特性<br>本篇文章我将自己总结一下自己使用ZeroC Ice的技术"
categories: [ZeroC Ice篇]
tags: [ZeroC Ice]
---

<!-- more -->

### 前言
- ZeroC Ice 的背景我就不介绍了
- ZeroC Ice 环境安装搭建，概念原理，技术基础，这些网络上都有，再介绍的话就是copy过来了，没有多大意义，不再赘述了
- 下面我们开始实战


### 开始动手
- 首先我们需要几个ice接口文件,比如说这几个：
![Ice 文件展示](//image.joylau.cn/blog/ZeroC-Ice-1.png)
- 我们来看一下其中一个ice文件定义的接口说明
![Ice接口文件说明](//image.joylau.cn/blog/ZeroC-Ice-2.png)
文件里定义了5个接口，可以很明显的的看到是区间的增删改查接口
刚好很适合我们对外提供增删改查的RESTFul API 接口
这里在对外提供 RESTFul API 是可以很清楚的 使用 POST GET PUT DELETE
可以说这里很好的提供了这样一个例子
- 命令 `slice2java xxx.ice` 生成 java 的 client，server类
![生成的Java类](//image.joylau.cn/blog/ZeroC-Ice-3.png)
生成的Java文件很多，这个不用管，更不必更改里面的代码内容
你要是有兴趣的话，也可以将这些文件分为 client 和 server 分门别类的归纳好
打开看一下，里面的代码很混乱，无论是代码风格，样式，变量命名，对于我来说，简直不忍直视
![生成的Java代码](//image.joylau.cn/blog/ZeroC-Ice-5.png)
- 编写client类
![client类](//image.joylau.cn/blog/ZeroC-Ice-4.png)
代码如下：

``` java
    @Data
    @Component
    @ConfigurationProperties(prefix = "ice")
    public class Client {
        private String adapterName;
        private String host;
        private int port;
    
        private Logger _logger = LoggerFactory.getLogger(Client.class);
    
        /**
         * 执行操作
         *
         * @param command 命令体
         * @return Result
         */
        public Result execute(CommandBody command) {
            Ice.Communicator ic = null;
            try {
                //初使化通信器
                ic = Ice.Util.initialize();
                //传入远程服务单元的名称、网络协议、IP及端口，获取接口的远程代理，这里使用的stringToProxy方式
                Ice.ObjectPrx base = ic.stringToProxy(getStringProxy());
                //通过checkedCast向下转换，获取接口的远程，并同时检测根据传入的名称获取的服务单元是否代理接口，如果不是则返回null对象
                ZKRoadRangeAdminPrx interfacePrx = ZKRoadRangeAdminPrxHelper.checkedCast(base);
                if (interfacePrx == null) {
                    return new Result(false, "Invalid proxy");
                }
                //把接口的方法传给服务端，让服务端执行
                Result result = executeCommand(command, interfacePrx);
                if (result == null) {
                    return new Result(false, "暂无此操作命令");
                }
                return result;
            } catch (Exception e) {
                _logger.info(e.getMessage(), e);
                return new Result(false, "连接错误！" + e);
            } finally {
                if (ic != null) {
                    ic.destroy();
                }
            }
        }
    
        /**
         * 执行操作命令
         *
         * @param command      命令体
         * @param interfacePrx 接口
         * @return ProgramResponse
         */
        private Result executeCommand(CommandBody command, ZKRoadRangeAdminPrx interfacePrx) {
            CommandType type = command.getCommandType();
            if (type.equals(CommandType.addRange)) {
                return returnMessage(interfacePrx.AddRange(command.getZkRoadRange()));
            } else if (type.equals(CommandType.updateRange)) {
                return returnMessage(interfacePrx.UpdateRange(command.getZkRoadRange()));
            } else if (type.equals(CommandType.removeRange)) {
                return returnMessage(interfacePrx.RemoveRange(command.getZkRoadRange().code));
            } else if (type.equals(CommandType.getRange)) {
                return new Result(true, JSONObject.toJSONString(interfacePrx.GetRange(command.getZkRoadRange().code)));
            } else if (type.equals(CommandType.listRanges)) {
                return new Result(true, JSONObject.toJSONString(interfacePrx.ListRanges()));
            }
            return null;
        }
    
    
        /**
         * 获取配置的地址信息
         *
         * @return String
         */
        private String getStringProxy() {
            return adapterName + ":tcp -h " + host + " -p " + port;
        }
    
    
        private Result returnMessage(boolean result) {
            return result ? new Result(true, "success") : new Result(false, "failure");
        }
    
    }
```

- 需要三个配置： 适配器名，IP地址，端口号，配置在SpringBoot项目里，如下：
![ICE配置信息](//image.joylau.cn/blog/ZeroC-Ice-6.png)


### 再封装一下
- 封装返回消息体
![ICE配置信息](//image.joylau.cn/blog/ZeroC-Ice-8.png)
- 封装执行命令体
![ICE配置信息](//image.joylau.cn/blog/ZeroC-Ice-7.png)


### 重要
- 调用 ice 里的接口方法：获取远程代理的 checkedCast 
- 获取远程接口的 interfacePrx 可直接调用 ice 文件里的方法
- 服务端的 Ice 版本最好和 客户端的版本相同
- 服务端提供服务时需要创建一个 servant ，一般的我们会在接口名后面加一个I，以此命名作为Java文件类名
- 该servant继承 接口文件的Disp类，并重写接口中定义的方法，实现具体的业务逻辑
- Server端创建一个适配器 adapter，将servant 放进去
- 服务退出前，一直对请求持续监听


 