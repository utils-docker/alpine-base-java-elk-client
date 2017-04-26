FROM frolvlad/alpine-oraclejdk8:slim
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Alpine Base"

ARG timezone
ENV timezone ${timezone:-"America/Sao_Paulo"}

ARG admin_username
ENV admin_username ${admin_username:-"admin"}

ARG admin_password
ENV admin_password ${admin_password:-"password"}

ARG monitor_username
ENV monitor_username ${monitor_username:-"monitor"}

ARG monitor_password
ENV monitor_password ${monitor_password:-"password"}

ENV elastico_download "https://www.elastic.co/downloads/beats/"

#####################

RUN apk --update --no-cache add supervisor curl tzdata sudo tar \
  && cp /usr/share/zoneinfo/${timezone} /etc/localtime \
  && echo ${timezone} > /etc/timezone \
  && printf "${admin_password}\n${admin_password}" | adduser ${admin_username} \
  && echo "${admin_username} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo -e "[supervisord]\nnodaemon=true\n\n[include]\nfiles = /etc/supervisor.d/*.ini" > /etc/supervisord.conf \
  && mkdir /var/log/monitor /opt/monitor

WORKDIR /opt/

## Configure Beats
RUN for type in file packet metric heart; do \
  beat="$type"beat; \
  link=$(curl -Ss $elastico_download$beat | grep -oE 'https://.*?linux-x86\_64\.tar\.gz' | head -n 1); \
  filename=$(basename $link); \
  echo 'Downloading file '$filename; \
  curl -Ss $link > $filename; \
  directory=$(tar tfz $filename --exclude '*/*'); \
  tar -xzf $filename && rm $filename && mv $directory ./monitor/$beat; \
done;

RUN printf "${monitor_password}\n${monitor_password}" | adduser ${monitor_username}

COPY files/supervisor/* /etc/supervisor.d/

ENTRYPOINT ["supervisord", "--nodaemon", "-c", "/etc/supervisord.conf", "-j", "/tmp/supervisord.pid", "-l", "/var/log/supervisord.log"]
