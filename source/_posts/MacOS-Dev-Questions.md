---
title: MacOS 开发问题备忘记录
date: 2020-12-08 15:29:08
description: 记录一下自己平时使用 MacOS 开发遇到的一些问题以及一些配置信息备忘
categories: [MacOS篇]
tags: [MacOS,MacBookPro]
---

<!-- more -->

### 清理 brew
1. brew cleanup
2. brew cleanup --prune 1 #清理早于 1 天的

### 防止 mac 锁屏后关闭显示器的方法
brew cask install keepingyouawake

### zsh 对 docker 命令的自动提示
1. 首先确定安装好了 oh-my-zsh
2. 在文件 **~/.zshrc** 文件中启用 docker docker-compose, 下面是我启用的插件

参考: https://docs.docker.com/compose/completion/


```bash
    plugins=(git gradle mvn node npm brew yarn docker docker-compose)
```

### zsh 插件推荐
1. 自动补全插件 zsh-autosuggestions

这里利用Oh my zsh的方法安装。直接一句话命令行里下载并移动到 oh my zsh 目录中：

```bash
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
```

然后在 ~/.zshrc 文件中找到 plugins 数组，加入 zsh-autosuggestions 名字，重新打开终端即可。

2. 语法高亮插件 zsh-syntax-highlighting

将插件下载到oh my zsh的插件目录下的该新建插件同名文件夹中

```shell 
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
```

编辑 ~/.zshrc 文件将然后将插件引用命令写入该文件最后一行（必须）

```bash 
    source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
```

保存重新打开即可看到高亮的命令行了。


