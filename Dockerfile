FROM ubuntu:trusty
MAINTAINER e.zuykin@gmail.com

RUN apt-get update
RUN touch /etc/apt/sources.list.d/tarantool.list
RUN apt-get -qq -y install curl && apt-get install -qq -y apt-transport-https
RUN curl http://download.tarantool.org/tarantool/1.7/gpgkey | sudo apt-key add -
RUN echo 'deb http://download.tarantool.org/tarantool/1.7/ubuntu/ trusty main' >> /etc/apt/sources.list.d/tarantool.list
RUN echo 'deb-src http://download.tarantool.org/tarantool/1.7/ubuntu/ trusty main' >> /etc/apt/sources.list.d/tarantool.list

RUN apt-get update

# Install locales
ENV LC_ALL C.UTF-8

EXPOSE 3310
# Install tarantool pack
RUN apt-get install -y --force-yes luarocks lua5.2 tarantool tarantool-dev lua-zip

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
#
#git clone https://github.com/tarantool/nginx_upstream_module.git nginx_upstream_module
#cd nginx_upstream_module
#git submodule update --init --recursive
#git clone https://github.com/nginx/nginx.git nginx
#sudo apt-get install libpcre-dev zlib1-dev # install dependencies to build nginx
#make build-all

RUN apt-get install -y cmake libpcre3-dev zlib1g-dev libssl-dev libxslt-dev \
     libgd-dev \
     libgeoip-dev \
     git \
     tar \
     gnupg \
     curl \
     libperl-dev \
     unzip \
     gcc \
     perl \
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
  && apt-get install $runDeps \
  && : "---------- install lua rocks ----------" \
  && for rock in $LUAROCKS_ROCKS; do luarocks install $rock; done \
  && : "---------- remove build deps ----------" \
  && rm -rf /usr/src/nginx \
  && rm -rf /usr/src/nginx_upstream_module \
  && : "---------- redirect logs to default collector ----------" \
  && ln -sf /dev/stdout /var/log/nginx/access.log \
  && ln -sf /dev/stderr /var/log/nginx/error.log

RUN useradd --no-create-home nginx
RUN mkdir /var/cache/nginx

RUN apt-get -y install supervisor
RUN service supervisor stop

RUN echo "nginx -c /usr/local/bin/rest_nginx.conf"> /usr/local/bin/run.sh && \
    echo "tarantool /usr/local/share/tarantool/starter.lua">> /usr/local/bin/run.sh && \
    chmod +x /usr/local/bin/run.sh

EXPOSE 80

COPY data.zip /tmp/data/data.zip
COPY options.txt /tmp/data/options.txt
COPY *.lua /usr/local/share/tarantool/
COPY rest_nginx.conf /usr/local/bin/

ENTRYPOINT ["/bin/bash", "-c", "./usr/local/bin/run.sh"]

