ARG PHP_VERSION=8.4
FROM php:${PHP_VERSION}-cli-alpine

RUN apk add --no-cache \
    tzdata \
    mysql-client \
    bash \
    curl \
    git \
    unzip \
    build-base \
    zlib-dev \
    oniguruma-dev \
    autoconf \
    zip \
    libzip-dev \
    freetype \
    libpng \
    libjpeg-turbo \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    postgresql-dev \
  && apk add --update linux-headers \
  && docker-php-ext-configure zip \
  && docker-php-ext-install pdo_mysql pdo_pgsql pgsql exif zip

# GD
RUN apk add --update --no-cache \
    freetype libpng libjpeg-turbo \
    freetype-dev libpng-dev libjpeg-turbo-dev libwebp-dev \
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
    NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \
    && docker-php-ext-install -j$(nproc) gd \
    && apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

COPY ./php/conf.d /usr/local/etc/php/conf.d

# Xdebug
ARG INSTALL_XDEBUG=false
ARG PHP_VERSION

RUN if [ "${INSTALL_XDEBUG}" = "true" ]; then \
      PHP_MODULE_PREFIX="php$(echo ${PHP_VERSION} | grep -oE '^[0-9]+\.[0-9]+' | tr -d '.')"; \
      apk add --no-cache "${PHP_MODULE_PREFIX}-pecl-xdebug"; \
      echo "zend_extension=/usr/lib/${PHP_MODULE_PREFIX}/modules/xdebug.so" > "$(php-config --ini-dir)/docker-php-ext-xdebug.ini"; \
    fi

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/bin --filename=composer --quiet \
    && rm -rf /root/.composer/cache

# Configure non-root user.
ARG HOST_USER_ID=1000
ARG HOST_GROUP_ID=1000
RUN apk --no-cache add shadow && \
    groupmod -o -g ${HOST_GROUP_ID} www-data && \
    usermod -o -u ${HOST_USER_ID} -g www-data www-data && \
    mkdir -p /home/www-data && \
    chown www-data:www-data /home/www-data

ENV HOME=/home/www-data

# Source code
RUN mkdir /app \
  && chown www-data:www-data /app

WORKDIR /app

# Install Laravel installer globally
RUN composer global require laravel/installer
ENV PATH="/home/www-data/.composer/vendor/bin:$PATH"
ENV COMPOSER_CACHE_DIR=/dev/null

USER www-data