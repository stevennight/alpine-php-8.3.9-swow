#!/bin/sh
/usr/local/sbin/php-fpm -D
nginx -g "daemon off;"
#php -S 0.0.0.0:8080