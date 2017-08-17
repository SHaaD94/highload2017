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

COPY data.zip /tmp/data/data.zip
COPY *.lua /usr/local/share/tarantool/
COPY rest_nginx.conf /usr/local/bin/

#ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]
ENTRYPOINT ["tarantool", "/usr/local/share/tarantool/starter.lua"]

