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
        icu-dev \
    && apk add --no-cache \
        gdb \
        strace \
        tzdata \
        bash \
        curl \
        git \
        nano \
        unzip \
        linux-headers \
        freetype \
        libpng \
        libjpeg-turbo \
        libwebp \
        mysql-client \
        openssh-client \
        libpq \
        libzip \
        icu-libs \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-configure zip \
    && docker-php-ext-install -j$(nproc) gd zip exif pdo_mysql pgsql pdo_pgsql intl opcache \
    && apk del .build-deps && rm -rf /var/cache/apk/*

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini
COPY ./php/conf.d /usr/local/etc/php/conf.d

# Xdebug
ARG PHP_VERSION
ARG INSTALL_XDEBUG=false
RUN if [ "${INSTALL_XDEBUG}" = "true" ]; then \
      PHP_MODULE_PREFIX="php$(echo ${PHP_VERSION} | grep -oE '^[0-9]+\.[0-9]+' | tr -d '.')"; \
      apk add --no-cache "${PHP_MODULE_PREFIX}-pecl-xdebug" || echo "Xdebug package not found for PHP $PHP_VERSION"; \
      echo "zend_extension=/usr/lib/${PHP_MODULE_PREFIX}/modules/xdebug.so" > "$(php-config --ini-dir)/20-docker-php-ext-xdebug.ini"; \
    fi

# Redis
RUN PHP_MODULE_PREFIX="php$(echo ${PHP_VERSION} | grep -oE '^[0-9]+\.[0-9]+' | tr -d '.')"; \
    apk add --no-cache  \
        lz4-libs \
        "${PHP_MODULE_PREFIX}-pecl-msgpack" \
        "${PHP_MODULE_PREFIX}-pecl-igbinary" \
        "${PHP_MODULE_PREFIX}-pecl-redis" \
    && ln -s "/$(apk info -qL "${PHP_MODULE_PREFIX}-pecl-msgpack" | grep '.so')" "$(php-config --extension-dir)/msgpack.so" \
    && echo 'extension=msgpack.so' > "$(php-config --ini-dir)/10-msgpack.ini" \
    && ln -s "/$(apk info -qL "${PHP_MODULE_PREFIX}-pecl-igbinary" | grep '.so')" "$(php-config --extension-dir)/igbinary.so" \
    && echo 'extension=igbinary.so' > "$(php-config --ini-dir)/10-igbinary.ini" \
    && ln -s "/$(apk info -qL "${PHP_MODULE_PREFIX}-pecl-redis" | grep '.so')" "$(php-config --extension-dir)/redis.so" \
    && echo 'extension=redis.so' > "$(php-config --ini-dir)/20-redis.ini" \
    && rm -rf /tmp/* /var/cache/apk/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV APP_HOME=/app
ENV HOME=/home/www-data

# non-root user
ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=1000
RUN apk add --no-cache shadow \
    && groupmod -o -g ${HOST_GROUP_ID} www-data \
    && usermod -o -u ${HOST_USER_ID} -g www-data www-data

RUN mkdir $APP_HOME \
    && chown www-data:www-data $APP_HOME \
    && mkdir -p $HOME/.composer/vendor/bin \
    && chown -R www-data:www-data $HOME

ENV PATH="$HOME/.composer/vendor/bin:$PATH"

# Symfony CLI
RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.alpine.sh' | distro=alpine version=3.19 bash \
    && apk add symfony-cli

USER www-data

# Laravel installer
RUN COMPOSER_HOME=$HOME/.composer composer global require laravel/installer
ENV COMPOSER_CACHE_DIR=/dev/null

WORKDIR $APP_HOME