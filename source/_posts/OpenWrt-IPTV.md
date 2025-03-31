---
title: OpenWrt --- 抓包电信 IPTV，组播转单播观看
date: 2025-03-31 10:03:09
description: OpenWrt 抓包电信 IPTV，组播转单播观看
categories: [ OpenWrt篇 ]
tags: [ OpenWrt ]
---

# 网络拓扑图
![iptv1](https://s3.joylau.cn:9000/blog/openwrt-iptv-1.png)


# 网络接口配置
1. 进入网络-接口-设备 配置， 对 br-lan 进行编辑， 去掉网桥端口 lan3 (因为要和 wan 进行桥接)
2. 新建设备 my-br, 选择设备 wan 和 lan 3
3. 新建接口 iptv, 设备选择刚才创建的 my-br, 协议选择静态IP 地址， 输入一个和现在内网网段不冲突的网段地址，我这里是 192.168.67.1/24

# udpxy 组播转单播
openwrt 安装 **luci-app-udpxy**, 配置如下:
1. Bind IP/Interface: 0.0.0.0
2. 端口: 4022
3. Source IP/Interface: 192.168.67.1
4. 已启用： 勾选

<!-- more -->

确认服务成功运行可以访问 `host:port/status` 查看状态

# 抓包
opkg 安装 tcpdump, 从机顶盒开机开始抓包，抓包命令

```shell
tcpdump -i iptv -s 0 -w /tmp/iptv.pcap
```

将文件下载到本地, 参考这篇文章的教程提取出 frameset_builder.jsp 文件 （注意中文编码的转换）  
https://post.smzdm.com/p/a785k2z9/  

（frameset_builder.jsp 里面有 rtsp 的单播地址，可以打开直接观看，只要是电信网络环境就可以，只不过参数很长，还有一些身份和认证的参数，不好公开分享）  

再使用下面的网页将组播地址批量替换成单播地址

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>FrameSet Builder 分析工具</title>
</head>
<body>
  <h2>上传 frameset_builder.jsp 文件</h2>
  <input type="file" id="fileInput" accept=".jsp">
  
  <h3>可选参数</h3>
  <label for="localIp">本地 IP: </label>
  <input type="text" id="localIp" placeholder="例如 192.168.11.1">
  <br>
  <label for="portInput">端口号: </label>
  <input type="text" id="portInput" placeholder="例如 8888">
  
  <br><br>
  <button id="processButton">分析文件</button>
  
  <h3>分析结果</h3>
  <pre id="output"></pre>

  <h3>下载选项</h3>
  <label>
    <input type="radio" name="downloadFormat" value="txt" checked> iptv.txt
  </label>
  <label>
    <input type="radio" name="downloadFormat" value="m3u"> iptv.m3u
  </label>
  <br><br>
  <button id="downloadButton">下载文件</button>
  
  <script>
    // 全局变量，用于存储解析后的记录
    let records = [];
    
    document.getElementById('processButton').addEventListener('click', function() {
      const fileInput = document.getElementById('fileInput');
      if (!fileInput.files || fileInput.files.length === 0) {
        alert('请先选择一个文件');
        return;
      }
      const file = fileInput.files[0];
      const reader = new FileReader();
      
      reader.onload = function(e) {
        try {
          const content = e.target.result;
          // 清空之前的记录
          records = [];
          // 正则表达式匹配格式：ChannelName="...",UserChannelID="...",ChannelURL="..."
          const regex = /ChannelName="([^"]+)"\s*,\s*UserChannelID="([^"]+)"\s*,\s*ChannelURL="([^"]+)"/g;
          let match;
          
          // 获取本地IP和端口参数
          const localIp = document.getElementById('localIp').value.trim();
          const port = document.getElementById('portInput').value.trim();
          
          // 简单验证 IP 和端口号
          const ipRegex = /^(25[0-5]|2[0-4]\d|[01]?\d?\d)(\.(25[0-5]|2[0-4]\d|[01]?\d?\d)){3}$/;
          const ipValid = localIp && ipRegex.test(localIp);
          let portValid = false;
          if (port && /^\d+$/.test(port)) {
            const portNum = parseInt(port, 10);
            if (portNum >= 1 && portNum <= 65535) {
              portValid = true;
            }
          }
          // 当且仅当 IP 与端口都有效时进行转换
          const transform = ipValid && portValid;
          
          while ((match = regex.exec(content)) !== null) {
            let channelName = match[1];
            let channelUrl = match[3];
            if (transform && channelUrl.startsWith("igmp://")) {
              // 移除 igmp:// 前缀，构造新的 URL 格式为 http://本地IP:端口/udp/剩余部分
              const rest = channelUrl.substring("igmp://".length);
              channelUrl = "http://" + localIp + ":" + port + "/udp/" + rest;
            }
            records.push({ channelName, channelUrl });
          }
          
          // 排序规则：
          // 1. 若 ChannelName 包含 "HD" 或 "4K"（不区分大小写）的记录排在前面（rank=0），否则 rank=1；
          // 2. 同组内按 ChannelName 降序排列（即 Z 到 A）。
          records.sort((a, b) => {
            const getRank = name => {
              const upper = name.toUpperCase();
              return (upper.includes("HD") || upper.includes("4K")) ? 0 : 1;
            };
            const rankA = getRank(a.channelName);
            const rankB = getRank(b.channelName);
            if (rankA !== rankB) {
              return rankA - rankB;
            }
            return b.channelName.localeCompare(a.channelName);
          });
          
          let outputStr = "";
          if (records.length === 0) {
            outputStr = "未找到匹配的记录。";
          } else {
            records.forEach(record => {
              outputStr += record.channelName + "，" + record.channelUrl + "\n";
            });
          }
          document.getElementById('output').textContent = outputStr;
        } catch (error) {
          console.error("解析文件时出错：", error);
          document.getElementById('output').textContent = "解析文件时出错。";
        }
      };
      
      reader.onerror = function(e) {
        alert("读取文件出错");
      };
      
      // 指定编码为 UTF-8，如文件编码不是 UTF-8，请修改为相应编码（如："GBK"）
      reader.readAsText(file, "UTF-8");
    });
    
    document.getElementById('downloadButton').addEventListener('click', function() {
      if (records.length === 0) {
        alert("没有可下载的内容，请先分析文件。");
        return;
      }
      const format = document.querySelector('input[name="downloadFormat"]:checked').value;
      let content = "";
      let filename = "";
      
      if (format === "txt") {
        // 每条记录一行，格式为：ChannelName，ChannelURL
        records.forEach(record => {
          content += record.channelName + "，" + record.channelUrl + "\n";
        });
        filename = "iptv.txt";
      } else if (format === "m3u") {
        // m3u 格式：第一行为 #EXTM3U，然后每条记录两行
        content = "#EXTM3U\n";
        records.forEach(record => {
          content += "#EXTINF:-1," + record.channelName + "\n" + record.channelUrl + "\n";
        });
        filename = "playlist.m3u";
      }
      
      const blob = new Blob([content], { type: "text/plain;charset=utf-8" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    });
  </script>
</body>
</html>
```

本地 IP 和 本地端口填写 udpxy 的配置

# m3u文件
最后整理成 m3u 文件 [playlist.m3u](https://s3.joylau.cn:9000/blog/playlist.m3u)  
然后就可以到电视端或者手机端导入观看了

# 总结
关于组播
1. 路由设置好组播放功能，直接用播放器播放此格式源 rtp://225.1.4.73:1102 就能本地网能任意观看
2. 路由设置好组播放功能，用播放器播放此格式源http://192.168.1.1:2222/rtp/225.1.4.73:1102 就能本地网能任意观看。
3. 路由设置好组播放功能并有公网IP或区域网名，可通花生壳等工具做成外网，即就可以在有网络下，在哪都能观看，不受限与本地网络（家）

(https://www.right.com.cn/forum/thread-8261285-1-1.html)


