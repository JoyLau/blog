#!/bin/sh
set -e
if [ "$(id -u)" = '0' ]; then
  echo "$0" "$@"
  nginx
	exec gosu www-data "$0" "$@"
fi
echo "$0" "$@"
exec "$@"