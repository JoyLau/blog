---
title: JavaScript 数组的一些常用的方法记录
date: 2017-11-24 09:00:28
description: 记录一些 JavaScript 数组的常用方法,拿来即用,忘了可以查找
categories: [JavaScript篇]
tags: [JavaScript]
---
<!-- more -->
### push 添加最后一项

在数组末尾添加一项，并返回数组的长度, 可以添加任意类型的值作为数组的一项。

``` javascript
    var arr = [1,2];
    arr.push(6)     // arr: [1,2,6]
    arr.push('aa')  // arr: [1,2,6,"aa"]
    arr.push(undefined)  // arr: [1,2,6,"aa",undefined]
    arr.push({a: "A", b: "B"})  // [1,2,6,"aa",undefined,{a: "A", b: "B"}]
```

### unshift 在最前面添加一项

``` javascript
    var arr = [1,2];
    arr.unshift(9)      // [9, 1, 2]
    arr.unshift('aa')   // ['aa',9, 1, 2]
```

### pop 删除最后一项

删除最后一项,并返回删除元素的值；如果数组为空则返回undefine。对数组本身操作

``` javascript
    var arr = [1,2,3,4,5];
    arr.pop()       // arr: [1, 2, 3, 4]
    arr.pop()       // arr: [1, 2, 3]
```

### shift 删除最前面一项

``` javascript
    var arr = [1,2,3,4,5];
    arr.shift()     // [2, 3, 4, 5]
    arr.shift()     // [3, 4, 5]
```

### slice截取(切片)数组 得到截取的数组

不改变原始数组，得到新的数组

slice(start,end)

``` javascript
    var arr = [1,2,3,4,5];
    var a = arr.slice(1)        // a: [2,3,4,5]
    var a = arr.slice(1,3)      // a: [2,3]
    var a = arr.slice(3,4)      // a: [5]
```


### splice剪接数组

改变原数组，可以实现shift前删除，pop后删除,unshift前增加,同push后增加一样的效果。索引从0开始

splice(index,howmany,item1,.....,itemX)

``` javascript
    var arr = [1,2,3,4,5];
    
    push: arr.splice(arr.length, 0, 6)  //  [1, 2, 3, 4, 5, 6]
    unshift: arr.splice(0, 0, 6)        // [6, 1, 2, 3, 4, 5]
    pop: arr.splice(arr.length-1, 1)    // [1, 2, 3, 4]
    shift: arr.splice(0, 1)             // [2, 3, 4, 5]
    
    arr.splice(1)   // [1]
    arr.splice(1, 2)    // [1, 4, 5]
    arr.splice(1, 0, 'A')   // [1, "A",2,3, 4, 5]
    arr.splice(1, 2, 'A', 'B')   // [1, "A", "B", 4, 5]
```

### concat 数组合并

合并后得到新数组，原始数组不改变

``` javascript
    var arr1 = [1,2];
    var arr2 = [3,4,5];
    var arr = arr1.concat(arr2)     // [1,2,3,4,5]
```

### indexOf 数组元素索引

并返回元素索引，不存在返回-1,索引从0开始

``` javascript
    var arr = ['a','b','c','d','e']; 
    arr.indexOf('a');       //0
    arr.indexOf(a);         //-1
    arr.indexOf('f');       //-1
    arr.indexOf('e');       //4
```

### join 数组转字符串

``` javascript
    var a, b;
    a = [0, 1, 2, 3, 4];
    b = a.join("-");    // 0-1-2-3-4
```


### reverse 数组翻转

并返回翻转后的原数组，原数组翻转了

``` javascript
    var a = [1,2,3,4,5]; 
    a.reverse()//a：[5, 4, 3, 2, 1] 返回[5, 4, 3, 2, 1]
```

### 数组里面的对象去重复
``` javascript
    unique(arr){
            let hash = {};
            arr = arr.reduce(function(item, next) {
                if (!hash[next.name]) {
                    item.push(next);
                    hash[next.name] = true;
                }
                return item
            }, []);
            return arr;
        }
```

发现一个比较好的js组件，地址： https://lodash.com/docs/  里面有很多关于对数组的操作