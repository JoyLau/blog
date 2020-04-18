---
title: 重剑无锋,大巧不工 SpringBoot --- Filebeat 实时收集 SpringBoot 日志
date: 2020-04-18 11:21:06
description: Filebeat 实时收集 SpringBoot 的方法
categories: [SpringBoot]
tags: [Filebeat,SpringBoot]
---

<!-- more -->

### 说明
1. Filebeat 版本为 6.4.3

### logback 配置

```yaml
    logging:
      config: classpath:logback-config.xml
```


```xml
    <?xml version="1.0" encoding="UTF-8"?>
      <configuration scan="true">
          <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
              <encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
                  <pattern>%d{${LOG_DATEFORMAT_PATTERN:-yyyy-MM-dd HH:mm:ss.SSS}} ${LOG_LEVEL_PATTERN:-%5p} ${PID:- } --- [%t] %-40.40logger{39} : %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%exception}
                  </pattern>
              </encoder>
          </appender>

          <appender name="CONSOLE-FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
              <file>
                  /Users/joylau/docker-data/logs/es-doc-office-service/es-doc-office-service-console.log
              </file>
              <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
                  <fileNamePattern>
                      /Users/joylau/docker-data/logs/es-doc-office-service/es-doc-office-service-console-%d{yyyy-MM-dd}.log.gz
                  </fileNamePattern>
                  <!--最大保留时间为 7 天-->
                  <maxHistory>7</maxHistory>
              </rollingPolicy>
              <encoder class="ch.qos.logback.classic.encoder.PatternLayoutEncoder">
                  <pattern>%d{${LOG_DATEFORMAT_PATTERN:-yyyy-MM-dd HH:mm:ss.SSS}} ${LOG_LEVEL_PATTERN:-%5p} ${PID:- } --- [%t] %-40.40logger{39} : %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%exception}
                  </pattern>
              </encoder>
          </appender>

          <appender name="JSON-FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
              <file>
                  /Users/joylau/docker-data/logs/es-doc-office-service/es-doc-office-service-json.log
              </file>
              <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
                  <fileNamePattern>
                      /Users/joylau/docker-data/logs/es-doc-office-service/es-doc-office-service-json-%d{yyyy-MM-dd}.log.gz
                  </fileNamePattern>
                  <maxHistory>7</maxHistory>
              </rollingPolicy>
              <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
                  <!--            json 日志美化-->
                  <!--            <jsonGeneratorDecorator class="net.logstash.logback.decorate.PrettyPrintingJsonGeneratorDecorator"/>-->
                  <jsonGeneratorDecorator class="net.logstash.logback.decorate.FeatureJsonGeneratorDecorator"/>
                  <providers>
                      <pattern>
                          <pattern>
                              {
                              "date": "%date{yyyy-MM-dd HH:mm:ss}",
                              "level": "%level",
                              "thread": "%thread",
                              "class": "%logger{500}",
                              "msg": "%msg",
                              "stack_trace": "%exception{2000}"
                              }
                          </pattern>
                      </pattern>
                  </providers>
              </encoder>
          </appender>

          <root level="INFO">
              <appender-ref ref="CONSOLE"/>
              <appender-ref ref="CONSOLE-FILE"/>
              <appender-ref ref="JSON-FILE"/>
          </root>

          <!--打印 mysql 日志-->
          <logger name="cn.joylau.code.mapper" level="DEBUG">
              <appender-ref ref="CONSOLE"/>
              <appender-ref ref="CONSOLE-FILE"/>
              <appender-ref ref="JSON-FILE"/>
          </logger>

      </configuration>
```

我这里记录了 2 份文件日志是因为我想在日志端点监控中(/actuator/logfile)直接访问控制台日志
需要配置 

```yaml
    logging:
      file: /path/es-doc-office-service-console.log
```

这里简单记录下 logback 配置文件:

logback的主要组成部分
- appender，是用来定义一个写日志记录的组件，常用的appender类有ConsoleAppender和RollingFileAppender，前者个是用来在控制台上打印日志，后者是将日志输出到文件中。
- layout，是指定日志的布局方式，这个基本都不会去特殊的指定，可以忽略，知道有这个东西即可。
- encoder，负责把事件转换成字节数组并把字节数组写到合适的输出流。encoder可以指定属性值class，这里对应的类只有一个PatternLayoutEncoder，也是默认值，可以不去指定。
- filter，过滤器分为三种，logback-classic提供的是两种，分别是常规的过滤器和Turbo过滤器。常用的过滤器就是按照日志级别来控制，将不同级别的日志输出到不同文件中，便于查看日志。如：错误日志输出到xxx-error.log，info日志输出到xxx-info.log中。
- rollingPolicy，用来设置日志的滚动策略，当达到条件后会自动将条件前的日志生成一个备份日志文件，条件后的日志输出到最新的日志文件中。常用的是按照时间来滚动（使用的类TimeBaseRollingPolicy）,还有一种就是基于索引来实现（使用的类FixedWindowRollingPolicy）。rolling policies有 TimeBasedRollingPolicy，SizeAndTimeBasedRollingPolicy,FixedWindowRollingPolicy三种策略
- triggeringPolicy，日志触发器策略，常用的是日志的大小的控制，当日志达到对应的大小的时候，就会触发。生成新的日志文件。日志大小的控制配合rollingPlicy使用的时候，不同的rollingPolicy会有所不同。


### springboot 日志输出格式

``` json
    {"date":"2020-04-18 09:18:56","level":"INFO","thread":"main","class":"cn.joylau.code.EsDocOfficeApplication","msg":"Starting EsDocOfficeApplication on JoyLaudeMacBook-Pro.local with PID 21663 (/Users/joylau/dev/idea-project/dev-app/es-doc-office/es-doc-office-service/build/classes/java/main started by joylau in /Users/joylau/dev/idea-project/es-doc-office)","stack_trace":""}
    {"date":"2020-04-18 09:18:56","level":"INFO","thread":"main","class":"cn.joylau.code.EsDocOfficeApplication","msg":"The following profiles are active: db,dev","stack_trace":""}
    {"date":"2020-04-18 09:18:58","level":"INFO","thread":"main","class":"org.springframework.data.repository.config.RepositoryConfigurationDelegate","msg":"Bootstrapping Spring Data repositories in DEFAULT mode.","stack_trace":""}
    {"date":"2020-04-18 09:18:58","level":"INFO","thread":"main","class":"org.springframework.data.repository.config.RepositoryConfigurationDelegate","msg":"Finished Spring Data repository scanning in 86ms. Found 3 repository interfaces.","stack_trace":""}
    {"date":"2020-04-18 09:18:58","level":"INFO","thread":"main","class":"org.springframework.context.support.PostProcessorRegistrationDelegate$BeanPostProcessorChecker","msg":"Bean 'org.springframework.transaction.annotation.ProxyTransactionManagementConfiguration' of type [org.springframework.transaction.annotation.ProxyTransactionManagementConfiguration$$EnhancerBySpringCGLIB$$a477e06a] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)","stack_trace":""}
    {"date":"2020-04-18 09:18:59","level":"WARN","thread":"main","class":"io.undertow.websockets.jsr","msg":"UT026010: Buffer pool was not set on WebSocketDeploymentInfo, the default pool will be used","stack_trace":""}
    {"date":"2020-04-18 09:18:59","level":"INFO","thread":"main","class":"io.undertow.servlet","msg":"Initializing Spring embedded WebApplicationContext","stack_trace":""}
    {"date":"2020-04-18 09:18:59","level":"INFO","thread":"main","class":"org.springframework.web.context.ContextLoader","msg":"Root WebApplicationContext: initialization completed in 2231 ms","stack_trace":""}
    {"date":"2020-04-18 09:18:59","level":"INFO","thread":"main","class":"com.alibaba.druid.spring.boot.autoconfigure.DruidDataSourceAutoConfigure","msg":"Init DruidDataSource","stack_trace":""}
```

### filebeat 配置

```yaml
    #=========================== Configure logging ================================
    logging.level: warning
    #=========================== Filebeat prospectors =============================
    filebeat.inputs:
      - type: log
        # Paths that should be crawled and fetched. Glob based paths.
        paths:
          - /var/log/read-log/*.log
        json.keys_under_root: true
        json.overwrite_keys: true
    #-------------------------- Elasticsearch output ------------------------------
    output.elasticsearch:
      # Array of hosts to connect to.
      hosts: ["http://ip:9200"]
      index: "service-runtime-log_%{+YYYY-MM-dd}"
      username: "username"
      password: "password"
    
    setup:template.enabled: true
    setup.template.overwrite: true
    setup.template.name: "service-log-filebeat-template"
    setup.template.pattern: "service-runtime-log_*"
    setup.template.json.enabled: true
    setup.template.json.path: "/usr/share/filebeat/filebeat.template.json"
    setup.template.json.name: "service-log-filebeat-template"
```

注意这里我使用了自定义模板 `filebeat.template.json`, 因为我需要处理一下特殊字段, 比如 date 字段需要设置为日期类型, `msg` 和 `stack_trace` 设置为 text 以供分词和全文检索,
默认处理使用的字段在配置文件 `fields.yml ` 里,见下面附录
可以使用 

```bash
    filebeat export template > /var/log/read-log/filebeat.template.json
```

导出模板,详细配置见下面的附录

### 模板配置

