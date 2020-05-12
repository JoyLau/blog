#!/bin/bash
set -e
if [ "$1" = '/my-blog/bash/init.sh' -a "$(id -u)" = '0' ]; then
  # 设置 fastcgi 的环境变量, 否则在执行时无法读取环境变量, 或者可以配置到 nginx.default.conf 文件里
  echo "fastcgi_param  PUSH_GIT_REPO  $PUSH_GIT_REPO;">>/etc/nginx/fastcgi_params
  echo "fastcgi_param  PUSH_BRANCH  $PUSH_BRANCH;">>/etc/nginx/fastcgi_params
  service nginx start
  service fcgiwrap start
  echo "☆☆☆☆☆ base service has started. ☆☆☆☆☆"
  exec gosu www-data "$0" "$@"
fi
exec "$@"