---
title: 重剑无锋,大巧不工 SpringBoot --- 实战项目 JoyMedia （ 搜索篇 ）
date: 2017-08-06 18:09:47
cover: //s3.joylau.cn:9000/blog/jquery-autocomplate.gif
description: JoyMedia --- 搜索自己想听的音乐
categories: [SpringBoot篇]
tags: [SpringBoot,Jquery]
---

<!-- more -->
## 前言
### 效果展示
![JoyMedia - Search](//s3.joylau.cn:9000/blog/jquery-autocomplate.gif)
### 在线地址
- [JoyMusic](//music.joylau.cn)
### 解释
- 正如文章图片那样,在搜索框中输入想听的音乐/歌手/专辑
- 在输入过程中及输入完成后,显示搜索结果的列表供用户选择
### 材料
- REST 接口
- jquery-autocomplete插件

## 优美的开始
### 准备工作
- 引入插件 css: jquery.autocomplete.css
- 引入插件 js : jquery.autocomplete.min.js
- 写一个数据返回的 REST 接口
### 开始操作
- 定义搜索的 input 的 id 值

``` html
    <div class="navbar-form navbar-left input-s-lg m-t m-l-n-xs hidden-xs">
            <div class="form-group" style="display: inline">
                <div class="input-group">
                <span class="input-group-btn">
                  <button class="btn btn-sm bg-white btn-icon rounded"><i class="fa fa-search"></i></button>
                </span>
                    <input id="keywords" type="text" class="form-control input-sm no-border rounded" placeholder="搜索  单曲/歌手/专辑...">
                </div>
            </div>
    </div>
```

- 这里我定义的是 keywords
- 接下来在我们的 js 文件里调用 : $("#keywords").autocomplete

``` javascript
    $("#keywords").autocomplete("/music/neteaseCloud/search", {
            width : 350, // 提示的宽度，溢出隐藏
            max : 30,// 显示数量
            scrollHeight: 600,
            resultsClass: "ac_results animated fadeInUpBig",
            autoFill : false,//自动填充
            highlight : false,
            highlightItem: true,
            scroll : true,
            matchContains : true,
            multiple :false,
            matchSubset: false,
            dataType: "json",
            formatItem: function(row, i, max) {
                //自定义样式
            },
            formatMatch: function(row, i, max) {
                return row.name + row.id;
            },
            formatResult: function(row) {
                return row.id;
            },
            parse:function(data) {
                //解释返回的数据，把其存在数组里
                if (data.data.length === 0) {
                    return [];
                }else {
                    return $.map(data.data, function(row) {
                        return {
                            data: row
                        }
                    });
                }
    
            }
        }).result(function(event, row, formatted) {
            jQuery(this).val(row.name + ' ' + row.author);
            addSearchResult(row.id);
        });
```

### 接下来重点解释这个配置项
- autocomplete 的第一个参数是url, 值得注意的是,这个 url 我们返回的结果数据是 JSON
- 后面要专门针对返回的 JSON 数据进行解析
- 再往后面来,看到的是一些配置项参数,一些简单的我就不在这多解释了,我这边主要说下我觉得比较重要的
- resultsClass : 这个参数是生成的候选项的父 DIV,如下图所示:

![JoyMedia - AutoComplate-Div](//s3.joylau.cn:9000/blog/jquery-autocomplate-div.png)

- 默认提供的样式很不好看,默认提供的样式都写在 jquery.autocomplete.css 里面
- 在这里面,能看到刚才截图的 div : ac_results
- 那么我们要美化的就是 这个 div 和其子元素 li 的样式了
- 为了跟契合本站的主题,我采用的黑色主题风格
- 给ac_results添加了黑色背景色:background-color: #232c32
- 在js文件里搜索ac_results,添加动画效果,并将这个配置写到配置项里:resultsClass: "ac_results animated fadeInUpBig"
- ul 里的 li 是交替的样式的,class 分别为ac_odd和 ac_even,鼠标滑上去的效果为 ac_over,这几个地方自定义下样式
- 还有一个配置: matchSubset,设置为 false ,可以避免输入大小写转换的js错误
- formatItem : 返回的每一个结果都会再次处理,这里要做的事是以自己想要的样式显示出来
- formatMatch : 匹配自己在结果集中想要的属性
- formatResult : 自己最终要取的数据是什么
- parse : 针对返回的JSON 数据进行转换,这里通过$. map 转化为 数组
- result : 点击了列表项以后要做什么事情

## 完美的结束
>> 欢迎大家来听听试试看!😘 http://music.joylau.cn  (当前版本 v1.3)