---
title: IntelliJ IDEA 插件开发
date: 2017-4-28 11:32:10
cover: //image.joylau.cn/blog/IntelliJIDEA-Plugins.png
description: 以前经常使用的一款翻译插件，近几天发现突然不好用了，时行时不行的.....是时候得 看一些问题了.....
categories: [IntelliJ IDEA篇]
tags: [IntelliJ IDEA,Plugins]
---

<!-- more -->
![IntelliJIDEA-Plugins](//image.joylau.cn/blog/IntelliJIDEA-Plugins.png)

## 说明
我现在用的这个插件时ECTranslation,是用于做中英文翻译的，可以在看文档和注释的是方便的使用，然而近期变得不好用了
- 翻译的内容有时能出来，有时出不来，有时甚至没有反应
- **查看了该款插件的源代码，发现是调用的有道翻译的API接口，而且在代码里写死了APIkey和KeyFrom**
- 调用了有道的API，加上上面作者提供的Key，再传入翻译的文本内容，发现返回值居然是请求次数过多，被封禁了.....
- 明白了，很多使用这个插件的开发者都是用的作者提供的默认Key，默认情况下1小时请求的限制次数是1000次
- 肯定是次数超了
- **但是他的配置信息是写在代码里的，能配置到IDEA的面板上供使用者自己配置就好了**
- 于是我有了自己动手的想法


## 开始项目
第一步创建IDEA插件项目：
![IntelliJIDEA-Build](//image.joylau.cn/blog/IntelliJIDEA-Build.png)
第二步目录结构如下图所示：
![IntelliJIDEA-Folder](//image.joylau.cn/blog/IntelliJIDEA-folder.png)


## 项目配置

### plugin.xml
看代码，相信能看懂的：
``` xml
    <idea-plugin>
      <id>cn.joylau.plugins.translation</id>
      <name>joylau-translation</name>
      <version>1.0</version>
      <vendor email="2587038142.liu@gmail" url="http://www.joylau.cn">JoyLau</vendor>
    
      <description><![CDATA[
          Plugin for translate English to Chinese.<br>
          <li>1. Choose the word you want translate.</li>
          <li>2. Press Ctrl + NUMPAD0.</li>
          <li>3. Fork ECTranslation Change ApiKey and KeyFrom</li>
    
        ]]></description>
    
      <change-notes><![CDATA[
          <li>Change ApiKey and KeyFrom for myself</li>
          <li>Change KeyMap to Ctrl + NumPad 0</li>
        ]]>
      </change-notes>
    
      <!-- please see http://www.jetbrains.org/intellij/sdk/docs/basics/getting_started/build_number_ranges.html for description -->
      <idea-version since-build="141.0"/>
    
      <!-- please see http://www.jetbrains.org/intellij/sdk/docs/basics/getting_started/plugin_compatibility.html
           on how to target different products -->
      <!-- uncomment to enable plugin in all products
      <depends>com.intellij.modules.lang</depends>
      -->
    
      <extensions defaultExtensionNs="com.intellij">
        <!-- Add your extensions here -->
      </extensions>
    
      <actions>
        <!-- Add your actions here -->
        <action id="ECTranslation" class="cn.joylau.plugins.translation.ECTranslation" text="Translate">
          <add-to-group group-id="EditMenu" anchor="first"/>
          <add-to-group group-id="EditorPopupMenu" anchor="first"/>
          <keyboard-shortcut keymap="$default" first-keystroke="ctrl NUMPAD0"/>
        </action>
      </actions>
    
    </idea-plugin>
```

只有一个action ，调用的类是`ECTranslation`，快捷键设置的`ctrl + NumPad 0`


## 最后

**_代码都是人家的，我就没好意思往IDEA的仓库里上传了..._**

>> 如果你想使用这个插件： [点击查看](https://github.com/JoyLau/joylau-translation/releases)  或  [点击下载](http://image.joylau.cn/plugins/joylau-translation.1.0.REALEASE.jar)