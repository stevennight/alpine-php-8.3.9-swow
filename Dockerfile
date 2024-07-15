FROM php:8.3.9-fpm-alpine

RUN apk update \
        && apk upgrade \
        && apk add --no-cache ca-certificates \
        && update-ca-certificates 2>/dev/null || true \
        && apk add --no-cache tzdata \
        && apk add --no-cache pkgconfig gcc g++ make autoconf linux-headers \
        # composer
        && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
        && php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
        && php composer-setup.php \
        && php -r "unlink('composer-setup.php');" \
        && mv composer.phar /usr/local/bin/composer \
        # swow
        && mkdir /swowinstall && cd /swowinstall \
        && composer require swow/swow \
        && ./vendor/bin/swow-builder --install \
        && cd / && rm -rf /swowinstall \
        && echo "extension=swow" > $PHP_INI_DIR/conf.d/swow.ini \
        # nginx
        && apk add --no-cache nginx \
        && mkdir -p /var/log/nginx \
        && ln -sf /dev/stdout /var/log/nginx/access.log \
        && ln -sf /dev/stderr /var/log/nginx/error.log \
        && echo "daemon off;" >> /etc/nginx/nginx.conf \
        && mkdir -p /etc/nginx/conf.d \
        && echo "server { listen 80; root /opt/www;  location / { index index.php; } location ~ \.php$ { fastcgi_pass   127.0.0.1:9000; fastcgi_index  index.php; fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name; include fastcgi_params; } }" > /etc/nginx/conf.d/default.conf \
        # clean
        && apk del pkgconfig gcc g++ make autoconf linux-headers \
        # workdir
        && mkdir -p /opt/www

ENV TZ Asia/Shanghai

WORKDIR /opt/www

ENTRYPOINT ["nginx", "-g", "daemon off;"]
# ENTRYPOINT ["php", "-S", "0.0.0.0:13300"]
