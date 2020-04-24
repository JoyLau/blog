#!/bin/bash
echo "Content-Type:text/html"
echo ""
echo "<h1>ok</h1>"
echo "<h3>Prepare to update Blog Posts.....</h3>"
cd /my-blog/blog/
git pull | tee /my-blog/logs/genrate.log
hexo g --debug | tee -a /my-blog/logs/genrate.log