# alpine-java-base

docker build --build-arg elk_logstash='172.17.0.2:5044' --build-arg elk_elasticsearh='http://172.17.0.3:9200' -t fabioluciano/alpine-base-java .
