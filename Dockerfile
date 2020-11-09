# STAGE 1: Build
FROM alpine:latest AS build

ENV COMPOSER_MEMORY_LIMIT=-1
# Install Stuff
RUN     apk update && \
				apk upgrade && \
				apk add --no-cache \
					bash \
					git \
					nfs-utils \
					net-snmp \
					mysql-client \
					util-linux \
					php7 \
					php7-fpm \
					php7-dom \
					php7-gd \
					php7-pdo \
					php7-pdo_mysql \
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
					php7-bz2 \
					php7-mysqli \
					unit \
					unit-php7 \
					certbot \
					vim \
					su-exec \
					net-tools \
					rpcbind \
					musl \
					openrc \
					composer \
					wget \
					npm


# install other stuff
RUN npm init --yes
RUN npm install -g npm@latest
RUN npm install -g n
RUN n latest
RUN npm install -g yarn
RUN npm install -g bowser
##

#
#RUN mv /var/www /var/Owww
# ensure www-data user exists
RUN set -x ; \
  addgroup -g 82 -S www-data ; \
  adduser -u 82 -h /var/www -s /bin/bash -D -G www-data www-data && exit 0 ; exit 1
#RUN mkdir /var/www
RUN chown www-data:www-data /var/www
#RUN usermod -s /bin/bash www-data

WORKDIR /var/www

RUN ls -lar
RUN /sbin/su-exec www-data:www-data git clone --single-branch --branch 9.0.x https://github.com/drupal/recommended-project.git drupal
#
WORKDIR /var/www/drupal
RUN /sbin/su-exec www-data:www-data composer update
RUN /sbin/su-exec www-data:www-data composer require drush/drush
RUN /sbin/su-exec www-data:www-data composer require civicrm/civicrm-asset-plugin civicrm/civicrm-drupal-8 civicrm/civicrm-packages
RUN /sbin/su-exec www-data:www-data composer require "drupal/bfd:^2.54"
RUN /sbin/su-exec www-data:www-data composer require "drupal/qwebirc:^1.0"
#
WORKDIR /var/www

# Expose HTTP.
ENV PORT 80
EXPOSE ${PORT}
# Expose HTTPS.
ENV HTTPS_PORT 443
EXPOSE ${HTTPS_PORT}

WORKDIR /var
RUN mv /var/www /var/Owww
RUN mkdir /var/www
RUN chown www-data:www-data /var/www

ENV NODE_ENV production

ENV THELOUNGE_HOME "/var/opt/thelounge"
VOLUME "${THELOUNGE_HOME}"

# Expose HTTP.
ENV PORT 9000
EXPOSE ${PORT}

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["thelounge", "start"]

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Install thelounge.
ARG THELOUNGE_VERSION=4.2.0
RUN yarn --non-interactive --frozen-lockfile global add thelounge@${THELOUNGE_VERSION} && \
    yarn --non-interactive cache clean
# need nginx config.
#

# loop de loop to keep going
CMD tail -f /dev/null
