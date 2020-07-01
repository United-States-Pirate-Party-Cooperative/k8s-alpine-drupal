# STAGE 1: Build
FROM alpine:latest AS build

ENV COMPOSER_MEMORY_LIMIT=-1
# Install Stuff
RUN     apk update && \
        apk upgrade && \
        apk add --no-cache \
                bash \
                git \
                php7 \
		php7-fpm \
                php7-dom \
                php7-gd \
                php7-pdo \
                php7-session \
                php7-simplexml \
                php7-tokenizer \
                php7-xml \
                php7-curl \
                php7-xmlwriter \
                php7-json \
		php7-ctype \
		php7-posix \
		php7-soap \
		php7-intl \
		php7-pcntl \
		php7-bz2 \
		php7-pdo \
		php7-pdo_sqlite \
		php7-pdo_odbc \
		php7-pdo_mysql \
		php7-pdo_pgsql \
		yarn \
                nfs-utils \
		libtirpc \
		rpcbind \
		musl \
		openrc \
                composer \
                wget \
                nginx


## Get dependencies for Go part of build
#RUN go get -u github.com/jteeuwen/go-bindata/...
#RUN go get github.com/tools/godep

WORKDIR /var/www

RUN rm -rf /var/www/*
RUN git clone --single-branch --branch 9.0.x https://github.com/drupal/recommended-project.git .
RUN composer update
RUN composer require drush/drush
RUN composer require 'drupal/bfd:^2.54'
RUN git clone https://github.com/thelounge/thelounge

WORKDIR /var/www/thelounge

RUN yarn install
RUN NODE_ENV=production yarn build
RUN yarn link
RUN thelounge start &

WORKDIR /var/www

# loop de loop to keep going
CMD tail -f /dev/null
