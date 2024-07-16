FROM hub.container.24-7to.icu/library/php:8.3.9-fpm-alpine

COPY ./etc /opt/etc
COPY ./bin /opt/bin

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories \
        && apk update \
        && apk upgrade \
        && apk add --no-cache ca-certificates \
        && update-ca-certificates 2>/dev/null || true \
        && apk add --no-cache tzdata \
        && apk add --no-cache pkgconfig gcc g++ make autoconf linux-headers \
        # workdir
        && mkdir -p /opt/www \
        # php setting \
        && cp /opt/etc/php/conf.d/security.ini /usr/local/etc/php/conf.d/security.ini \
        # install php gd
        && apk add zlib-dev libpng-dev libjpeg-turbo-dev freetype-dev libwebp-dev \
        && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
        && docker-php-ext-install -j$(nproc) gd \
        # install pdo_mysql
        && docker-php-ext-install -j$(nproc) pdo_mysql \
        # install pdo_postgresql if need. too big. \
        # && apk add postgresql-dev \
        # && docker-php-ext-install -j$(nproc) pdo_pgsql \
        # install redis
        && pecl install redis-6.0.2 \
        && docker-php-ext-enable redis \
        # install memcached
        && apk add libmemcached-dev openssl-dev zlib-dev \
        && pecl install memcached-3.2.0 \
        && docker-php-ext-enable memcached \
        # install zip \
        && apk add zlib-dev libzip-dev \
        && docker-php-ext-install -j$(nproc) zip \
        # install bcmath \
        && docker-php-ext-install -j$(nproc) bcmath \
        # install pcntl \
        && docker-php-ext-install -j$(nproc) pcntl \
        # install intl, icu, icu data \
        && apk add icu-dev \
        && docker-php-ext-install -j$(nproc) intl \
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
        # nginx \
        && addgroup www \
        && adduser -H -D -G www www\
        && apk add --no-cache nginx \
        && mkdir -p /var/log/nginx \
        && mkdir -p /etc/nginx/conf.d \
        && cp /opt/etc/nginx/nginx.conf /etc/nginx/nginx.conf \
        && cp /opt/etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf \
        # php configure file
        && cp /opt/etc/php-fpm/php-fpm.d/www.conf /usr/local/etc/php-fpm.d/www.conf \
        # clean
        && apk del pkgconfig gcc g++ make autoconf linux-headers \
        && rm -rf /opt/etc \
        && rm -rf /var/cache/apk/* \
        && rm -rf /tmp/* \
        # entrypoint
        && chmod +x /opt/bin/entrypoint.sh


ENV TZ Asia/Shanghai

WORKDIR /opt/www

ENTRYPOINT ["/opt/bin/entrypoint.sh"]
