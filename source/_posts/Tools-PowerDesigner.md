---
title: PowerDesigner 数据库逆向生成物理模型并显示 Comment 注释
date: 2020-04-27 11:46:01
description: PowerDesigner 数据库逆向生成物理模型并显示 Comment 注释
categories: [Tools篇]
tags: [PowerDesigner]
---

<!-- more -->
### 工具
1. PowerDesigner 16.5

### 注意
使用 PowerDesigner 的原生方式连接各种数据库我遇到很多问题, 于是,这里我都是使用的 JDBC 的方式连接

使用 JDBC 方式连接需要注意一下几点

1. JDK 的版本必须是 32 位的
2. 需要 JDBC 的驱动 jar 包
3. 需要新建 **CLASSPATH** 环境变量, 并且将驱动 jar 包的路径配置到 `CLASSPATH` 中, 否则的话会导致无法加载驱动类


### 步骤
1. File -> New Module, 选择 `Physical Diagram`, DBMS 选择实际的数据库类型
2. 选择 Database -> Configure Connections... -> Connection Profiles , 选择 第二个图标, `add data source`
3. Connections Type 现在 JDBC, 然后根据实际情况填写, 注意最后一项的 `JDBC driver jar files` 的文件需要配置的 CLASSPATH 环境变量中去, 如果已经配置了, 则此项都可以不用选择,亲测
4. 点击测试,没有问题,保存即可
5. 选择 Database -> Update Model from Database , 选择需要的表
6. 此时双击表,可能没有注释, 需要双击表，弹出表属性对话框，切到 ColumnTab ，默认是没显示 Comment 的，此时点击漏斗状的按钮 `Customize Columns and Filter`, 勾选 `Comment`

### 设置物理模型显示注释
1. Tools>Display Perferences..
2. 进入 Table, 先勾选 Comment
3. 再点击 Advanced -> Columns , 点击 List columns 右边的按钮 `select` , 选择上 code, 并将位置调的最上方, 点击确定
4. Tools>Execute Commands>Edit/Run Script.., 执行下面的脚本, 脚本的作用是将 NAME 替换成 COMMENT

```bash
    Option   Explicit   
        ValidationMode   =   True   
        InteractiveMode   =   im_Batch
        Dim blankStr
        blankStr   =   Space(1)
        Dim   mdl   '   the   current   model  
          
        '   get   the   current   active   model   
        Set   mdl   =   ActiveModel   
        If   (mdl   Is   Nothing)   Then   
              MsgBox   "There   is   no   current   Model "   
        ElseIf   Not   mdl.IsKindOf(PdPDM.cls_Model)   Then   
              MsgBox   "The   current   model   is   not   an   Physical   Data   model. "   
        Else   
              ProcessFolder   mdl   
        End   If  
          
        Private   sub   ProcessFolder(folder)   
        On Error Resume Next  
              Dim   Tab   'running     table   
              for   each   Tab   in   folder.tables   
                    if   not   tab.isShortcut   then   
                          tab.name   =   tab.comment  
                          Dim   col   '   running   column   
                          for   each   col   in   tab.columns   
                          if col.comment = "" or replace(col.comment," ", "")="" Then
                                col.name = blankStr
                                blankStr = blankStr & Space(1)
                          else  
                                col.name = col.comment   
                          end if  
                          next   
                    end   if   
              next  
          
              Dim   view   'running   view   
              for   each   view   in   folder.Views   
                    if   not   view.isShortcut   then   
                          view.name   =   view.comment   
                    end   if   
              next  
          
              '   go   into   the   sub-packages   
              Dim   f   '   running   folder   
              For   Each   f   In   folder.Packages   
                    if   not   f.IsShortcut   then   
                          ProcessFolder   f   
                    end   if   
              Next   
        end   sub  
```