```json
    {
      "index_patterns": [
        "service-runtime-log_*"
      ],
      "mappings": {
        "doc": {
          "_meta": {
            "version": "6.4.3"
          },
          "date_detection": false,
          "dynamic_templates": [
            {
              "fields": {
                "mapping": {
                  "type": "keyword"
                },
                "match_mapping_type": "string",
                "path_match": "fields.*"
              }
            },
            {
              "docker.container.labels": {
                "mapping": {
                  "type": "keyword"
                },
                "match_mapping_type": "string",
                "path_match": "docker.container.labels.*"
              }
            },
            {
              "kibana.log.meta": {
                "mapping": {
                  "type": "keyword"
                },
                "match_mapping_type": "string",
                "path_match": "kibana.log.meta.*"
              }
            },
            {
              "strings_as_keyword": {
                "mapping": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "match_mapping_type": "string"
              }
            }
          ],
          "properties": {
            "@timestamp": {
              "type": "date"
            },
            "beat": {
              "properties": {
                "hostname": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timezone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "offset": {
              "type": "long"
            },
            "source": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "date": {
              "type": "date",
              "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd||epoch_millis"
            },
            "stack_trace": {
              "type": "text"
            },
            "msg": {
              "type": "text"
            }
          }
        }
      },
      "order": 1,
      "settings": {
        "index": {
          "mapping": {
            "total_fields": {
              "limit": 10000
            }
          },
          "number_of_routing_shards": 30,
          "refresh_interval": "5s"
        }
      },
      "aliases": {
        "service-runtime-log": {}
      }
    }

```


### docker 运行
```bash
    docker run --rm --name filebeat --mount type=bind,source="$(pwd)"/filebeat.yml,target=/usr/share/filebeat/filebeat.yml --mount type=bind,source="$(pwd)"/filebeat.template.json,target=/usr/share/filebeat/filebeat.template.json -v /Users/joylau/docker-data/logs/es-doc-office-service:/var/log/read-log docker.elastic.co/beats/filebeat:6.4.3
```

### 自定义 docker 容器
```dockerfile
    FROM docker.elastic.co/beats/filebeat:6.4.3
    MAINTAINER liufa "2587038142.liu@gmail.com"
    LABEL Descripttion="This image use custom configuration filebeat in Docker."
    COPY filebeat.yml /usr/share/filebeat/filebeat.yml
    COPY filebeat.template.json /usr/share/filebeat/filebeat.template.json
    USER root
    RUN chown root:filebeat /usr/share/filebeat/filebeat.yml /usr/share/filebeat/filebeat.template.json
    USER filebeat
```

### 最终效果
```json
    {
      "_index": "service-runtime-log_2020-04-18",
      "_type": "doc",
      "_id": "PiQoi3EBOwES5EhZK7lp",
      "_version": 1,
      "_score": 1,
      "_source": {
        "@timestamp": "2020-04-18T02:39:56.273Z",
        "thread": "main",
        "source": "/var/log/read-log/es-doc-office-service-2020-04-18.log",
        "offset": 2145,
        "input": {
          "type": "log"
        },
        "beat": {
          "name": "032aebe1f6bc",
          "hostname": "032aebe1f6bc",
          "version": "6.4.3"
        },
        "host": {
          "name": "032aebe1f6bc"
        },
        "msg": "Init DruidDataSource",
        "date": "2020-04-18 09:18:59",
        "class": "com.alibaba.druid.spring.boot.autoconfigure.DruidDataSourceAutoConfigure",
        "prospector": {
          "type": "log"
        },
        "stack_trace": "",
        "level": "INFO"
      }
    }

```


### 处理 timestamp 时区问题
使用 filebeat 处理数据可以利用 elasticsearch 的 pipline

PUT /_ingest/pipeline/process_data

```json
    {
      "description" : "process timestamp field to ",
      "processors" : [
        {
          "date" : {
            "field" : "@timestamp",
            "formats" : ["ISO8601"],
            "target_field" : "@timestamp",
            "timezone" : "Asia/Shanghai"
          }
        }
      ]
    }
```


### 附录一(filebeat.template-all.json)

