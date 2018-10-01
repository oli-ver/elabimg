# elabftw + nginx + php-fpm in a container
FROM alpine:3.7

# select version or branch here
ENV ELABFTW_VERSION hypernext

# this is versioning for the container image
ENV ELABIMG_VERSION 1.0.0

ENV NGINX_VERSION 1.14.0
ENV PCRE_VERSION 8.42
ENV OPENSSL_VERSION 1.1.1
ENV ZLIB_VERSION 1.2.11

LABEL org.label-schema.name="elabftw" \
    org.label-schema.description="Run nginx and php-fpm to serve elabftw" \
    org.label-schema.url="https://www.elabftw.net" \
    org.label-schema.vcs-url="https://github.com/elabftw/elabimg" \
    org.label-schema.version=$ELABFTW_VERSION \
    org.label-schema.maintainer="nicolas.carpi@curie.fr" \
    org.label-schema.schema-version="1.0"

# install php-fpm and friends
# php7-gd is required by mpdf for transparent png
# don't put line comments inside this instruction
RUN apk upgrade -U -a && apk add --update \
    autoconf \
    bash \
    build-base \
    coreutils \
    curl \
    freetype \
    ghostscript \
    git \
    graphicsmagick-dev \
    openssl \
    libtool \
    linux-headers \
    openjdk8-jre \
    php7 \
    php7-curl \
    php7-ctype \
    php7-dev \
    php7-dom \
    php7-gd \
    php7-gettext \
    php7-fileinfo \
    php7-fpm \
    php7-json \
    php7-mbstring \
    php7-mcrypt \
    php7-opcache \
    php7-openssl \
    php7-pdo_mysql \
    php7-pear \
    php7-phar \
    php7-session \
    php7-zip \
    php7-zlib \
    yarn \
    supervisor && \
    pecl install gmagick-2.0.4RC1 && echo "extension=gmagick.so" >> /etc/php7/php.ini

# now build nginx
# TODO sha512sum andor gpg verif
WORKDIR /tmp
RUN curl -sS https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tgz && tar xf nginx.tgz && curl -sS https://www.zlib.net/zlib-$ZLIB_VERSION.tar.gz -o zlib.tgz && tar xf zlib.tgz && curl -sS https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz -o openssl.tgz && tar xf openssl.tgz && curl -sS https://ftp.pcre.org/pub/pcre/pcre-$PCRE_VERSION.tar.gz -o pcre.tgz && tar xf pcre.tgz

RUN addgroup -g 101 nginx && adduser -s /bin/false -G nginx -D -H -u 100 nginx && adduser nginx nginx && cd nginx-$NGINX_VERSION && ./configure \
    --prefix=/var/lib/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/run/nginx/nginx.pid \
    --lock-path=/run/nginx/nginx.lock \
    --user=nginx --group=nginx \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_gzip_static_module \
    --with-pcre=/tmp/pcre-$PCRE_VERSION \
    --with-pcre-jit \
    --with-openssl=/tmp/openssl-$OPENSSL_VERSION \
    --with-zlib=/tmp/zlib-$ZLIB_VERSION && make && make install

RUN apk del autoconf build-base libtool php7-dev && rm -rf /var/cache/apk/*

# clone elabftw repository in /elabftw
RUN git clone --depth 1 -b $ELABFTW_VERSION https://github.com/elabftw/elabftw.git /elabftw && chown -R nginx:nginx /elabftw

WORKDIR /elabftw

# install composer
RUN echo "$(curl -sS https://composer.github.io/installer.sig) -" > composer-setup.php.sig \
    && curl -sS https://getcomposer.org/installer | tee composer-setup.php | sha384sum -c composer-setup.php.sig \
    && php composer-setup.php && rm composer-setup.php*

# install dependencies
RUN /elabftw/composer.phar install --no-dev -a && yarn install --pure-lockfile && yarn run buildall && rm -rf node_modules && yarn cache clean && /elabftw/composer.phar clear-cache

# nginx will run on port 443
EXPOSE 443

# copy configuration and run script
COPY ./src/nginx/ /etc/nginx/
COPY ./src/supervisord.conf /etc/supervisord.conf
COPY ./src/run.sh /run.sh

# start
CMD ["/run.sh"]

# define mountable directories
VOLUME /elabftw
VOLUME /ssl
