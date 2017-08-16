FROM alpine:3.5
MAINTAINER mail@racktear.com

RUN addgroup -S tarantool \
    && adduser -S -G tarantool tarantool \
    && apk add --no-cache 'su-exec>=0.2'

ENV TARANTOOL_VERSION=1.7.4-329-g2e4b6fddf \
    TARANTOOL_DOWNLOAD_URL=https://github.com/tarantool/tarantool.git \
    TARANTOOL_INSTALL_LUADIR=/usr/local/share/tarantool \
    GPERFTOOLS_REPO=https://github.com/gperftools/gperftools.git \
    GPERFTOOLS_TAG=gperftools-2.5 \
    LUAROCKS_URL=http://keplerproject.github.io/luarocks/releases/luarocks-2.3.0.tar.gz \
    LUAROCK_AVRO_SCHEMA_REPO=https://github.com/tarantool/avro-schema.git \
    LUAROCK_AVRO_SCHEMA_TAG=b49efa8 \
    LUAROCK_EXPIRATIOND_REPO=https://github.com/tarantool/expirationd.git \
    LUAROCK_EXPIRATIOND_TAG=9ec22b6 \
    LUAROCK_QUEUE_REPO=https://github.com/tarantool/queue.git \
    LUAROCK_QUEUE_TAG=24d730c \
    LUAROCK_CONNPOOL_REPO=https://github.com/tarantool/connpool.git \
    LUAROCK_CONNPOOL_TAG=89c2fe4 \
    LUAROCK_SHARD_REPO=https://github.com/tarantool/shard.git \
    LUAROCK_SHARD_TAG=8f8c5a7 \
    LUAROCK_HTTP_REPO=https://github.com/tarantool/http.git \
    LUAROCK_HTTP_TAG=67d8a9b \
    LUAROCK_PG_REPO=https://github.com/tarantool/pg.git \
    LUAROCK_PG_TAG=8bb4164 \
    LUAROCK_MYSQL_REPO=https://github.com/tarantool/mysql.git \
    LUAROCK_MYSQL_TAG=3203633 \
    LUAROCK_MEMCACHED_REPO=https://github.com/tarantool/memcached.git \
    LUAROCK_MEMCACHED_TAG=7aa78b2 \
    LUAROCK_TARANTOOL_PROMETHEUS_REPO=https://github.com/tarantool/prometheus.git \
    LUAROCK_TARANTOOL_PROMETHEUS_TAG=0654304 \
    LUAROCK_TARANTOOL_CURL_REPO=https://github.com/tarantool/curl.git \
    LUAROCK_TARANTOOL_CURL_TAG=2.2.7 \
    LUAROCK_MQTT_REPO=https://github.com/tarantool/mqtt.git \
    LUAROCK_MQTT_TAG=238fd2e \
    LUAROCK_TARANTOOL_GIS_REPO=https://github.com/tarantool/gis.git \
    LUAROCK_TARANTOOL_GIS_TAG=25209fc \
    LUAROCK_GPERFTOOLS_REPO=https://github.com/tarantool/gperftools.git \
    LUAROCK_GPERFTOOLS_TAG=12a7ac2

COPY gperftools_alpine.diff /