```json
    {
      "index_patterns": [
        "filebeat_log_*"
      ],
      "mappings": {
        "doc": {
          "_meta": {
            "version": "6.4.3"
          },
          "date_detection": false,
          "dynamic_templates": [
            {
              "fields": {
                "mapping": {
                  "type": "keyword"
                },
                "match_mapping_type": "string",
                "path_match": "fields.*"
              }
            },
            {
              "docker.container.labels": {
                "mapping": {
                  "type": "keyword"
                },
                "match_mapping_type": "string",
                "path_match": "docker.container.labels.*"
              }
            },
            {
              "kibana.log.meta": {
                "mapping": {
                  "type": "keyword"
                },
                "match_mapping_type": "string",
                "path_match": "kibana.log.meta.*"
              }
            },
            {
              "strings_as_keyword": {
                "mapping": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "match_mapping_type": "string"
              }
            }
          ],
          "properties": {
            "@timestamp": {
              "type": "date"
            },
            "apache2": {
              "properties": {
                "access": {
                  "properties": {
                    "agent": {
                      "norms": false,
                      "type": "text"
                    },
                    "body_sent": {
                      "properties": {
                        "bytes": {
                          "type": "long"
                        }
                      }
                    },
                    "geoip": {
                      "properties": {
                        "city_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "continent_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "location": {
                          "type": "geo_point"
                        },
                        "region_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "region_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "http_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "method": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "referrer": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "remote_ip": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "response_code": {
                      "type": "long"
                    },
                    "url": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "user_agent": {
                      "properties": {
                        "device": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "major": {
                          "type": "long"
                        },
                        "minor": {
                          "type": "long"
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "os": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "os_major": {
                          "type": "long"
                        },
                        "os_minor": {
                          "type": "long"
                        },
                        "os_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "patch": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "user_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "error": {
                  "properties": {
                    "client": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "level": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "module": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "pid": {
                      "type": "long"
                    },
                    "tid": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "auditd": {
              "properties": {
                "log": {
                  "properties": {
                    "a0": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "acct": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "geoip": {
                      "properties": {
                        "city_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "continent_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "location": {
                          "type": "geo_point"
                        },
                        "region_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "region_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "item": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "items": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "new_auid": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "new_ses": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "old_auid": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "old_ses": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "pid": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "ppid": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "record_type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "res": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sequence": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "beat": {
              "properties": {
                "hostname": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "timezone": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "version": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "docker": {
              "properties": {
                "container": {
                  "properties": {
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "image": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "labels": {
                      "type": "object"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "elasticsearch": {
              "properties": {
                "audit": {
                  "properties": {
                    "action": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "event_type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "layer": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "origin_address": {
                      "type": "ip"
                    },
                    "origin_type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "principal": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "request": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "request_body": {
                      "norms": false,
                      "type": "text"
                    },
                    "uri": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "deprecation": {
                  "properties": {}
                },
                "gc": {
                  "properties": {
                    "heap": {
                      "properties": {
                        "size_kb": {
                          "type": "long"
                        },
                        "used_kb": {
                          "type": "long"
                        }
                      }
                    },
                    "jvm_runtime_sec": {
                      "type": "float"
                    },
                    "old_gen": {
                      "properties": {
                        "size_kb": {
                          "type": "long"
                        },
                        "used_kb": {
                          "type": "long"
                        }
                      }
                    },
                    "phase": {
                      "properties": {
                        "class_unload_time_sec": {
                          "type": "float"
                        },
                        "cpu_time": {
                          "properties": {
                            "real_sec": {
                              "type": "float"
                            },
                            "sys_sec": {
                              "type": "float"
                            },
                            "user_sec": {
                              "type": "float"
                            }
                          }
                        },
                        "duration_sec": {
                          "type": "float"
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "parallel_rescan_time_sec": {
                          "type": "float"
                        },
                        "scrub_string_table_time_sec": {
                          "type": "float"
                        },
                        "scrub_symbol_table_time_sec": {
                          "type": "float"
                        },
                        "weak_refs_processing_time_sec": {
                          "type": "float"
                        }
                      }
                    },
                    "stopping_threads_time_sec": {
                      "type": "float"
                    },
                    "tags": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "threads_total_stop_time_sec": {
                      "type": "float"
                    },
                    "young_gen": {
                      "properties": {
                        "size_kb": {
                          "type": "long"
                        },
                        "used_kb": {
                          "type": "long"
                        }
                      }
                    }
                  }
                },
                "index": {
                  "properties": {
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "node": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "server": {
                  "properties": {
                    "component": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "gc": {
                      "properties": {
                        "young": {
                          "properties": {
                            "one": {
                              "type": "long"
                            },
                            "two": {
                              "type": "long"
                            }
                          }
                        }
                      }
                    },
                    "gc_overhead": {
                      "type": "long"
                    }
                  }
                },
                "shard": {
                  "properties": {
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "slowlog": {
                  "properties": {
                    "extra_source": {
                      "norms": false,
                      "type": "text"
                    },
                    "id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "logger": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "routing": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "search_type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "source_query": {
                      "norms": false,
                      "type": "text"
                    },
                    "stats": {
                      "norms": false,
                      "type": "text"
                    },
                    "took": {
                      "norms": false,
                      "type": "text"
                    },
                    "took_millis": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "total_hits": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "total_shards": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "types": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "error": {
              "properties": {
                "code": {
                  "type": "long"
                },
                "message": {
                  "norms": false,
                  "type": "text"
                },
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "event": {
              "properties": {
                "created": {
                  "type": "date"
                },
                "severity": {
                  "type": "long"
                }
              }
            },
            "fields": {
              "type": "object"
            },
            "fileset": {
              "properties": {
                "module": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "host": {
              "properties": {
                "architecture": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "id": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "ip": {
                  "type": "ip"
                },
                "mac": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "os": {
                  "properties": {
                    "family": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "platform": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "http": {
              "properties": {
                "request": {
                  "properties": {
                    "method": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "response": {
                  "properties": {
                    "content_length": {
                      "type": "long"
                    },
                    "elapsed_time": {
                      "type": "long"
                    },
                    "status_code": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "icinga": {
              "properties": {
                "debug": {
                  "properties": {
                    "facility": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "severity": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "main": {
                  "properties": {
                    "facility": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "severity": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "startup": {
                  "properties": {
                    "facility": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "severity": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "iis": {
              "properties": {
                "access": {
                  "properties": {
                    "agent": {
                      "norms": false,
                      "type": "text"
                    },
                    "body_received": {
                      "properties": {
                        "bytes": {
                          "type": "long"
                        }
                      }
                    },
                    "body_sent": {
                      "properties": {
                        "bytes": {
                          "type": "long"
                        }
                      }
                    },
                    "cookie": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "geoip": {
                      "properties": {
                        "city_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "continent_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "location": {
                          "type": "geo_point"
                        },
                        "region_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "region_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "hostname": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "http_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "method": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "port": {
                      "type": "long"
                    },
                    "query_string": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "referrer": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "remote_ip": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "request_time_ms": {
                      "type": "long"
                    },
                    "response_code": {
                      "type": "long"
                    },
                    "server_ip": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "server_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "site_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "sub_status": {
                      "type": "long"
                    },
                    "url": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "user_agent": {
                      "properties": {
                        "device": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "major": {
                          "type": "long"
                        },
                        "minor": {
                          "type": "long"
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "os": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "os_major": {
                          "type": "long"
                        },
                        "os_minor": {
                          "type": "long"
                        },
                        "os_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "patch": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "user_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "win32_status": {
                      "type": "long"
                    }
                  }
                },
                "error": {
                  "properties": {
                    "geoip": {
                      "properties": {
                        "city_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "continent_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "location": {
                          "type": "geo_point"
                        },
                        "region_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "region_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "http_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "method": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "queue_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "reason_phrase": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "remote_ip": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "remote_port": {
                      "type": "long"
                    },
                    "response_code": {
                      "type": "long"
                    },
                    "server_ip": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "server_port": {
                      "type": "long"
                    },
                    "url": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "input": {
              "properties": {
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "kafka": {
              "properties": {
                "log": {
                  "properties": {
                    "class": {
                      "norms": false,
                      "type": "text"
                    },
                    "component": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "level": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "timestamp": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "trace": {
                      "properties": {
                        "class": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "full": {
                          "norms": false,
                          "type": "text"
                        },
                        "message": {
                          "norms": false,
                          "type": "text"
                        }
                      }
                    }
                  }
                }
              }
            },
            "kibana": {
              "properties": {
                "log": {
                  "properties": {
                    "meta": {
                      "type": "object"
                    },
                    "state": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "tags": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "kubernetes": {
              "properties": {
                "annotations": {
                  "type": "object"
                },
                "container": {
                  "properties": {
                    "image": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "labels": {
                  "type": "object"
                },
                "namespace": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "node": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "pod": {
                  "properties": {
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "uid": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "log": {
              "properties": {
                "level": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "logstash": {
              "properties": {
                "log": {
                  "properties": {
                    "level": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "log_event": {
                      "type": "object"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "module": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "thread": {
                      "norms": false,
                      "type": "text"
                    }
                  }
                },
                "slowlog": {
                  "properties": {
                    "event": {
                      "norms": false,
                      "type": "text"
                    },
                    "level": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "module": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "plugin_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "plugin_params": {
                      "norms": false,
                      "type": "text"
                    },
                    "plugin_params_object": {
                      "type": "object"
                    },
                    "plugin_type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "thread": {
                      "norms": false,
                      "type": "text"
                    },
                    "took_in_millis": {
                      "type": "long"
                    },
                    "took_in_nanos": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "message": {
              "norms": false,
              "type": "text"
            },
            "meta": {
              "properties": {
                "cloud": {
                  "properties": {
                    "availability_zone": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "instance_id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "instance_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "machine_type": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "project_id": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "provider": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "region": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "mongodb": {
              "properties": {
                "log": {
                  "properties": {
                    "component": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "context": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "severity": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "mysql": {
              "properties": {
                "error": {
                  "properties": {
                    "level": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "thread_id": {
                      "type": "long"
                    },
                    "timestamp": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "slowlog": {
                  "properties": {
                    "host": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "id": {
                      "type": "long"
                    },
                    "ip": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "lock_time": {
                      "properties": {
                        "sec": {
                          "type": "float"
                        }
                      }
                    },
                    "query": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "query_time": {
                      "properties": {
                        "sec": {
                          "type": "float"
                        }
                      }
                    },
                    "rows_examined": {
                      "type": "long"
                    },
                    "rows_sent": {
                      "type": "long"
                    },
                    "timestamp": {
                      "type": "long"
                    },
                    "user": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "nginx": {
              "properties": {
                "access": {
                  "properties": {
                    "agent": {
                      "norms": false,
                      "type": "text"
                    },
                    "body_sent": {
                      "properties": {
                        "bytes": {
                          "type": "long"
                        }
                      }
                    },
                    "geoip": {
                      "properties": {
                        "city_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "continent_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "location": {
                          "type": "geo_point"
                        },
                        "region_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "region_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "http_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "method": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "referrer": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "remote_ip": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "response_code": {
                      "type": "long"
                    },
                    "url": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "user_agent": {
                      "properties": {
                        "device": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "major": {
                          "type": "long"
                        },
                        "minor": {
                          "type": "long"
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "os": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "os_major": {
                          "type": "long"
                        },
                        "os_minor": {
                          "type": "long"
                        },
                        "os_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "patch": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "user_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "error": {
                  "properties": {
                    "connection_id": {
                      "type": "long"
                    },
                    "level": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "pid": {
                      "type": "long"
                    },
                    "tid": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "offset": {
              "type": "long"
            },
            "osquery": {
              "properties": {
                "result": {
                  "properties": {
                    "action": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "calendar_time": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "host_identifier": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "unix_time": {
                      "type": "long"
                    }
                  }
                }
              }
            },
            "postgresql": {
              "properties": {
                "log": {
                  "properties": {
                    "database": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "duration": {
                      "type": "float"
                    },
                    "level": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "query": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "thread_id": {
                      "type": "long"
                    },
                    "timestamp": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "timezone": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "user": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "process": {
              "properties": {
                "pid": {
                  "type": "long"
                },
                "program": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "prospector": {
              "properties": {
                "type": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "read_timestamp": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "redis": {
              "properties": {
                "log": {
                  "properties": {
                    "level": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "pid": {
                      "type": "long"
                    },
                    "role": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                },
                "slowlog": {
                  "properties": {
                    "args": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "cmd": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "duration": {
                      "properties": {
                        "us": {
                          "type": "long"
                        }
                      }
                    },
                    "id": {
                      "type": "long"
                    },
                    "key": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "service": {
              "properties": {
                "name": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "source": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "stream": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "syslog": {
              "properties": {
                "facility": {
                  "type": "long"
                },
                "facility_label": {
                  "ignore_above": 1024,
                  "type": "keyword"
                },
                "priority": {
                  "type": "long"
                },
                "severity_label": {
                  "ignore_above": 1024,
                  "type": "keyword"
                }
              }
            },
            "system": {
              "properties": {
                "auth": {
                  "properties": {
                    "groupadd": {
                      "properties": {
                        "gid": {
                          "type": "long"
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "hostname": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "pid": {
                      "type": "long"
                    },
                    "program": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "ssh": {
                      "properties": {
                        "dropped_ip": {
                          "type": "ip"
                        },
                        "event": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "geoip": {
                          "properties": {
                            "city_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "continent_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "country_iso_code": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "location": {
                              "type": "geo_point"
                            },
                            "region_iso_code": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            },
                            "region_name": {
                              "ignore_above": 1024,
                              "type": "keyword"
                            }
                          }
                        },
                        "ip": {
                          "type": "ip"
                        },
                        "method": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "port": {
                          "type": "long"
                        },
                        "signature": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "sudo": {
                      "properties": {
                        "command": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "error": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "pwd": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "tty": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "user": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "timestamp": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "user": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "useradd": {
                      "properties": {
                        "gid": {
                          "type": "long"
                        },
                        "home": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "shell": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "uid": {
                          "type": "long"
                        }
                      }
                    }
                  }
                },
                "syslog": {
                  "properties": {
                    "hostname": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "message": {
                      "norms": false,
                      "type": "text"
                    },
                    "pid": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "program": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "timestamp": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            },
            "tags": {
              "ignore_above": 1024,
              "type": "keyword"
            },
            "traefik": {
              "properties": {
                "access": {
                  "properties": {
                    "agent": {
                      "norms": false,
                      "type": "text"
                    },
                    "backend_url": {
                      "norms": false,
                      "type": "text"
                    },
                    "body_sent": {
                      "properties": {
                        "bytes": {
                          "type": "long"
                        }
                      }
                    },
                    "frontend_name": {
                      "norms": false,
                      "type": "text"
                    },
                    "geoip": {
                      "properties": {
                        "city_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "continent_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "country_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "location": {
                          "type": "geo_point"
                        },
                        "region_iso_code": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "region_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "http_version": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "method": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "referrer": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "remote_ip": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "request_count": {
                      "type": "long"
                    },
                    "response_code": {
                      "type": "long"
                    },
                    "url": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    },
                    "user_agent": {
                      "properties": {
                        "device": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "major": {
                          "type": "long"
                        },
                        "minor": {
                          "type": "long"
                        },
                        "name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "os": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "os_major": {
                          "type": "long"
                        },
                        "os_minor": {
                          "type": "long"
                        },
                        "os_name": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        },
                        "patch": {
                          "ignore_above": 1024,
                          "type": "keyword"
                        }
                      }
                    },
                    "user_name": {
                      "ignore_above": 1024,
                      "type": "keyword"
                    }
                  }
                }
              }
            }
          }
        }
      },
      "order": 1,
      "settings": {
        "index": {
          "mapping": {
            "total_fields": {
              "limit": 10000
            }
          },
          "number_of_routing_shards": 30,
          "refresh_interval": "5s"
        }
      }
    }

```

