---
title: office 套件的一系列研究记录
date: 2018-07-02 17:06:58
description: 包含 es 的中文分词检索，附件检索，office 套件在线预览等等
categories: [大数据篇]
tags: [Elasticsearch,OpenOffice,LibreOffice]
---

<!-- more -->
## ElasticSearch 环境准备
略

## 中文分词实现

1. 安装插件 https://github.com/medcl/elasticsearch-analysis-ik

2. 测试分词：

  ik_max_word会将文本做最细粒度的拆分； 
  ik_smart 会做最粗粒度的拆分。


``` json
    http://192.168.10.74:9200/_analyze/ POST
    	{
    	  "analyzer": "ik_max_word",
    	  "text": "绝地求生是最好玩的游戏"
    	}
    	
    	和
    	{
    	  "analyzer": "ik_smart",
    	  "text": "绝地求生是最好玩的游戏"
    	}
    	
    	和
    	{
    	  "analyzer": "standard",
    	  "text": "绝地求生是最好玩的游戏"
    	}
```

3. 创建索引

	http://192.168.10.74:9200/ik-index  PUT
	指定使用 ik_max_word 分词器
	
``` json
    {
        "settings" : {
            "analysis" : {
                "analyzer" : {
                    "ik" : {
                        "tokenizer" : "ik_max_word"
                    }
                }
            }
        },
        "mappings" : {
            "article" : {
                "dynamic" : true,
                "properties" : {
                    "subject" : {
                        "type" : "string",
                        "analyzer" : "ik_max_word"
                    },
                    "content" : {
                        "type" : "string",
                        "analyzer" : "ik_max_word"
                    }
                }
            }
        }
    }
```


​	

4. 添加数据
	略

5. 查询：
	http://192.168.10.74:9200/index/_search    POST
``` json
    {
      "query": {
        "match": {
          "subject": "合肥送餐冲突"
        }
      },
      "highlight": {
        "pre_tags": ["<span style = 'color:red'>"],
        "post_tags": ["</span>"],
        "fields": {"subject": {}}
      }
    }
```


6. 热更新
	IKAnalyzer.cfg.xml
	
	<entry key="remote_ext_dict">http://localhost/hotload.dic</entry>
	
	放入到 静态资源服务器下面
	
	
	
7. 同义词配置
	http://192.168.10.74:9200/synonyms-ik-index  PUT
	
``` json
    {
    	  "settings": {
    		"analysis": {
    		  "analyzer": {
    			"by_smart": {
    			  "type": "custom",
    			  "tokenizer": "ik_smart",
    			  "filter": [
    				"by_tfr",
    				"by_sfr"
    			  ],
    			  "char_filter": [
    				"by_cfr"
    			  ]
    			},
    			"by_max_word": {
    			  "type": "custom",
    			  "tokenizer": "ik_max_word",
    			  "filter": [
    				"by_tfr",
    				"by_sfr"
    			  ],
    			  "char_filter": [
    				"by_cfr"
    			  ]
    			}
    		  },
    		  "filter": {
    			"by_tfr": {
    			  "type": "stop",
    			  "stopwords": [
    				" "
    			  ]
    			},
    			"by_sfr": {
    			  "type": "synonym",
    			  "synonyms_path": "synonyms.dic"
    			}
    		  },
    		  "char_filter": {
    			"by_cfr": {
    			  "type": "mapping",
    			  "mappings": [
    				"| => |"
    			  ]
    			}
    		  }
    		}
    	  },
    	  "mappings": {
    		"article": {
    		  "dynamic": true,
    		  "properties": {
    			"subject": {
    			  "type": "string",
    			  "analyzer": "by_max_word",
    			  "search_analyzer": "by_smart"
    			},
    			"content": {
    			  "type": "string",
    			  "analyzer": "by_max_word",
    			  "search_analyzer": "by_smart"
    			}
    		  }
    		}
    	  }
    	}
```


8. 测试同义词

	http://192.168.10.74:9200/synonyms-ik-index/_analyze  POST

``` json
    {
      "analyzer": "by_smart",
      "text": "绝地求生是最好玩的游戏"
    }
```

9. 查询同义词
	http://192.168.10.74:9200/synonyms-ik-index/_search  POST
	
``` json
    	{
    	  "query": {
    		"match": {
    		  "subject": "吃鸡"
    		}
    	  },
    	  "highlight": {
    		"pre_tags": [
    		  "<span style = 'color:red'>"
    		],
    		"post_tags": [
    		  "</span>"
    		],
    		"fields": {
    		  "subject": {}
    		}
    	  }
    	}
```

