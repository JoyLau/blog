---
title: EFK(Elasticsearch8 + FileBeat + Kibana) 日志分析平台搭建
date: 2022-07-21 17:11:22
description: 记录下 EFK(Elasticsearch8 + FileBeat + Kibana) 日志分析平台搭建
categories: [大数据篇]
tags: [Elasticsearch]
---

<!-- more -->

## 说明
记录下 EFK(Elasticsearch8 + FileBeat + Kibana) 日志分析平台搭建
并加以用户名密码保护


## 证书生成
先启动一个 ES 节点，进入节点后使用下面的命令生成证书

```shell
    if [ x${ELASTIC_PASSWORD} == x ]; then
          echo "Set the ELASTIC_PASSWORD environment variable in the .env file";
          exit 1;
        elif [ x${KIBANA_PASSWORD} == x ]; then
          echo "Set the KIBANA_PASSWORD environment variable in the .env file";
          exit 1;
        fi;
        if [ ! -f config/certs/ca.zip ]; then
          echo "Creating CA";
          bin/elasticsearch-certutil ca --silent --pem -out config/certs/ca.zip;
          unzip config/certs/ca.zip -d config/certs;
        fi;
        if [ ! -f config/certs/certs.zip ]; then
          echo "Creating certs";
          echo -ne \
          "instances:\n"\
          "  - name: es01\n"\
          "    dns:\n"\
          "      - es01\n"\
          "      - localhost\n"\
          "    ip:\n"\
          "      - 127.0.0.1\n"\
          "  - name: es02\n"\
          "    dns:\n"\
          "      - es02\n"\
          "      - localhost\n"\
          "    ip:\n"\
          "      - 127.0.0.1\n"\
          "  - name: es03\n"\
          "    dns:\n"\
          "      - es03\n"\
          "      - localhost\n"\
          "    ip:\n"\
          "      - 127.0.0.1\n"\
          > config/certs/instances.yml;
          bin/elasticsearch-certutil cert --silent --pem -out config/certs/certs.zip --in config/certs/instances.yml --ca-cert config/certs/ca/ca.crt --ca-key config/certs/ca/ca.key;
          unzip config/certs/certs.zip -d config/certs;
        fi;
        echo "Setting file permissions"
        chown -R root:root config/certs;
        find . -type d -exec chmod 750 \{\} \;;
        find . -type f -exec chmod 640 \{\} \;;
        echo "Waiting for Elasticsearch availability";
        until curl -s --cacert config/certs/ca/ca.crt https://es01:9200 | grep -q "missing authentication credentials"; do sleep 30; done;
        echo "Setting kibana_system password";
        until curl -s -X POST --cacert config/certs/ca/ca.crt -u "elastic:${ELASTIC_PASSWORD}" -H "Content-Type: application/json" https://es01:9200/_security/user/kibana_system/_password -d "{\"password\":\"${KIBANA_PASSWORD}\"}" | grep -q "^{}"; do sleep 10; done;
        echo "All done!";

```

详细查看 [官方文档](https://www.elastic.co/guide/en/elasticsearch/reference/current/docker.html)


## 服务搭建
docker-compose.yml

```yaml
    version: "2.2"
    services:
      es01:
        image: elasticsearch:${STACK_VERSION}
        volumes:
          - ./certs:/usr/share/elasticsearch/config/certs
          - ./es01-data:/usr/share/elasticsearch/data
        container_name: elasticsearch-01
        restart: always
        ports:
          - ${ES_PORT}:9200
        networks:
          - elastic
        environment:
          - node.name=es01
          - cluster.name=${CLUSTER_NAME}
          - discovery.type=single-node
          #- cluster.initial_master_nodes=es01,es02,es03
          #- discovery.seed_hosts=es02,es03
          - ELASTIC_PASSWORD=${ELASTIC_PASSWORD}
          - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
          - bootstrap.memory_lock=true
          - xpack.security.enabled=true
          #- xpack.security.http.ssl.enabled=true
          #- xpack.security.http.ssl.key=certs/es01/es01.key
          #- xpack.security.http.ssl.certificate=certs/es01/es01.crt
          #- xpack.security.http.ssl.certificate_authorities=certs/ca/ca.crt
          #- xpack.security.http.ssl.verification_mode=certificate
          - xpack.security.transport.ssl.enabled=true
          - xpack.security.transport.ssl.key=certs/es01/es01.key
          - xpack.security.transport.ssl.certificate=certs/es01/es01.crt
          - xpack.security.transport.ssl.certificate_authorities=certs/ca/ca.crt
          - xpack.security.transport.ssl.verification_mode=certificate
          - xpack.license.self_generated.type=${LICENSE}
        ulimits:
          memlock:
            soft: -1
            hard: -1
        healthcheck:
          test:
            [
              "CMD-SHELL",
              "curl -s --cacert config/certs/ca/ca.crt http://localhost:9200 | grep -q 'missing authentication credentials'",
            ]
          interval: 10s
          timeout: 10s
          retries: 120
      kibana:
        depends_on:
          es01:
            condition: service_healthy
        image: kibana:${STACK_VERSION}
        container_name: kibana
        restart: always
        volumes:
          - ./certs:/usr/share/kibana/config/certs
          - ./kibanadata:/usr/share/kibana/data
        ports:
          - ${KIBANA_PORT}:5601
        networks:
          - elastic
        environment:
          - SERVERNAME=192.168.1.21
          - SERVER_BASEPATH=/kibana
          - SERVER_REWRITEBASEPATH=true
          - ELASTICSEARCH_HOSTS=http://es01:9200
          - ELASTICSEARCH_USERNAME=kibana_system
          - ELASTICSEARCH_PASSWORD=${KIBANA_PASSWORD}
          - ELASTICSEARCH_SSL_CERTIFICATEAUTHORITIES=config/certs/ca/ca.crt
          - I18N_LOCALE=zh-CN
        healthcheck:
          test:
            [
              "CMD-SHELL",
              "curl -s -I http://localhost:5601/kibana | grep -q 'HTTP/1.1 302 Found'",
            ]
          interval: 10s
          timeout: 10s
          retries: 120
      filebeat:
        depends_on:
          es01:
            condition: service_healthy
        image: elastic/filebeat:${STACK_VERSION}
        container_name: filebeat
        ports:
          - 6115:6115
        restart: always
        volumes:
          - ./filebeat-data/filebeat.yml:/usr/share/filebeat/filebeat.yml
          - ./filebeat-data/filebeat.template.json:/usr/share/filebeat/filebeat.template.json
        networks:
          - elastic
    networks:
      elastic:
```


.env 文件

```shell
    # Password for the 'elastic' user (at least 6 characters)
    ELASTIC_PASSWORD=xxxxx
    
    # Password for the 'kibana_system' user (at least 6 characters)
    KIBANA_PASSWORD=Kaiyuan@2022
    
    # Version of Elastic products
    STACK_VERSION=8.4.0
    
    # Set the cluster name
    CLUSTER_NAME=docker-cluster
    
    # Set to 'basic' or 'trial' to automatically start the 30-day trial
    LICENSE=basic
    #LICENSE=trial
    
    # Port to expose Elasticsearch HTTP API to the host
    ES_PORT=9200
    #ES_PORT=127.0.0.1:9200
    
    # Port to expose Kibana to the host
    KIBANA_PORT=5601
    #KIBANA_PORT=80
    
    # Increase or decrease based on the available host memory (in bytes)
    MEM_LIMIT=1073741824
    
    # Project namespace (defaults to the current folder name if not set)
    #COMPOSE_PROJECT_NAME=myproject
```






