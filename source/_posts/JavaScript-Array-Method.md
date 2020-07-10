---
title: JavaScript 数组的一些常用的方法整理
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

### arr.forEach(callback)
遍历数组,无return
callback的参数：
value --当前索引的值
index --索引
array --原数组


### arr.map(callback)
映射数组(遍历数组),有return 返回一个新数组
callback的参数： 
value --当前索引的值
index --索引
array --原数组

注意: arr.forEach()和arr.map()的区别 
1. arr.forEach()是和for循环一样，是代替for。arr.map()是修改数组其中的数据，并返回新的数据。
2. arr.forEach() 没有return  arr.map() 有return

### arr.filter(callback)
过滤数组，返回一个满足要求的数组

### arr.every(callback)
依据判断条件，数组的元素是否全满足，若满足则返回ture

```js
    let arr = [1,2,3,4,5]
    let arr1 = arr.every( (i, v) => i < 3)
    console.log(arr1)    // false
    let arr2 = arr.every( (i, v) => i < 10)
    console.log(arr2)    // true
```


### arr.some()
依据判断条件，数组的元素是否有一个满足，若有一个满足则返回ture

```js
    let arr = [1,2,3,4,5]
    let arr1 = arr.some( (i, v) => i < 3)
    console.log(arr1)    // true
    let arr2 = arr.some( (i, v) => i > 10)
    console.log(arr2)    // false
```


### arr.reduce(callback, initialValue)
迭代数组的所有项，累加器，数组中的每个值（从左到右）合并，最终计算为一个值

参数： 
1. callback: 
previousValue 必选 --上一次调用回调返回的值，或者是提供的初始值（initialValue）
currentValue 必选 --数组中当前被处理的数组项
index 可选 --当前数组项在数组中的索引值
array 可选 --原数组

2. initialValue: 可选 --初始值
实行方法：回调函数第一次执行时，preValue 和 curValue 可以是一个值，如果 initialValue 在调用 reduce() 时被提供，那么第一个 preValue 等于 initialValue ，并且curValue 等于数组中的第一个值；如果initialValue 未被提供，那么preValue 等于数组中的第一个值.

```js
    let arr = [0,1,2,3,4]
    let arr1 = arr.reduce((preValue, curValue) => 
        preValue + curValue
    )
    console.log(arr1)    // 10
```



### arr.find(callback)
find的参数为回调函数，回调函数可以接收3个参数，值x、所以i、数组arr，回调函数默认返回值x。

```js
    let arr=[1,2,234,'sdf',-2];
    arr.find(function(x){
        return x<=2;
    })//结果：1，返回第一个符合条件的x值
    arr.find(function(x,i,arr){
        if(x<2){console.log(x,i,arr)}
    })//结果：1 0 [1, 2, 234, "sdf", -2]，-2 4 [1, 2, 234, "sdf", -2]
```

### arr.findIndex(callback)
findIndex和find差不多，不过默认返回的是索引。


### arr.includes()
includes函数与string的includes一样，接收2参数，查询的项以及查询起始位置。

```js
    let arr=[1,2,234,'sdf',-2];
    arr.includes(2);// 结果true，返回布尔值
    arr.includes(20);// 结果：false，返回布尔值
    arr.includes(2,3)//结果：false，返回布尔值
```


### arr.keys()
keys，对数组索引的遍历

```js
    let arr=[1,2,234,'sdf',-2];
    for(let a of arr.keys()){
        console.log(a)
    }//结果：0,1,2,3,4  遍历了数组arr的索引
```


### arr.values()
values, 对数组项的遍历

```js
    let arr=[1,2,234,'sdf',-2];
    for(let a of arr.values()){
        console.log(a)
    }//结果：1,2,234,sdf,-2 遍历了数组arr的值
```


### arr.entries()
entries，对数组键值对的遍历。

```js
    let arr=['w','b'];
    for(let a of arr.entries()){
        console.log(a)
    }//结果：[0,w],[1,b]
    for(let [i,v] of arr.entries()){
        console.log(i,v)
    }//结果：0 w,1 b
```


### arr.fill()
fill方法改变原数组，当第三个参数大于数组长度时候，以最后一位为结束位置。