数据导入/导出 ： [elasticdump](https://github.com/taskrabbit/elasticsearch-dump) 

github 地址： https://github.com/taskrabbit/elasticsearch-dump


## 文件搜索实现
1. 文档地址： https://www.elastic.co/guide/en/elasticsearch/plugins/5.3/using-ingest-attachment.html

2. 安装插件 
   ./bin/elasticsearch-plugin install ingest-attachment

3. 创建管道single_attachment
    http://192.168.10.74:9200/_ingest/pipeline/single_attachment  PUT

``` json
    {
      "description": "Extract single attachment information",
      "processors": [
        {
          "attachment": {
            "field": "data",
            "indexed_chars": -1,
            "ignore_missing": true
          }
        },
         {
           "remove": {
             "field": "data"
           }
         }
      ]
    }
```

新增了添加完附件数据后 删除 data 的 base64 的数据

3. 删除通道

http://192.168.10.74:9200/_ingest/pipeline/single_attachment  DELETE


4. 创建索引
    http://192.168.10.74:9200/file_attachment/  PUT
    
``` json
    {
      "settings": {
        "analysis": {
          "analyzer": {
            "ik": {
              "tokenizer": "ik_max_word"
            }
          }
        }
      },
      "mappings": {
        "attachment": {
          "properties": {
            "filename": {
              "type": "text",
              "analyzer": "ik_max_word"
            },
            "data": {
              "type": "text"
            },
            "time": {
              "type": "string"
            },
            "attachment.content": {
              "type": "text",
              "analyzer": "ik_max_word"
            }
          }
        }
      }
    }
```

5. 添加数据
    http://192.168.10.74:9200/file_attachment/attachment/1?pipeline=single_attachment&refresh=true&pretty=1/  POST

``` json
    {
      "filename": "测试文档.txt",
      "time": "2018-06-13 15:14:00",
      "data": "6L+Z5piv56ys5LiA5Liq55So5LqO5rWL6K+V5paH5pys6ZmE5Lu255qE5YaF5a6577yb5paH5Lu25qC85byP5Li6dHh0LOaWh+acrOS4uuS4reaWhw=="
    }
```

6. 文档查询
    http://192.168.10.74:9200/file_attachment/_search POST

``` json
    {
      "query": {
        "match": {
          "attachment.content": "测试"
        }
      },
      "highlight": {
        "pre_tags": [
          "<span style = 'color:red'>"
        ],
        "post_tags": [
          "</span>"
        ],
        "fields": {
          "attachment.content": {}
        }
      }
    }
```

注意： 使用 nginx 的静态资源目录作为 文件的存放，那么在下载文件时，想要 txt ,html ,pdf 等文件直接被下载而不被浏览器打开时，可在 nginx 的配置文件加入以下配置

``` bash
    server {
            listen       80;
            server_name  localhost;
    
            #charset koi8-r;
    
            #access_log  logs/host.access.log  main;
    
            location / {
                root   html;
    			if ($request_filename ~* ^.*?.(txt|doc|pdf|rar|gz|zip|docx|exe|xlsx|ppt|pptx|jpg|png|html|xml)$){
                            add_header Content-Disposition attachment; 
                            add_header Content-Type 'APPLICATION/OCTET-STREAM';                 
                     } 
                index  index.html index.htm;
            }
    
            #error_page  404              /404.html;
    
            # redirect server error pages to the static page /50x.html
            #
            error_page   500 502 503 504  /50x.html;
            location = /50x.html {
                root   html;
            }
    
            # proxy the PHP scripts to Apache listening on 127.0.0.1:80
            #
            #location ~ \.php$ {
            #    proxy_pass   http://127.0.0.1;
            #}
    
            # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
            #
            #location ~ \.php$ {
            #    root           html;
            #    fastcgi_pass   127.0.0.1:9000;
            #    fastcgi_index  index.php;
            #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
            #    include        fastcgi_params;
            #}
    
            # deny access to .htaccess files, if Apache's document root
            # concurs with nginx's one
            #
            #location ~ /\.ht {
            #    deny  all;
            #}
        }
```

重点是 : 
if ($request_filename ~* ^.*?.(txt|doc|pdf|rar|gz|zip|docx|exe|xlsx|ppt|pptx|jpg|png|html|xml)$){
      add_header Content-Disposition attachment;  
      add_header Content-Type 'APPLICATION/OCTET-STREAM';                
   } 
或者也可以这样处理：
if ($args ~* "target=download") {
      add_header Content-Disposition 'attachment';
      add_header Content-Type 'APPLICATION/OCTET-STREAM';
 }

这样的话只要在 get请求加上 target=download 参数就可以下载了。



## Office 套件研究

### OpenOffice 服务搭建
#### 安装步骤

1. 下载 rpm 包 ： 官网： https://www.openoffice.org/download/

2. 解压，进入 /zh-CN/RPMS/ ， 安装 rpm 包： `rpm -ivh *.rpm`

3. 安装完成后，生成 desktop-integration 目录，进入，因为我的系统是 centos 的 ，我选择安装 `rpm -ivh openoffice4.1.5-redhat-menus-4.1.5-9789.noarch.rpm`

4. 安装完成后，目录在 /opt/openoffice4 下
    启动： `/opt/openoffice4/program/soffice -headless -accept="socket,host=0.0.0.0,port=8100;urp;" -nofirststartwizard &`


#### 遇到的问题
1. libXext.so.6: cannot open shared object file: No such file or directory
    解决 ： `yum install libXext.x86_64`

2. no suitable windowing system found, exiting.
    解决： `yum groupinstall "X Window System"`

之后再启动，查看监听端口 `netstat -lnp |grep 8100`
已经可以了。

#### 存在的问题

对很多中文字体的支持并不是很好，很多中文字符及特殊字符无法显示


### LibreOffice 服务搭建
#### 安装步骤

1. 下载 Linux系统下的 rpm 安装包

2. 将安装包解压缩到目录下

3. 安装
   $ sudo yum install ./RPMS/*.rpm  /* 安装主安装程序的所有rpm包 */
   $ sudo yum install ./RPMS/*.rpm  /* 安装中文语言包中的所有rpm包 */
   $ sudo yum install ./RPMS/*.rpm  /* 安装中文离线帮助文件中的所有rpm包 */

4. 卸载
    $ sudo apt-get remove --purge libreoffice6.x-*  /* 移除所有类似libreoffice6.x-*的包。--purge表示卸载的同时移除所有相关的配置文件 */
    
#### 使用总结

LibreOffice 的安装表示没有像 OpenOffice 那样遇到很多问题，且对中文字符的支持较为友好，官网也提供了相应的中文字体下载。

### Spring Boot 连接并调用 Office 服务

``` java
    public Object preview(@PathVariable String fileName){
        try {
            Resource resource = new UrlResource(remoteAddr + fileName);
            if (FilenameUtils.getExtension(resource.getFilename()).equalsIgnoreCase("pdf")) {
                return "Is the PDF file";
            }
            try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
    
                final DocumentFormat targetFormat =
                        DefaultDocumentFormatRegistry.getFormatByExtension("pdf");
                converter
                        .convert(resource.getInputStream())
                        .as(
                                DefaultDocumentFormatRegistry.getFormatByExtension(
                                        FilenameUtils.getExtension(resource.getFilename())))
                        .to(baos)
                        .as(targetFormat)
                        .execute();
    
                final HttpHeaders headers = new HttpHeaders();
                headers.setContentType(MediaType.parseMediaType(targetFormat.getMediaType()));
                return new ResponseEntity<>(baos.toByteArray(), headers, HttpStatus.OK);
    
            } catch (OfficeException | IOException e) {
                e.printStackTrace();
                return "convert error: " + e.getMessage();
            }
        } catch (IOException e) {
            e.printStackTrace();
            return "File does not exist;";
        }
    }
```

### Collabora Office 服务搭建

官方地址： https://www.collaboraoffice.com/solutions/collabora-office/

#### Collabora CODE 服务搭建

官方建议采用docker来安装

##### Docker

``` bash
$ docker pull collabora/code
$ docker run -t -d -p 127.0.0.1:9980:9980 -e "domain=<your-dot-escaped-domain>" \
        -e "username=admin" -e "password=S3cRet" --restart always --cap-add MKNOD collabora/code
```

##### Linux packages

``` shell
# import the signing key
wget https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7/repodata/repomd.xml.key && rpm --import repomd.xml.key
# add the repository URL to yum
yum-config-manager --add-repo https://www.collaboraoffice.com/repos/CollaboraOnline/CODE-centos7
# perform the installation
yum install loolwsd CODE-brand
```

### Office 套件文档在线协作

 需要域名和SSL证书，尚未实际研究
