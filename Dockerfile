FROM frolvlad/alpine-oraclejdk8:slim
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Alpine Base"

ARG timezone
ENV timezone ${timezone:-"America/Sao_Paulo"}

RUN apk --update --no-cache add tar curl supervisor tzdata \
  && cp /usr/share/zoneinfo/${timezone} /etc/localtime \
  && echo $timezone > /etc/timezone
