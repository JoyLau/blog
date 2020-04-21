#!/bin/bash
echo "Content-Type:text/html"
echo ""
echo "<h1>ok</h1>"
echo "<h3>republish blog.....</h3>"
cd /my-blog/blog
hexo g --force