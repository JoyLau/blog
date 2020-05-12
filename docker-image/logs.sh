#!/bin/bash
echo "Content-Type: text/html;charset=UTF-8"
echo "Content-Language: zh-CN"
echo ""
echo "<h1>Publish Logs</h1>"
echo "<pre>"
cat /my-blog/logs/genrate.log
echo "</pre>"