RUN set -x \
    && apk add --no-cache --virtual .run-deps \
        libstdc++ \
        readline \
        libressl \
        yaml \
        lz4 \
        binutils \
        ncurses \
        libgomp \
        lua \
        curl \
        tar \
        zip \
        libunwind \
        libcurl \
    && apk add --no-cache --virtual .build-deps \
        perl \
        gcc \
        g++ \
        cmake \
        readline-dev \
        libressl-dev \
        yaml-dev \
        lz4-dev \
        binutils-dev \
        ncurses-dev \
        lua-dev \
        musl-dev \
        make \
        git \
        libunwind-dev \
        autoconf \
        automake \
        libtool \
        linux-headers \
        go \
        curl-dev \
    && : "---------- gperftools ----------" \
    && mkdir -p /usr/src/gperftools \
    && git clone "$GPERFTOOLS_REPO" /usr/src/gperftools \
    && git -C /usr/src/gperftools checkout "$GPERFTOOLS_TAG" \
    && (cd /usr/src/gperftools; \
        patch -p1 < /gperftools_alpine.diff; \
        rm /gperftools_alpine.diff; \
        ./autogen.sh; \
        ./configure; \
        make; \
        cp .libs/libprofiler.so* /usr/local/lib;) \
    && (GOPATH=/usr/src/go go get github.com/google/pprof; \
        cp /usr/src/go/bin/pprof /usr/local/bin) \
    && : "---------- tarantool ----------" \
    && mkdir -p /usr/src/tarantool \
    && git clone "$TARANTOOL_DOWNLOAD_URL" /usr/src/tarantool \
    && git -C /usr/src/tarantool checkout "$TARANTOOL_VERSION" \
    && git -C /usr/src/tarantool submodule update --init --recursive \
    && (cd /usr/src/tarantool; \
       cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo\
             -DENABLE_BUNDLED_LIBYAML:BOOL=OFF\
             -DENABLE_BACKTRACE:BOOL=ON\
             -DENABLE_DIST:BOOL=ON\
             .) \
    && make -C /usr/src/tarantool -j\
    && make -C /usr/src/tarantool install \
    && make -C /usr/src/tarantool clean \
    && : "---------- small ----------" \
    && (cd /usr/src/tarantool/src/lib/small; \
        cmake -DCMAKE_INSTALL_PREFIX=/usr \
              -DCMAKE_INSTALL_LIBDIR=lib \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              .) \
    && make -C /usr/src/tarantool/src/lib/small \
    && make -C /usr/src/tarantool/src/lib/small install \
    && make -C /usr/src/tarantool/src/lib/small clean \
    && : "---------- msgpuck ----------" \
    && (cd /usr/src/tarantool/src/lib/msgpuck; \
        cmake -DCMAKE_INSTALL_PREFIX=/usr \
              -DCMAKE_INSTALL_LIBDIR=lib \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              .) \
    && make -C /usr/src/tarantool/src/lib/msgpuck \
    && make -C /usr/src/tarantool/src/lib/msgpuck install \
    && make -C /usr/src/tarantool/src/lib/msgpuck clean \
    && : "---------- luarocks ----------" \
    && wget -O luarocks.tar.gz "$LUAROCKS_URL" \
    && mkdir -p /usr/src/luarocks \
    && tar -xzf luarocks.tar.gz -C /usr/src/luarocks --strip-components=1 \
    && (cd /usr/src/luarocks; \
        ./configure; \
        make build; \
        make install) \
    && rm -r /usr/src/luarocks \
    && rm -rf /usr/src/tarantool \
    && rm -rf /usr/src/gperftools \
    && rm -rf /usr/src/go \
    && : "---------- remove build deps ----------" \
    && apk del .build-deps

COPY luarocks-config.lua /usr/local/etc/luarocks/config-5.1.lua

RUN set -x \
    && apk add --no-cache --virtual .run-deps \
        mariadb-client-libs \
        libpq \
        cyrus-sasl \
        mosquitto-libs \
        libev \
    && apk add --no-cache --virtual .build-deps \
        git \
        cmake \
        make \
        coreutils \
        gcc \
        g++ \
        postgresql-dev \
        lua-dev \
        musl-dev \
        cyrus-sasl-dev \
        curl-dev \
        mosquitto-dev \
        libev-dev \
    && mkdir -p /rocks \
    && : "---------- luarocks ----------" \
    && luarocks install lua-term \

    && : "gperftools" \
    && git clone $LUAROCK_GPERFTOOLS_REPO /rocks/gperftools \
    && git -C /rocks/gperftools checkout $LUAROCK_GPERFTOOLS_TAG \
    && (cd /rocks/gperftools && luarocks make *rockspec) \
    && : "---------- remove build deps ----------" \
    && apk del .build-deps \
    && rm -rf /rocks

RUN mkdir -p /var/lib/tarantool \
    && chown tarantool:tarantool /var/lib/tarantool \
    && mkdir -p /opt/tarantool \
    && chown tarantool:tarantool /opt/tarantool \
    && mkdir -p /var/run/tarantool \
    && chown tarantool:tarantool /var/run/tarantool \
    && mkdir /etc/tarantool \
    && chown tarantool:tarantool /etc/tarantool


RUN addgroup -S nginx \
    && adduser -S -G nginx nginx \
    && apk add --no-cache 'su-exec>=0.2'