### 附录二(fields-all.yml)

```yaml
    - key: log
      title: Log file content
      description: >
        Contains log file lines.
      fields:
        - name: source
          type: keyword
          required: true
          description: >
            The file from which the line was read. This field contains the absolute path to the file.
            For example: `/var/log/system.log`.
    
        - name: offset
          type: long
          required: false
          description: >
            The file offset the reported line starts at.
    
        - name: message
          type: text
          ignore_above: 0
          required: true
          description: >
            The content of the line read from the log file.
    
        - name: stream
          type: keyword
          required: false
          description: >
            Log stream when reading container logs, can be 'stdout' or 'stderr'
    
        - name: prospector.type
          required: true
          description: >
            The input type from which the event was generated. This field is set to the value specified
            for the `type` option in the input section of the Filebeat config file. (DEPRECATED: see `input.type`)
    
        - name: input.type
          required: true
          description: >
            The input type from which the event was generated. This field is set to the value specified
            for the `type` option in the input section of the Filebeat config file.
    
        - name: read_timestamp
          description: >
            In case the ingest pipeline parses the timestamp from the log contents, it stores
            the original `@timestamp` (representing the time when the log line was read) in this
            field.
    
        - name: fileset.module
          description: >
            The Filebeat module that generated this event.
    
        - name: fileset.name
          description: >
            The Filebeat fileset that generated this event.
    
        - name: syslog.facility
          type: long
          required: false
          description: >
            The facility extracted from the priority.
    
        - name: syslog.priority
          type: long
          required: false
          description: >
            The priority of the syslog event.
    
        - name: syslog.severity_label
          type: keyword
          required: false
          description: >
            The human readable severity.
    
        - name: syslog.facility_label
          type: keyword
          required: false
          description: >
            The human readable facility.
    
        - name: process.program
          type: keyword
          required: false
          description: >
            The name of the program.
    
        - name: process.pid
          type: long
          required: false
          description: >
            The pid of the process.
    
        - name: event.severity
          type: long
          required: false
          description: >
            The severity of the event.
    
        - name: service.name
          type: keyword
          description: >
            Service name.
    
        - name: log.level
          type: keyword
          description: >
            Logging level.
    
        - name: event.created
          type: date
          description: >
            event.created contains the date on which the event was created. In case of
            log events this is when the log line was read by Filebeat. In comparison
            @timestamp is the processed timestamp from the log line. If both are identical
            only @timestamp should be used.
    
        - name: http.response.status_code
          type: long
          description: >
            HTTP response status_code.
          example: 404
    
        - name: http.response.elapsed_time
          type: long
          description: >
            Elapsed time between request and response in milli seconds.
    
        - name: http.response.content_length
          type: long
          description: >
            Content length of the HTTP response body.
    
        - name: http.request.method
          type: keyword
          description: >
            Request method.
    
    - key: beat
      title: Beat
      description: >
        Contains common beat fields available in all event types.
      fields:
    
        - name: beat.name
          description: >
            The name of the Beat sending the log messages. If the Beat name is
            set in the configuration file, then that value is used. If it is not
            set, the hostname is used. To set the Beat name, use the `name`
            option in the configuration file.
        - name: beat.hostname
          description: >
            The hostname as returned by the operating system on which the Beat is
            running.
        - name: beat.timezone
          description: >
            The timezone as returned by the operating system on which the Beat is
            running.
        - name: beat.version
          description: >
            The version of the beat that generated this event.
    
        - name: "@timestamp"
          type: date
          required: true
          format: date
          example: August 26th 2016, 12:35:53.332
          description: >
            The timestamp when the event log record was generated.
    
        - name: tags
          description: >
            Arbitrary tags that can be set per Beat and per transaction
            type.
    
        - name: fields
          type: object
          object_type: keyword
          description: >
            Contains user configurable fields.
    
        - name: error
          type: group
          description: >
            Error fields containing additional info in case of errors.
          fields:
            - name: message
              type: text
              description: >
                Error message.
            - name: code
              type: long
              description: >
                Error code.
            - name: type
              type: keyword
              description: >
                Error type.
    - key: cloud
      title: Cloud provider metadata
      description: >
        Metadata from cloud providers added by the add_cloud_metadata processor.
      fields:
    
        - name: meta.cloud.provider
          example: ec2
          description: >
            Name of the cloud provider. Possible values are ec2, gce, or digitalocean.
    
        - name: meta.cloud.instance_id
          description: >
            Instance ID of the host machine.
    
        - name: meta.cloud.instance_name
          description: >
            Instance name of the host machine.
    
        - name: meta.cloud.machine_type
          example: t2.medium
          description: >
            Machine type of the host machine.
    
        - name: meta.cloud.availability_zone
          example: us-east-1c
          description: >
            Availability zone in which this host is running.
    
        - name: meta.cloud.project_id
          example: project-x
          description: >
            Name of the project in Google Cloud.
    
        - name: meta.cloud.region
          description: >
            Region in which this host is running.
    - key: docker
      title: Docker
      description: >
        Docker stats collected from Docker.
      short_config: false
      anchor: docker-processor
      fields:
        - name: docker
          type: group
          fields:
            - name: container.id
              type: keyword
              description: >
                Unique container id.
            - name: container.image
              type: keyword
              description: >
                Name of the image the container was built on.
            - name: container.name
              type: keyword
              description: >
                Container name.
            - name: container.labels
              type: object
              object_type: keyword
              description: >
                Image labels.
    - key: host
      title: Host
      description: >
        Info collected for the host machine.
      anchor: host-processor
      fields:
        - name: host
          type: group
          fields:
            - name: name
              type: keyword
              description: >
                Hostname.
            - name: id
              type: keyword
              description: >
                Unique host id.
            - name: architecture
              type: keyword
              description: >
                Host architecture (e.g. x86_64, arm, ppc, mips).
            - name: os.platform
              type: keyword
              description: >
                OS platform (e.g. centos, ubuntu, windows).
            - name: os.version
              type: keyword
              description: >
                OS version.
            - name: os.family
              type: keyword
              description: >
                OS family (e.g. redhat, debian, freebsd, windows).
            - name: ip
              type: ip
              description: >
                List of IP-addresses.
            - name: mac
              type: keyword
              description: >
                List of hardware-addresses, usually MAC-addresses.
    
    - key: kubernetes
      title: Kubernetes
      description: >
        Kubernetes metadata added by the kubernetes processor
      short_config: false
      anchor: kubernetes-processor
      fields:
        - name: kubernetes
          type: group
          fields:
            - name: pod.name
              type: keyword
              description: >
                Kubernetes pod name
    
            - name: pod.uid
              type: keyword
              description: >
                Kubernetes Pod UID
    
            - name: namespace
              type: keyword
              description: >
                Kubernetes namespace
    
            - name: node.name
              type: keyword
              description: >
                Kubernetes node name
    
            - name: labels
              type: object
              description: >
                Kubernetes labels map
    
            - name: annotations
              type: object
              description: >
                Kubernetes annotations map
    
            - name: container.name
              type: keyword
              description: >
                Kubernetes container name
    
            - name: container.image
              type: keyword
              description: >
                Kubernetes container image
    - key: apache2
      title: "Apache2"
      description: >
        Apache2 Module
      short_config: true
      fields:
        - name: apache2
          type: group
          description: >
            Apache2 fields.
          fields:
            - name: access
              type: group
              description: >
                Contains fields for the Apache2 HTTPD access logs.
              fields:
                - name: remote_ip
                  type: keyword
                  description: >
                    Client IP address.
                - name: user_name
                  type: keyword
                  description: >
                    The user name used when basic authentication is used.
                - name: method
                  type: keyword
                  example: GET
                  description: >
                    The request HTTP method.
                - name: url
                  type: keyword
                  description: >
                    The request HTTP URL.
                - name: http_version
                  type: keyword
                  description: >
                    The HTTP version.
                - name: response_code
                  type: long
                  description: >
                    The HTTP response code.
                - name: body_sent.bytes
                  type: long
                  format: bytes
                  description: >
                    The number of bytes of the server response body.
                - name: referrer
                  type: keyword
                  description: >
                    The HTTP referrer.
                - name: agent
                  type: text
                  description: >
                    Contains the un-parsed user agent string. Only present if the user
                    agent Elasticsearch plugin is not available or not used.
                - name: user_agent
                  type: group
                  description: >
                    Contains the parsed User agent field. Only present if the user
                    agent Elasticsearch plugin is available and used.
                  fields:
                    - name: device
                      type: keyword
                      description: >
                        The name of the physical device.
                    - name: major
                      type: long
                      description: >
                        The major version of the user agent.
                    - name: minor
                      type: long
                      description: >
                        The minor version of the user agent.
                    - name: patch
                      type: keyword
                      description: >
                        The patch version of the user agent.
                    - name: name
                      type: keyword
                      example: Chrome
                      description: >
                        The name of the user agent.
                    - name: os
                      type: keyword
                      description: >
                        The name of the operating system.
                    - name: os_major
                      type: long
                      description: >
                        The major version of the operating system.
                    - name: os_minor
                      type: long
                      description: >
                        The minor version of the operating system.
                    - name: os_name
                      type: keyword
                      description: >
                        The name of the operating system.
                - name: geoip
                  type: group
                  description: >
                    Contains GeoIP information gathered based on the remote_ip field.
                    Only present if the GeoIP Elasticsearch plugin is available and
                    used.
                  fields:
                    - name: continent_name
                      type: keyword
                      description: >
                        The name of the continent.
                    - name: country_iso_code
                      type: keyword
                      description: >
                        Country ISO code.
                    - name: location
                      type: geo_point
                      description: >
                        The longitude and latitude.
                    - name: region_name
                      type: keyword
                      description: >
                        The region name.
                    - name: city_name
                      type: keyword
                      description: >
                        The city name.
                    - name: region_iso_code
                      type: keyword
                      description: >
                        Region ISO code.
            - name: error
              type: group
              description: >
                Fields from the Apache error logs.
              fields:
                - name: level
                  type: keyword
                  description: >
                    The severity level of the message.
                - name: client
                  type: keyword
                  description: >
                    The IP address of the client that generated the error.
                - name: message
                  type: text
                  description: >
                    The logged message.
                - name: pid
                  type: long
                  description: >
                    The process ID.
                - name: tid
                  type: long
                  description: >
                    The thread ID.
                - name: module
                  type: keyword
                  description: >
                    The module producing the logged message.
    - key: auditd
      title: "Auditd"
      description: >
        Module for parsing auditd logs.
      short_config: true
      fields:
        - name: auditd
          type: group
          description: >
            Fields from the auditd logs.
          fields:
            - name: log
              type: group
              description: >
                Fields from the Linux audit log. Not all fields are documented here because
                they are dynamic and vary by audit event type.
              fields:
                - name: record_type
                  description: >
                    The audit event type.
                - name: old_auid
                  description: >
                    For login events this is the old audit ID used for the user prior to
                    this login.
                - name: new_auid
                  description: >
                    For login events this is the new audit ID. The audit ID can be used to
                    trace future events to the user even if their identity changes (like
                    becoming root).
                - name: old_ses
                  description: >
                    For login events this is the old session ID used for the user prior to
                    this login.
                - name: new_ses
                  description: >
                    For login events this is the new session ID. It can be used to tie a
                    user to future events by session ID.
                - name: sequence
                  type: long
                  description: >
                    The audit event sequence number.
                - name: acct
                  description: >
                    The user account name associated with the event.
                - name: pid
                  description: >
                    The ID of the process.
                - name: ppid
                  description: >
                    The ID of the process.
                - name: items
                  description: >
                    The number of items in an event.
                - name: item
                  description: >
                    The item field indicates which item out of the total number of items.
                    This number is zero-based; a value of 0 means it is the first item.
                - name: a0
                  description: >
                    The first argument to the system call.
                - name: res
                  description: >
                    The result of the system call (success or failure).
                - name: geoip
                  type: group
                  description: >
                    Contains GeoIP information gathered based on the `auditd.log.addr`
                    field. Only present if the GeoIP Elasticsearch plugin is available and
                    used.
                  fields:
                    - name: continent_name
                      type: keyword
                      description: >
                        The name of the continent.
                    - name: city_name
                      type: keyword
                      description: >
                        The name of the city.
                    - name: region_name
                      type: keyword
                      description: >
                        The name of the region.
                    - name: country_iso_code
                      type: keyword
                      description: >
                        Country ISO code.
                    - name: location
                      type: geo_point
                      description: >
                        The longitude and latitude.
                    - name: region_iso_code
                      type: keyword
                      description: >
                        Region ISO code.
    - key: elasticsearch
      title: "elasticsearch"
      description: >
        elasticsearch Module
      fields:
        - name: elasticsearch
          type: group
          description: >
          fields:
            - name: node.name
              description: "Name of the node"
              example: "vWNJsZ3"
              type: keyword
            - name: index.name
              description: "Index name"
              example: "filebeat-test-input"
              type: keyword
            - name: index.id
              description: "Index id"
              example: "aOGgDwbURfCV57AScqbCgw"
              type: keyword
            - name: shard.id
              description: "Id of the shard"
              example: "0"
              type: keyword
            - name: audit
              type: group
              description: >
              fields:
                - name: layer
                  description: "The layer from which this event originated: rest, transport or ip_filter"
                  example: "rest"
                  type: keyword
                - name: event_type
                  description: "The type of event that occurred: anonymous_access_denied, authentication_failed, access_denied, access_granted, connection_granted, connection_denied, tampered_request, run_as_granted, run_as_denied"
                  example: "access_granted"
                  type: keyword
                - name: origin_type
                  description: "Where the request originated: rest (request originated from a REST API request), transport (request was received on the transport channel), local_node (the local node issued the request)"
                  example: "local_node"
                  type: keyword
                - name: origin_address
                  description: "The IP address from which the request originated"
                  example: "192.168.1.42"
                  type: ip
                - name: principal
                  description: "The principal (username) that failed authentication"
                  example: "_anonymous"
                  type: keyword
                - name: action
                  description: "The name of the action that was executed"
                  example: "cluster:monitor/main"
                  type: keyword
                - name: uri
                  description: "The REST endpoint URI"
                  example: /_xpack/security/_authenticate
                  type: keyword
                - name: request
                  description: "The type of request that was executed"
                  example: "ClearScrollRequest"
                  type: keyword
                - name: request_body
                  description: "The body of the request, if enabled"
                  example: "body"
                  type: text
            - name: deprecation
              type: group
              description: >
              fields:
            - name: gc
              type: group
              description: >
                GC fileset fields.
              fields:
                - name: phase
                  type: group
                  description: >
                    Fields specific to GC phase.
                  fields:
                    - name: name
                      type: keyword
                      description: >
                        Name of the GC collection phase.
                    - name: duration_sec
                      type: float
                      description: >
                        Collection phase duration according to the Java virtual machine.
                    - name: scrub_symbol_table_time_sec
                      type: float
                      description: >
                         Pause time in seconds cleaning up symbol tables.
                    - name: scrub_string_table_time_sec
                      type: float
                      description: >
                        Pause time in seconds cleaning up string tables.
                    - name: weak_refs_processing_time_sec
                      type: float
                      description: >
                        Time spent processing weak references in seconds.
                    - name: parallel_rescan_time_sec
                      type: float
                      description: >
                        Time spent in seconds marking live objects while application is stopped.
                    - name: class_unload_time_sec
                      type: float
                      description: >
                        Time spent unloading unused classes in seconds.
                    - name: cpu_time
                      type: group
                      description: >
                        Process CPU time spent performing collections.
                      fields:
                        - name: user_sec
                          type: float
                          description: >
                            CPU time spent outside the kernel.
                        - name: sys_sec
                          type: float
                          description: >
                            CPU time spent inside the kernel. 
                        - name: real_sec
                          type: float
                          description: >
                            Total elapsed CPU time spent to complete the collection from start to finish.
                - name: jvm_runtime_sec
                  type: float
                  description: >
                    The time from JVM start up in seconds, as a floating point number.
                - name: threads_total_stop_time_sec
                  type: float
                  description: >
                    Garbage collection threads total stop time seconds.
                - name: stopping_threads_time_sec
                  type: float
                  description: >
                    Time took to stop threads seconds.
                - name: tags
                  type: keyword
                  description: >
                    GC logging tags.
                - name: heap
                  type: group
                  description: >
                    Heap allocation and total size.
                  fields:
                    - name: size_kb
                      type: integer
                      description: >
                        Total heap size in kilobytes.
                    - name: used_kb
                      type: integer
                      description: >
                        Used heap in kilobytes.
                - name: old_gen
                  type: group
                  description: >
                    Old generation occupancy and total size.
                  fields:
                    - name: size_kb
                      type: integer
                      description: >
                        Total size of old generation in kilobytes.
                    - name: used_kb
                      type: integer
                      description: >
                        Old generation occupancy in kilobytes.
                - name: young_gen
                  type: group
                  description: >
                    Young generation occupancy and total size.
                  fields:
                    - name: size_kb
                      type: integer
                      description: >
                        Total size of young generation in kilobytes.
                    - name: used_kb
                      type: integer
                      description: >
                        Young generation occupancy in kilobytes.
            - name: server
              description: "Server log file"
              type: group
              fields:
              - name: component
                description: "Log component"
                example: "o.e.c.m.MetaDataCreateIndexService"
                type: keyword
              - name: gc
                description: "GC log"
                type: group
                fields:
                - name: young
                  description: "Young GC"
                  example: ""
                  type: group
                  fields:
                  - name: one
                    description: ""
                    example: ""
                    type: long
                  - name: two
                    description: ""
                    example: ""
                    type: long
              - name: gc_overhead
                description: ""
                example: ""
                type: long
            - name: slowlog
              description: "Slowlog events from Elasticsearch"
              example: "[2018-06-29T10:06:14,933][INFO ][index.search.slowlog.query] [v_VJhjV] [metricbeat-6.3.0-2018.06.26][0] took[4.5ms], took_millis[4], total_hits[19435], types[], stats[], search_type[QUERY_THEN_FETCH], total_shards[1], source[{\"query\":{\"match_all\":{\"boost\":1.0}}}],"
              type: group
              fields:
              - name: logger
                description: "Logger name"
                example: "index.search.slowlog.fetch"
                type: keyword
              - name: took
                description: "Time it took to execute the query"
                example: "300ms"
                type: text
              - name: types
                description: "Types"
                example: ""
                type: keyword
              - name: stats
                description: "Statistics"
                example: ""
                type: text
              - name: search_type
                description: "Search type"
                example: "QUERY_THEN_FETCH"
                type: keyword
              - name: source_query
                description: "Slow query"
                example: "{\"query\":{\"match_all\":{\"boost\":1.0}}}"
                type: text
              - name: extra_source
                description: "Extra source information"
                example: ""
                type: text
              - name: took_millis
                description: "Time took in milliseconds"
                example: 42
                type: keyword
              - name: total_hits
                description: "Total hits"
                example: 42
                type: keyword
              - name: total_shards
                description: "Total queried shards"
                example: 22
                type: keyword
              - name: routing
                description: "Routing"
                example: "s01HZ2QBk9jw4gtgaFtn"
                type: keyword
              - name: id
                description: Id
                example: ""
                type: keyword
              - name: type
                description: "Type"
                example: "doc"
                type: keyword
    - key: icinga
      title: "Icinga"
      description: >
        Icinga Module
      fields:
        - name: icinga
          type: group
          description: >
          fields:
            - name: debug
              type: group
              description: >
                Contains fields for the Icinga debug logs.
              fields:
                - name: facility
                  type: keyword
                  description: >
                    Specifies what component of Icinga logged the message.
                - name: severity
                  type: keyword
                  description: >
                    Possible values are "debug", "notice", "information", "warning" or
                    "critical".
                - name: message
                  type: text
                  description: >
                    The logged message.
            - name: main
              type: group
              description: >
                Contains fields for the Icinga main logs.
              fields:
                - name: facility
                  type: keyword
                  description: >
                    Specifies what component of Icinga logged the message.
                - name: severity
                  type: keyword
                  description: >
                    Possible values are "debug", "notice", "information", "warning" or
                    "critical".
                - name: message
                  type: text
                  description: >
                    The logged message.
            - name: startup
              type: group
              description: >
                Contains fields for the Icinga startup logs.
              fields:
                - name: facility
                  type: keyword
                  description: >
                    Specifies what component of Icinga logged the message.
                - name: severity
                  type: keyword
                  description: >
                    Possible values are "debug", "notice", "information", "warning" or
                    "critical".
                - name: message
                  type: text
                  description: >
                    The logged message.
    - key: iis
      title: "IIS"
      description: >
        Module for parsing IIS log files.
      fields:
        - name: iis
          type: group
          description: >
            Fields from IIS log files.
          fields:
            - name: access
              type: group
              description: >
                Contains fields for IIS access logs.
              fields:
                - name: server_ip
                  type: keyword
                  description: >
                    The server IP address.
                - name: method
                  type: keyword
                  example: GET
                  description: >
                    The request HTTP method.
                - name: url
                  type: keyword
                  description: >
                    The request HTTP URL.
                - name: query_string
                  type: keyword
                  description: >
                    The request query string, if any.
                - name: port
                  type: long
                  description: >
                    The request port number.
                - name: user_name
                  type: keyword
                  description: >
                    The user name used when basic authentication is used.
                - name: remote_ip
                  type: keyword
                  description: >
                    The client IP address.
                - name: referrer
                  type: keyword
                  description: >
                    The HTTP referrer.
                - name: response_code
                  type: long
                  description: >
                    The HTTP response code.
                - name: sub_status
                  type: long
                  description: >
                    The HTTP substatus code.
                - name: win32_status
                  type: long
                  description: >
                    The Windows status code.
                - name: request_time_ms
                  type: long
                  description: >
                    The request time in milliseconds.
                - name: site_name
                  type: keyword
                  description: >
                    The site name and instance number.
                - name: server_name
                  type: keyword
                  description: >
                    The name of the server on which the log file entry was generated.
                - name: http_version
                  type: keyword
                  description: >
                    The HTTP version.
                - name: cookie
                  type: keyword
                  description: >
                    The content of the cookie sent or received, if any.
                - name: hostname
                  type: keyword
                  description: >
                    The host header name, if any.
                - name: body_sent.bytes
                  type: long
                  format: bytes
                  description: >
                    The number of bytes of the server response body.
                - name: body_received.bytes
                  type: long
                  format: bytes
                  description: >
                    The number of bytes of the server request body.
                - name: agent
                  type: text
                  description: >
                    Contains the un-parsed user agent string. Only present if the user
                    agent Elasticsearch plugin is not available or not used.
                - name: user_agent
                  type: group
                  description: >
                    Contains the parsed user agent field. Only present if the user
                    agent Elasticsearch plugin is available and used.
                  fields:
                    - name: device
                      type: keyword
                      description: >
                        The name of the physical device.
                    - name: major
                      type: long
                      description: >
                        The major version of the user agent.
                    - name: minor
                      type: long
                      description: >
                        The minor version of the user agent.
                    - name: patch
                      type: keyword
                      description: >
                        The patch version of the user agent.
                    - name: name
                      type: keyword
                      example: Chrome
                      description: >
                        The name of the user agent.
                    - name: os
                      type: keyword
                      description: >
                        The name of the operating system.
                    - name: os_major
                      type: long
                      description: >
                        The major version of the operating system.
                    - name: os_minor
                      type: long
                      description: >
                        The minor version of the operating system.
                    - name: os_name
                      type: keyword
                      description: >
                        The name of the operating system.
                - name: geoip
                  type: group
                  description: >
                    Contains GeoIP information gathered based on the remote_ip field.
                    Only present if the GeoIP Elasticsearch plugin is available and
                    used.
                  fields:
                    - name: continent_name
                      type: keyword
                      description: >
                        The name of the continent.
                    - name: country_iso_code
                      type: keyword
                      description: >
                        Country ISO code.
                    - name: location
                      type: geo_point
                      description: >
                        The longitude and latitude.
                    - name: region_name
                      type: keyword
                      description: >
                        The region name.
                    - name: city_name
                      type: keyword
                      description: >
                        The city name.
                    - name: region_iso_code
                      type: keyword
                      description: >
                        Region ISO code.
            - name: error
              type: group
              description: >
                Contains fields for IIS error logs.
              fields:
                - name: remote_ip
                  type: keyword
                  description: >
                    The client IP address.
                - name: remote_port
                  type: long
                  description: >
                    The client port number.
                - name: server_ip
                  type: keyword
                  description: >
                    The server IP address.
                - name: server_port
                  type: long
                  description: >
                    The server port number.
                - name: http_version
                  type: keyword
                  description: >
                    The HTTP version.
                - name: method
                  type: keyword
                  example: GET
                  description: >
                    The request HTTP method.
                - name: url
                  type: keyword
                  description: >
                    The request HTTP URL.
                - name: response_code
                  type: long
                  description: >
                    The HTTP response code.
                - name: reason_phrase
                  type: keyword
                  description: >
                    The HTTP reason phrase.
                - name: queue_name
                  type: keyword
                  description: >
                    The IIS application pool name.
                - name: geoip
                  type: group
                  description: >
                    Contains GeoIP information gathered based on the remote_ip field.
                    Only present if the GeoIP Elasticsearch plugin is available and
                    used.
                  fields:
                    - name: continent_name
                      type: keyword
                      description: >
                        The name of the continent.
                    - name: country_iso_code
                      type: keyword
                      description: >
                        Country ISO code.
                    - name: location
                      type: geo_point
                      description: >
                        The longitude and latitude.
                    - name: region_name
                      type: keyword
                      description: >
                        The region name.
                    - name: city_name
                      type: keyword
                      description: >
                        The city name.
                    - name: region_iso_code
                      type: keyword
                      description: >
                        Region ISO code.
    - key: kafka
      title: "Kafka"
      description: >
        Kafka module
      fields:
        - name: kafka
          type: group
          description: >
          fields:
            - name: log
              type: group
              description: >
                Kafka log lines.
              fields:
                - name: timestamp
                  description: >
                    The timestamp from the log line.
                - name: level
                  example: "WARN"
                  description: >
                    The log level.
                - name: message
                  type: text
                  description: >
                    The logged message.
                - name: component
                  type: keyword
                  description: >
                    Component the log is coming from.
                - name: class
                  type: text
                  description: >
                    Java class the log is coming from.
                - name: trace
                  type: group
                  description: >
                      Trace in the log line.
                  fields:
                    - name: class
                      type: keyword
                      description: >
                        Java class the trace is coming from.
                    - name: message
                      type: text
                      description: >
                          Message part of the trace.
                    - name: full
                      type: text
                      description: >
                          The full trace in the log line.
    - key: kibana
      title: "kibana"
      description: >
        kibana Module
      fields:
        - name: kibana
          type: group
          description: >
          fields:
            - name: log
              type: group
              description: >
                Kafka log lines.
              fields:
                - name: tags
                  type: keyword
                  description: >
                    Kibana logging tags.
                - name: state
                  type: keyword
                  description: >
                    Current state of Kibana.
                - name: meta
                  type: object
                  object_type: keyword
    - key: logstash
      title: "logstash"
      description: >
        logstash Module
      fields:
        - name: logstash
          type: group
          description: >
          fields:
            - name: log
              title: "Logstash"
              type: group
              description: >
                Fields from the Logstash logs.
              fields:
                - name: message
                  type: text
                  description: >
                    Contains the un-parsed log message
                - name: level
                  type: keyword
                  description: >
                    The log level of the message, this correspond to Log4j levels.
                - name: module
                  type: keyword
                  description: >
                    The module or class where the event originate.
                - name: thread
                  type: text
                  description: >
                    Information about the running thread where the log originate.
                - name: log_event
                  type: object
                  description: >
                    key and value debugging information.
            
            - name: slowlog
              type: group
              description: >
                slowlog
              fields:
                - name: message
                  type: text
                  description: >
                    Contains the un-parsed log message
                - name: level
                  type: keyword
                  description: >
                    The log level of the message, this correspond to Log4j levels.
                - name: module
                  type: keyword
                  description: >
                    The module or class where the event originate.
                - name: thread
                  type: text
                  description: >
                    Information about the running thread where the log originate.
                - name: event
                  type: text
                  description: >
                    Raw dump of the original event
                - name: plugin_name
                  type: keyword
                  description: >
                    Name of the plugin
                - name: plugin_type
                  type: keyword
                  description: >
                    Type of the plugin: Inputs, Filters, Outputs or Codecs.
                - name: took_in_millis
                  type: long
                  description: >
                    Execution time for the plugin in milliseconds.
                - name: took_in_nanos
                  type: long
                  description: >
                    Execution time for the plugin in nanoseconds.
                - name: plugin_params
                  type: text
                  description: >
                    String value of the plugin configuration
                - name: plugin_params_object
                  type: object
                  description: >
                    key -> value of the configuration used by the plugin.
            
            
            
            
            
    - key: mongodb
      title: "mongodb"
      description: >
        Module for parsing MongoDB log files.
      fields:
        - name: mongodb
          type: group
          description: >
              Fields from MongoDB logs.
          fields:
            - name: log
              type: group
              description: >
                  Contains fields from MongoDB logs.
              fields:
              - name: severity
                description: >
                    Severity level of message
                example: I
                type: keyword
              - name: component
                description: >
                    Functional categorization of message
                example: COMMAND
                type: keyword
              - name: context
                description: >
                    Context of message
                example: initandlisten
                type: keyword
              - name: message
                description: >
                    The message in the log line.
                type: text
    - key: mysql
      title: "MySQL"
      description: >
        Module for parsing the MySQL log files.
      short_config: true
      fields:
        - name: mysql
          type: group
          description: >
            Fields from the MySQL log files.
          fields:
            - name: error
              type: group
              description: >
                Contains fields from the MySQL error logs.
              fields:
                - name: timestamp
                  description: >
                    The timestamp from the log line.
                - name: thread_id
                  type: long
                  description: >
                    As of MySQL 5.7.2, this is the thread id. For MySQL versions prior to 5.7.2, this
                    field contains the process id.
                - name: level
                  example: "Warning"
                  description:
                    The log level.
                - name: message
                  type: text
                  description: >
                    The logged message.
            - name: slowlog
              type: group
              description: >
                Contains fields from the MySQL slow logs.
              fields:
                - name: user
                  description: >
                    The MySQL user that created the query.
                - name: host
                  description: >
                    The host from where the user that created the query logged in.
                - name: ip
                  description: >
                    The IP address from where the user that created the query logged in.
                - name: query_time.sec
                  type: float
                  description: >
                    The total time the query took, in seconds, as a floating point number.
                - name: lock_time.sec
                  type: float
                  description: >
                    The amount of time the query waited for the lock to be available. The
                    value is in seconds, as a floating point number.
                - name: rows_sent
                  type: long
                  description: >
                    The number of rows returned by the query.
                - name: rows_examined
                  type: long
                  description: >
                    The number of rows scanned by the query.
                - name: timestamp
                  type: long
                  description: >
                    The unix timestamp taken from the `SET timestamp` query.
                - name: query
                  description: >
                    The slow query.
                - name: id
                  type: long
                  description: >
                    The connection ID for the query.
    - key: nginx
      title: "Nginx"
      description: >
        Module for parsing the Nginx log files.
      short_config: true
      fields:
        - name: nginx
          type: group
          description: >
            Fields from the Nginx log files.
          fields:
            - name: access
              type: group
              description: >
                Contains fields for the Nginx access logs.
              fields:
                - name: remote_ip_list
                  type: array
                  description: >
                    An array of remote IP addresses. It is a list because it is common to include, besides the client
                    IP address, IP addresses from headers like `X-Forwarded-For`. See also the `remote_ip` field.
                - name: remote_ip
                  type: keyword
                  description: >
                    Client IP address. The first public IP address from the `remote_ip_list` array. If no public IP
                    addresses are present, this field contains the first private IP address from the `remote_ip_list`
                    array.
                - name: user_name
                  type: keyword
                  description: >
                    The user name used when basic authentication is used.
                - name: method
                  type: keyword
                  example: GET
                  description: >
                    The request HTTP method.
                - name: url
                  type: keyword
                  description: >
                    The request HTTP URL.
                - name: http_version
                  type: keyword
                  description: >
                    The HTTP version.
                - name: response_code
                  type: long
                  description: >
                    The HTTP response code.
                - name: body_sent.bytes
                  type: long
                  format: bytes
                  description: >
                    The number of bytes of the server response body.
                - name: referrer
                  type: keyword
                  description: >
                    The HTTP referrer.
                - name: agent
                  type: text
                  description: >
                    Contains the un-parsed user agent string. Only present if the user
                    agent Elasticsearch plugin is not available or not used.
                - name: user_agent
                  type: group
                  description: >
                    Contains the parsed User agent field. Only present if the user
                    agent Elasticsearch plugin is available and used.
                  fields:
                    - name: device
                      type: keyword
                      description: >
                        The name of the physical device.
                    - name: major
                      type: long
                      description: >
                        The major version of the user agent.
                    - name: minor
                      type: long
                      description: >
                        The minor version of the user agent.
                    - name: patch
                      type: keyword
                      description: >
                        The patch version of the user agent.
                    - name: name
                      type: keyword
                      example: Chrome
                      description: >
                        The name of the user agent.
                    - name: os
                      type: keyword
                      description: >
                        The name of the operating system.
                    - name: os_major
                      type: long
                      description: >
                        The major version of the operating system.
                    - name: os_minor
                      type: long
                      description: >
                        The minor version of the operating system.
                    - name: os_name
                      type: keyword
                      description: >
                        The name of the operating system.
                - name: geoip
                  type: group
                  description: >
                    Contains GeoIP information gathered based on the remote_ip field.
                    Only present if the GeoIP Elasticsearch plugin is available and
                    used.
                  fields:
                    - name: continent_name
                      type: keyword
                      description: >
                        The name of the continent.
                    - name: country_iso_code
                      type: keyword
                      description: >
                        Country ISO code.
                    - name: location
                      type: geo_point
                      description: >
                        The longitude and latitude.
                    - name: region_name
                      type: keyword
                      description: >
                        The region name.
                    - name: city_name
                      type: keyword
                      description: >
                        The city name.
                    - name: region_iso_code
                      type: keyword
                      description: >
                        Region ISO code.
            - name: error
              type: group
              description: >
                Contains fields for the Nginx error logs.
              fields:
                - name: level
                  type: keyword
                  description: >
                    Error level (e.g. error, critical).
                - name: pid
                  type: long
                  description: >
                    Process identifier (PID).
                - name: tid
                  type: long
                  description: >
                    Thread identifier.
                - name: connection_id
                  type: long
                  description: >
                    Connection identifier.
                - name: message
                  type: text
                  description: >
                    The error message
    - key: osquery
      title: "Osquery"
      description: >
        Fields exported by the `osquery` module
      fields:
        - name: osquery
          type: group
          description: >
          fields:
            - name: result
              type: group
              description: >
                Common fields exported by the result metricset.
              fields:
                - name: name
                  type: keyword
                  description: >
                    The name of the query that generated this event.
                - name: action
                  type: keyword
                  description: >
                    For incremental data, marks whether the entry was added
                    or removed. It can be one of "added", "removed", or "snapshot".
                - name: host_identifier
                  type: keyword
                  description: >
                    The identifier for the host on which the osquery agent is running.
                    Normally the hostname.
                - name: unix_time
                  type: long
                  description: >
                    Unix timestamp of the event, in seconds since the epoch. Used for computing the `@timestamp` column.
                - name: calendar_time
                  tupe: keyword
                  description: >
                    String representation of the collection time, as formatted by osquery.
    - key: postgresql
      title: "PostgreSQL"
      description: >
        Module for parsing the PostgreSQL log files.
      short_config: true
      fields:
        - name: postgresql
          type: group
          description: >
              Fields from PostgreSQL logs.
          fields:
            - name: log
              type: group
              description: >
                Fields from the PostgreSQL log files.
              fields:
                - name: timestamp
                  description: >
                    The timestamp from the log line.
                - name: timezone
                  description: >
                    The timezone of timestamp.
                - name: thread_id
                  type: long
                  description: >
                      Process id
                - name: user
                  example: "admin"
                  description:
                    Name of user
                - name: database
                  example: "mydb"
                  description:
                    Name of database
                - name: level
                  example: "FATAL"
                  description:
                    The log level.
                - name: duration
                  type: float
                  example: "30.0"
                  description:
                    Duration of a query.
                - name: query
                  example: "SELECT * FROM users;"
                  description:
                    Query statement.
                - name: message
                  type: text
                  description: >
                    The logged message.
    - key: redis
      title: "Redis"
      description: >
        Redis Module
      fields:
        - name: redis
          type: group
          description: >
          fields:
            - name: log
              type: group
              description: >
                Redis log files
              fields:
                - name: pid
                  type: long
                  description: >
                    The process ID of the Redis server.
                - name: role
                  type: keyword
                  description: >
                    The role of the Redis instance. Can be one of `master`, `slave`, `child` (for RDF/AOF writing child),
                    or `sentinel`.
                - name: level
                  type: keyword
                  description: >
                    The log level. Can be one of `debug`, `verbose`, `notice`, or `warning`.
                - name: message
                  type: text
                  description: >
                    The log message
            - name: slowlog
              type: group
              description: >
                Slow logs are retrieved from Redis via a network connection.
              fields:
                - name: cmd
                  type: keyword
                  description: >
                    The command executed.
                - name: duration.us
                  type: long
                  description: >
                    How long it took to execute the command in microseconds.
                - name: id
                  type: long
                  description: >
                    The ID of the query.
                - name: key
                  type: keyword
                  description: >
                    The key on which the command was executed.
                - name: args
                  type: keyword
                  description: >
                    The arguments with which the command was called.
    - key: system
      title: "System"
      description: >
        Module for parsing system log files.
      short_config: true
      fields:
        - name: system
          type: group
          description: >
            Fields from the system log files.
          fields:
            - name: auth
              type: group
              description: >
                Fields from the Linux authorization logs.
              fields:
                - name: timestamp
                  description: >
                    The timestamp as read from the auth message.
                - name: hostname
                  description: >
                    The hostname as read from the auth message.
                - name: program
                  description: >
                    The process name as read from the auth message.
                - name: pid
                  type: long
                  description: >
                    The PID of the process that sent the auth message.
                - name: message
                  type: text
                  description: >
                    The message in the log line.
                - name: user
                  description: >
                    The Unix user that this event refers to.
            
                - name: ssh
                  type: group
                  description: >
                    Fields specific to SSH login events.
                  fields:
                  - name: event
                    description: >
                      The SSH login event. Can be one of "Accepted", "Failed", or "Invalid". "Accepted"
                      means a successful login. "Invalid" means that the user is not configured on the
                      system. "Failed" means that the SSH login attempt has failed.
                  - name: method
                    description: >
                      The SSH authentication method. Can be one of "password" or "publickey".
                  - name: ip
                    type: ip
                    description: >
                      The client IP from where the login attempt was made.
                  - name: dropped_ip
                    type: ip
                    description: >
                      The client IP from SSH connections that are open and immediately dropped.
                  - name: port
                    type: long
                    description: >
                      The client port from where the login attempt was made.
                  - name: signature
                    description: >
                      The signature of the client public key.
                  - name: geoip
                    type: group
                    description: >
                      Contains GeoIP information gathered based on the `system.auth.ip` field.
                      Only present if the GeoIP Elasticsearch plugin is available and
                      used.
                    fields:
                      - name: continent_name
                        type: keyword
                        description: >
                          The name of the continent.
                      - name: city_name
                        type: keyword
                        description: >
                          The name of the city.
                      - name: region_name
                        type: keyword
                        description: >
                          The name of the region.
                      - name: country_iso_code
                        type: keyword
                        description: >
                          Country ISO code.
                      - name: location
                        type: geo_point
                        description: >
                          The longitude and latitude.
                      - name: region_iso_code
                        type: keyword
                        description: >
                          Region ISO code.
                - name: sudo
                  type: group
                  description: >
                    Fields specific to events created by the `sudo` command.
                  fields:
                  - name: error
                    example: user NOT in sudoers
                    description: >
                      The error message in case the sudo command failed.
                  - name: tty
                    description: >
                      The TTY where the sudo command is executed.
                  - name: pwd
                    description: >
                      The current directory where the sudo command is executed.
                  - name: user
                    example: root
                    description: >
                      The target user to which the sudo command is switching.
                  - name: command
                    description: >
                      The command executed via sudo.
            
                - name: useradd
                  type: group
                  description: >
                    Fields specific to events created by the `useradd` command.
                  fields:
                  - name: name
                    description: >
                      The user name being added.
                  - name: uid
                    type: long
                    description:
                      The user ID.
                  - name: gid
                    type: long
                    description:
                      The group ID.
                  - name: home
                    description:
                      The home folder for the new user.
                  - name: shell
                    description:
                      The default shell for the new user.
            
                - name: groupadd
                  type: group
                  description: >
                    Fields specific to events created by the `groupadd` command.
                  fields:
                  - name: name
                    description: >
                      The name of the new group.
                  - name: gid
                    type: long
                    description: >
                      The ID of the new group.
            - name: syslog
              type: group
              description: >
                Contains fields from the syslog system logs.
              fields:
                - name: timestamp
                  description: >
                    The timestamp as read from the syslog message.
                - name: hostname
                  description: >
                    The hostname as read from the syslog message.
                - name: program
                  description: >
                    The process name as read from the syslog message.
                - name: pid
                  description: >
                    The PID of the process that sent the syslog message.
                - name: message
                  type: text
                  description: >
                    The message in the log line.
    - key: traefik
      title: "Traefik"
      description: >
        Module for parsing the Traefik log files.
      fields:
        - name: traefik
          type: group
          description: >
            Fields from the Traefik log files.
          fields:
            - name: access
              type: group
              description: >
                Contains fields for the Traefik access logs.
              fields:
                - name: remote_ip
                  type: keyword
                  description: >
                    Client IP address.
                - name: user_name
                  type: keyword
                  description: >
                    The user name used when basic authentication is used.
                - name: method
                  type: keyword
                  example: GET
                  description: >
                    The request HTTP method.
                - name: url
                  type: keyword
                  description: >
                    The request HTTP URL.
                - name: http_version
                  type: keyword
                  description: >
                    The HTTP version.
                - name: response_code
                  type: long
                  description: >
                    The HTTP response code.
                - name: body_sent.bytes
                  type: long
                  format: bytes
                  description: >
                    The number of bytes of the server response body.
                - name: referrer
                  type: keyword
                  description: >
                    The HTTP referrer.
                - name: agent
                  type: text
                  description: >
                    Contains the un-parsed user agent string. Only present if the user
                    agent Elasticsearch plugin is not available or not used.
                - name: user_agent
                  type: group
                  description: >
                    Contains the parsed User agent field. Only present if the user
                    agent Elasticsearch plugin is available and used.
                  fields:
                    - name: device
                      type: keyword
                      description: >
                        The name of the physical device.
                    - name: major
                      type: long
                      description: >
                        The major version of the user agent.
                    - name: minor
                      type: long
                      description: >
                        The minor version of the user agent.
                    - name: patch
                      type: keyword
                      description: >
                        The patch version of the user agent.
                    - name: name
                      type: keyword
                      example: Chrome
                      description: >
                        The name of the user agent.
                    - name: os
                      type: keyword
                      description: >
                        The name of the operating system.
                    - name: os_major
                      type: long
                      description: >
                        The major version of the operating system.
                    - name: os_minor
                      type: long
                      description: >
                        The minor version of the operating system.
                    - name: os_name
                      type: keyword
                      description: >
                        The name of the operating system.
                - name: geoip
                  type: group
                  description: >
                    Contains GeoIP information gathered based on the remote_ip field.
                    Only present if the GeoIP Elasticsearch plugin is available and
                    used.
                  fields:
                    - name: continent_name
                      type: keyword
                      description: >
                        The name of the continent.
                    - name: country_iso_code
                      type: keyword
                      description: >
                        Country ISO code.
                    - name: location
                      type: geo_point
                      description: >
                        The longitude and latitude.
                    - name: region_name
                      type: keyword
                      description: >
                        The region name.
                    - name: city_name
                      type: keyword
                      description: >
                        The city name.
                    - name: region_iso_code
                      type: keyword
                      description: >
                        Region ISO code.
                - name: request_count
                  type: long
                  description: >
                    The number of requests
                - name: frontend_name
                  type: text
                  description: >
                    The name of the frontend used
                - name: backend_url
                  type: text
                  description:
                    The url of the backend where request is forwarded

```