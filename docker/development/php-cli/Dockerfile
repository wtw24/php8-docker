ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-cli-alpine

RUN apk add --no-cache --virtual .build-deps \
        build-base \
        autoconf \
        zlib-dev \
        oniguruma-dev \
        libzip-dev \
        freetype-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        libwebp-dev \
        postgresql-dev \
    && apk add --no-cache \
        tzdata \
        bash \
        curl \
        git \
        unzip \
        linux-headers \
        freetype \
        libpng \
        libjpeg-turbo \
        libwebp \
        mysql-client \
        libpq \
        libzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) gd zip exif pdo_mysql pgsql pdo_pgsql \
    && apk del .build-deps

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
COPY ./php/conf.d /usr/local/etc/php/conf.d

# Xdebug
ARG PHP_VERSION
ARG INSTALL_XDEBUG=false
RUN if [ "${INSTALL_XDEBUG}" = "true" ]; then \
      PHP_MODULE_PREFIX="php$(echo ${PHP_VERSION} | grep -oE '^[0-9]+\.[0-9]+' | tr -d '.')"; \
      apk add --no-cache "${PHP_MODULE_PREFIX}-pecl-xdebug"; \
      echo "zend_extension=/usr/lib/${PHP_MODULE_PREFIX}/modules/xdebug.so" > "$(php-config --ini-dir)/docker-php-ext-xdebug.ini"; \
    fi

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# non-root user
ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=1000
RUN apk add --no-cache shadow \
    && groupmod -o -g ${HOST_GROUP_ID} www-data \
    &&usermod -o -u ${HOST_USER_ID} -g www-data www-data

RUN mkdir -p /home/www-data && chown www-data:www-data /home/www-data \
    && mkdir /app && chown www-data:www-data /app \
    && mkdir -p /home/www-data/.composer/vendor/bin

ENV HOME=/home/www-data
ENV PATH="/home/www-data/.composer/vendor/bin:$PATH"

# Laravel installer
RUN composer global require laravel/installer
ENV COMPOSER_CACHE_DIR=/dev/null

WORKDIR /app

USER www-data