ENV NGINX_VERSION=1.11.1 \
    NGINX_UPSTREAM_MODULE_URL=https://github.com/tarantool/nginx_upstream_module.git \
    NGINX_UPSTREAM_MODULE_COMMIT=863e9bdd0ebbf94c0b5449cdbf686b316ba674b8 \
    NGINX_GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8

ENV NGINX_LUA_MODULE_URL=https://github.com/openresty/lua-nginx-module \
    NGINX_LUA_MODULE_PATH=/usr/src/lua-nginx-module

ENV NGINX_DEVEL_KIT_URL=https://github.com/simpl/ngx_devel_kit \
    NGINX_DEVEL_KIT_PATH=/usr/src/nginx-devel-kit

ENV LUAJIT_VERSION=2.0.5 \
    LUAJIT_URL=http://luajit.org/git/luajit-2.0.git \
    LUAJIT_PATH=/usr/src/luajit \
    LUAJIT_LIB=/usr/local/lib \
    LUAJIT_INC=/usr/local/include/luajit-2.0

ENV LUAROCKS_VERSION=2.4.2 \
    LUAROCKS_URL=https://github.com/luarocks/luarocks \
    LUAROCKS_PATH=/usr/src/luarocks

ENV LUAROCKS_ROCKS="\
lua-cjson\
"

RUN set -x \
  && apk add --no-cache --virtual .build-deps \
     build-base \
     cmake \
     linux-headers \
     libressl-dev \
     pcre-dev \
     zlib-dev \
     libxslt-dev \
     gd-dev \
     geoip-dev \
     git \
     tar \
     gnupg \
     curl \
     perl-dev \
     unzip \
     gcc \
     perl \
  && apk add --no-cache --virtual .run-deps \
     ca-certificates \
     libressl \
     pcre \
     zlib \
     libxslt \
     gd \
     geoip \
     gettext \
     libgcc \
  && git config --global http.postBuffer 524288000 \
  && : "---------- download nginx-devel-kit ----------" \
  && git clone "$NGINX_DEVEL_KIT_URL" $NGINX_DEVEL_KIT_PATH \
  && : "---------- download nginx-lua-module ----------" \
  && git clone "$NGINX_LUA_MODULE_URL" $NGINX_LUA_MODULE_PATH \
  && : "---------- download luajit ----------" \
  && git clone "$LUAJIT_URL" $LUAJIT_PATH \
  && git -C $LUAJIT_PATH checkout tags/v$LUAJIT_VERSION \
  && make -C $LUAJIT_PATH \
  && make -C $LUAJIT_PATH install \
  && : "---------- download and install luarocks (depends on luajit) ----------" \
  && git clone $LUAROCKS_URL $LUAROCKS_PATH \
  && git -C $LUAROCKS_PATH checkout tags/v$LUAROCKS_VERSION \
  && ln -s /usr/local/bin/luajit-$LUAJIT_VERSION /usr/local/bin/lua \
  && cd $LUAROCKS_PATH \
  && ./configure --with-lua-bin=/usr/local/bin --with-lua-include=/usr/src/luajit/src/ \
  && make build \
  && make install \
  && cd \
  && : "---------- download nginx-upstream-module ----------" \
  && git clone "$NGINX_UPSTREAM_MODULE_URL" /usr/src/nginx_upstream_module \
  && git -C /usr/src/nginx_upstream_module checkout "${NGINX_UPSTREAM_MODULE_COMMIT}" \
  && git -C /usr/src/nginx_upstream_module submodule init \
  && git -C /usr/src/nginx_upstream_module submodule update \
  && make -C /usr/src/nginx_upstream_module yajl \
  && make -C /usr/src/nginx_upstream_module msgpack \
  && : "---------- download nginx ----------" \
  && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
     -o nginx.tar.gz \
  && curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc \
     -o nginx.tar.gz.asc \
  && : "---------- verify signatures ----------" \
  && mkdir -p /usr/src/nginx \
  && tar -xzf nginx.tar.gz -C /usr/src/nginx \
      --strip-components=1 \
  && cd /usr/src/nginx \
  && : "---------- build nginx ----------" \
  && ./configure \
      --with-cc-opt='-I/usr/src/nginx_upstream_module/third_party/third_party/msgpuck -I /usr/src/nginx_upstream_module/third_party/yajl/build/yajl-2.1.0/include' \
      --with-ld-opt='/usr/src/nginx_upstream_module/third_party/yajl/build/yajl-2.1.0/lib/libyajl_s.a -L /usr/src/nginx_upstream_module/third_party/third_party/msgpuck' \
      --add-module=/usr/src/nginx_upstream_module \
      --prefix=/etc/nginx \
      --sbin-path=/usr/sbin/nginx \
      --modules-path=/usr/lib/nginx/modules \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/var/run/nginx.pid \
      --lock-path=/var/run/nginx.lock \
      --http-client-body-temp-path=/var/cache/nginx/client_temp \
      --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
      --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
      --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
      --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
      --user=nginx \
      --group=nginx \
      --with-http_ssl_module \
      --with-http_realip_module \
      --with-http_addition_module \
      --with-http_sub_module \
      --with-http_dav_module \
      --with-http_flv_module \
      --with-http_mp4_module \
      --with-http_gunzip_module \
      --with-http_gzip_static_module \
      --with-http_random_index_module \
      --with-http_secure_link_module \
      --with-http_stub_status_module \
      --with-http_auth_request_module \
      --with-http_xslt_module=dynamic \
      --with-http_image_filter_module=dynamic \
      --with-http_geoip_module=dynamic \
      --with-http_perl_module=dynamic \
      --with-threads \
      --with-stream \
      --with-stream_ssl_module \
      --with-http_slice_module \
      --with-mail \
      --with-mail_ssl_module \
      --with-file-aio \
      --with-http_v2_module \
      --with-ipv6 \
      --with-ld-opt="-Wl,-rpath,$LUAJIT_LIB" \
      --add-module=$NGINX_DEVEL_KIT_PATH \
      --add-module=$NGINX_LUA_MODULE_PATH \
  && make \
  && make install \
  && rm -rf /etc/nginx/html/ \
  && mkdir /etc/nginx/conf.d/ \
  && mkdir -p /usr/share/nginx/html/ \
  && install -m644 html/index.html /usr/share/nginx/html/ \
  && install -m644 html/50x.html /usr/share/nginx/html/ \
  && : "---------- install module deps ----------" \
  && runDeps="$( \
      scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so \
              | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
              | sort -u \
              | xargs -r apk info --installed \
              | sort -u \
      )" \
  && apk add --virtual .run-deps $runDeps \
  && : "---------- install lua rocks ----------" \
  && for rock in $LUAROCKS_ROCKS; do luarocks install $rock; done \
  && : "---------- remove build deps ----------" \
  && rm -rf /usr/src/nginx \
  && rm -rf /usr/src/nginx_upstream_module \
  && apk del .build-deps \
  && : "---------- redirect logs to default collector ----------" \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

