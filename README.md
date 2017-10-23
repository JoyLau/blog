## pull
- 1.pull node_modules folder in your project


## 2017年6月11日11:48:35 更新
- npm install hexo-generator-sitemap --save     
- npm install hexo-generator-baidu-sitemap --save
- npm install hexo-html-minifier --save
- npm install hexo-uglify --save
- npm install hexo-clean-css --save
pull node_modules folder in your project


## 2017年6月22日09:46:10 更新

- 更新文件node_modules/hexo-generator-index/lib/generator.js 增加更新提示 在标题添加参数update_o,数值越大越靠前

``` javascript
    if(a.update_o && b.update_o) { // 两篇文章update_o都有定义
                if(a.update_o == b.update_o) return b.date - a.date; // 若update-o值一样则按照文章日期降序排
                else return b.update_o - a.update_o; // 否则按照update_o值降序排
            }
            else if(a.update_o && !b.update_o) { // 以下是只有一篇文章update_o有定义，那么将有update_o的排在前面（这里用异或操作居然不行233）
                return -1;
            }
            else if(!a.update_o && b.update_o) {
                return 1;
            }
```

- 新增new文章功能，可在配置文件里面配置是否开启使用


## 2017年06月24日16:35:10 更新
- 好像忘了安装订阅插件： npm install hexo-generator-feed --save

## 2017年10月23日09:10:23 更新
- npm install hexo-deployer-git --save