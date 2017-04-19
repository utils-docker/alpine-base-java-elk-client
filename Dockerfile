FROM frolvlad/alpine-oraclejdk8:slim
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Alpine Base"

ARG timezone
ARG admin_username
ARG admin_password
ENV timezone ${timezone:-"America/Sao_Paulo"}
ENV admin_username ${admin_username:-"admin"}
ENV admin_password ${admin_password:-"password"}

#####################

RUN apk --update --no-cache add supervisor tzdata sudo \
  && cp /usr/share/zoneinfo/${timezone} /etc/localtime \
  && echo ${timezone} > /etc/timezone \
  && printf "${admin_password}\n${admin_password}" | adduser ${admin_username} \
  && echo "${admin_username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo "[supervisord]\nnodaemon=true\n\n[include]\nfiles = /etc/supervisor.d/*.ini" > /etc/supervisord.conf

ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf", "-j", "/tmp/supervisord.pid", "-l", "/var/log/supervisord.log"]
