#!/bin/sh
set -e
if [ "$1" = '/my-blog/bash/init.sh' -a "$(id -u)" = '0' ]; then
    service nginx start
    service fcgiwrap start
    echo "☆☆☆☆☆ base service has started. ☆☆☆☆☆"
    exec gosu www-data "$0" "$@"
fi
exec "$@"