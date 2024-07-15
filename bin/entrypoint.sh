#!/bin/sh
/usr/local/sbin/php-fpm -D
nginx -g "daemon off;"