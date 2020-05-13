#!/bin/bash
echo "Content-Type: text/html;charset=UTF-8"
echo "Content-Language: zh-CN"
echo ""
echo "<h1>Publish Logs</h1>"
echo "<style>
    pre {
      padding: 7px 12px;
      margin: 10px 0;
      overflow: auto;
      font-size: 13px;
      line-height: 1.5;
      background-color: #f8f8f8;
      border: 1px solid #ddd;
      border-radius: 3px;
    }
    </style>"
echo "<pre>"
cat /my-blog/logs/genrate.log
echo "</pre>"