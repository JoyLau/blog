---
title: Docker Jenkins 升级步骤
date: 2025-10-13 13:27:39
description: Docker 搭建 Jenkins 如何进行升级以及升级遇到的问题记录
categories: [Docker篇]
tags: [Docker, Jenkins]
---

<!-- more -->

我的 Jenkins 是使用 Docker 部署的，部署的脚本如下:

```yaml
services:
  jenkins:
    image: 192.168.1.231:6117/jenkins/jenkins:2.531-jdk21
    container_name: jenkins
    restart: always
    volumes:
      - ./data:/var/jenkins_home
    ports:
      - 6108:8080
      #- 50000:50000
    
```

### 升级步骤
总体思路
1. 直接从 docker hub 上找最新的镜像包，更改 image 的 jenkins 版本重启升级即可

### 升级问题
绝大部分场景下，更新版本重启后就行了  
我这里遇到一个插件问题，例如:

```shell
jenkins  | java.io.IOException: Failed to load: Folders Plugin (cloudbees-folder 6.1062.v2877b_d6b_b_eeb_)
jenkins  | [LF]>  - Update required: Credentials Plugin (credentials 1389.vd7a_b_f5fa_50a_2) to be updated to 1447.v4cb_b_539b_5321 or higher
jenkins  |      at hudson.PluginWrapper.resolvePluginDependencies(PluginWrapper.java:1020)
jenkins  |      at hudson.PluginManager$2$1$1.run(PluginManager.java:590)
jenkins  |      at org.jvnet.hudson.reactor.TaskGraphBuilder$TaskImpl.run(TaskGraphBuilder.java:175)
jenkins  |      at org.jvnet.hudson.reactor.Reactor.runTask(Reactor.java:304)
jenkins  |      at jenkins.model.Jenkins$5.runTask(Jenkins.java:1152)
jenkins  |      at org.jvnet.hudson.reactor.Reactor$2.run(Reactor.java:221)
jenkins  |      at org.jvnet.hudson.reactor.Reactor$Node.run(Reactor.java:120)
jenkins  |      at jenkins.security.ImpersonatingExecutorService$1.run(ImpersonatingExecutorService.java:68)
jenkins  |      at java.base/java.util.concurrent.ThreadPoolExecutor.runWorker(Unknown Source)
jenkins  |      at java.base/java.util.concurrent.ThreadPoolExecutor$Worker.run(Unknown Source)
jenkins  |      at java.base/java.lang.Thread.run(Unknown Source)
```

这里需要 credentials 插件升级到最少 1447.v4cb_b_539b_5321  
Jenkins 在升级时会自动升级插件的版本，但有时候会遇到一些问题，这时候需要手动解决

1. 去 `https://plugins.jenkins.io/credentials/releases/` 手动下载插件文件
2. 将下载下来的 hpi 文件修改后缀名为 jpi, 并且上传到Jenkins的 plugins 目录下， 并且删除同名的解压目录
3. 重启 Jenkins
4. 再次观察日志，如有其他插件问题，再重复上面的方式解决

### 备份问题
我这边是使用 `ThinBackup` 这个插件的来备份数据的  
但是有个问题，就是这个插件安装后在 Jenkins的后台页面上找不到设置的 UI， 只有 `Backup now` 和 `Restore` 2 个按钮  
后来看插件的文档，（ 注意：从 2.0 版本开始，这些设置存在于全局配置中）  
这里是插件文档: https://plugins.jenkins.io/thinBackup/  

或者可以直接配置插件的配置文件 `org.jvnet.hudson.plugins.thinbackup.ThinBackupPluginImpl.xml`  
我的配置如下:  

```xml
<?xml version='1.1' encoding='UTF-8'?>
<org.jvnet.hudson.plugins.thinbackup.ThinBackupPluginImpl plugin="thinBackup@2.1.3">
  <fullBackupSchedule>10 1 * * *</fullBackupSchedule>
  <diffBackupSchedule></diffBackupSchedule>
  <backupPath>/var/jenkins_home/backup</backupPath>
  <nrMaxStoredFull>1</nrMaxStoredFull>
  <excludedFilesRegex></excludedFilesRegex>
  <waitForIdle>true</waitForIdle>
  <forceQuietModeTimeout>120</forceQuietModeTimeout>
  <cleanupDiff>true</cleanupDiff>
  <moveOldBackupsToZipFile>false</moveOldBackupsToZipFile>
  <backupBuildResults>true</backupBuildResults>
  <backupBuildArchive>false</backupBuildArchive>
  <backupPluginArchives>true</backupPluginArchives>
  <backupUserContents>false</backupUserContents>
  <backupConfigHistory>false</backupConfigHistory>
  <backupAdditionalFiles>false</backupAdditionalFiles>
  <backupAdditionalFilesRegex></backupAdditionalFilesRegex>
  <backupNextBuildNumber>true</backupNextBuildNumber>
  <backupBuildsToKeepOnly>false</backupBuildsToKeepOnly>
  <failFast>true</failFast>
</org.jvnet.hudson.plugins.thinbackup.ThinBackupPluginImpl>
```

