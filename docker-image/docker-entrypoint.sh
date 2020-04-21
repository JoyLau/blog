#!/bin/sh
set -e
service nginx start
service fcgiwrap start
echo "☆☆☆☆☆ base service has started. ☆☆☆☆☆"
exec gosu www-data "$@"