```js
    let arr=['w','b'];
    arr.fill('i')//结果：['i','i']，改变原数组
    arr.fill('o',1)//结果：['i','o']改变原数组,第二个参数表示填充起始位置
    new Array(3).fill('k').fill('r',1,2)//结果：['k','r','k']，第三个数组表示填充的结束位置
```

### Array.of()
Array.of()方法永远返回一个数组，参数不分类型，只分数量，数量为0返回空数组。

```js
    Array.of('w','i','r')//["w", "i", "r"]返回数组
    Array.of(['w','o'])//[['w','o']]返回嵌套数组
    Array.of(undefined)//[undefined]依然返回数组
    Array.of()//[]返回一个空数组
```


### arr.copyWithin
copyWithin方法接收三个参数，被替换数据的开始处、替换块的开始处、替换块的结束处(不包括);copyWithin(s,m,n).

```js
    ["w", "i", "r"].copyWithin(0)//此时数组不变
    ["w", "i", "r"].copyWithin(1)//["w", "w", "i"],数组从位置1开始被原数组覆盖，只有1之前的项0保持不变
    ["w", "i", "r","b"].copyWithin(1,2)//["w", "r", "b", "b"],索引2到最后的r,b两项分别替换到原数组1开始的各项，当数量不够，变终止
    ["w", "i", "r",'b'].copyWithin(1,2,3)//["w", "r", "r", "b"]，强第1项的i替换为第2项的r
```

### Array.from()
Array.from可以把带有lenght属性类似数组的对象转换为数组，也可以把字符串等可以遍历的对象转换为数组，它接收2个参数，转换对象与回调函数

```js
    Array.from({'0':'w','1':'b',length:2})//["w", "b"],返回数组的长度取决于对象中的length，故此项必须有！
    Array.from({'0':'w','1':'b',length:4})//["w", "b", undefined, undefined],数组后2项没有属性去赋值，故undefined
    Array.from({'0':'w','1':'b',length:1})//["w"],length小于key的数目，按序添加数组
    
    //////////////////////////////
    let divs=document.getElementsByTagName('div');
    Array.from(divs)//返回div元素数组
    Array.from('wbiokr')//["w", "b", "i", "o", "k", "r"]
    Array.from([1,2,3],function(x){
            return x+1})//[2, 3, 4],第二个参数为回调函数
```


### arr.sort(callback)
如果方法没有使用参数，那么将按照字母顺序对数组元素进行排序

```js
    var arr = [
        {name:'zopp',age:0},
        {name:'gpp',age:18},
        {name:'yjj',age:8}
    ];
    var compare = age => {
       return (a,b) => {
           return a[age] - b[age];
       }
    }
    arr.sort(compare(age))
```

### arr.indexOf()
从前往后遍历，返回item在数组中的索引位，如果没有返回-1；通常用来判断数组中有没有某个元素。可以接收两个参数，第一个参数是要查找的项，第二个参数是查找起点位置的索引


### arr.lastIndexOf()
与indexOf一样，区别是从后往前找。


### arr.flat()
数组的成员有时还是数组，Array.prototype.flat()用于将嵌套的数组“拉平”，变成一维数组。该方法返回一个新数组，对原数据没有影响
flat()默认只会“拉平”一层，如果想要“拉平”多层的嵌套数组，可以将flat()方法的参数写成一个整数，表示想要拉平的层数，默认为1

```js
    [1, 2, [3, 4]].flat()
    // [1, 2, 3, 4]
    [1, 2, [3, [4, 5]]].flat()
    // [1, 2, 3, [4, 5]]
    [1, 2, [3, [4, 5]]].flat(2)
    // [1, 2, 3, 4, 5]
```

### arr.flatMap()
flatMap()方法对原数组的每个成员执行一个函数，相当于执行Array.prototype.map(),然后对返回值组成的数组执行flat()方法。该方法返回一个新数组，不改变原数组。

```js
    // 相当于 [[2, 4], [3, 6], [4, 8]].flat()
    [2, 3, 4].flatMap((x) => [x, x * 2])
    // [2, 4, 3, 6, 4, 8]
```

发现一个比较好的js组件，地址： https://www.lodashjs.com/  里面有很多关于对数组的操作