VOLUME /var/lib/tarantool
WORKDIR /opt/tarantool

ENV PYTHON_VERSION=2.7.13-r0
ENV PY_PIP_VERSION=9.0.0-r1
ENV SUPERVISOR_VERSION=3.3.1

RUN apk update && apk add -u python=$PYTHON_VERSION py-pip=$PY_PIP_VERSION
RUN pip install supervisor==$SUPERVISOR_VERSION

RUN echo "[supervisord]" > /etc/supervisord.conf && \
    echo "nodaemon=true" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \

    echo "[program:tarantool]" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/dev/stdout" >> /etc/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "command=tarantool /usr/local/bin/starter.lua" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf && \

    echo "[program:nginx]" >> /etc/supervisord.conf && \
    echo "command=nginx -c /usr/local/bin/rest_nginx.conf" >> /etc/supervisord.conf && \
    echo "stdout_logfile=/dev/stdout" >> /etc/supervisord.conf && \
    echo "stdout_logfile_maxbytes=0" >> /etc/supervisord.conf && \
    echo "" >> /etc/supervisord.conf

EXPOSE 80
RUN apk update && \
    apk upgrade && \
    apk add --update autoconf gcc
RUN apk add libzip-dev git musl-dev libc-dev && luarocks install --server=http://luarocks.org/dev lua-zip

COPY data.zip /tmp/data/data.zip
COPY *.lua /usr/local/bin/
COPY rest_nginx.conf /usr/local/bin/

ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]

