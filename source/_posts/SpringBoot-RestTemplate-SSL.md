---
title: SpringBoot RestTemplate 支持发送 HTTPS 请求
date: 2020-10-19 11:03:09
description: 有时在项目中调用的接口是 https 的形式, 这时使用 RestTemplate 来调用请求就会出错, 下面是解决方式
categories: [SpringBoot篇]
tags: [SpringBoot]
---

<!-- more -->
## 背景
有时在项目中调用的接口是 https 的形式, 这时使用 RestTemplate 来调用请求就会出错:

```text
    javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    	at sun.security.ssl.Alerts.getSSLException(Alerts.java:192)
    	at sun.security.ssl.SSLSocketImpl.fatal(SSLSocketImpl.java:1949)
    	at sun.security.ssl.Handshaker.fatalSE(Handshaker.java:302)
    	at sun.security.ssl.Handshaker.fatalSE(Handshaker.java:296)
    	at sun.security.ssl.ClientHandshaker.serverCertificate(ClientHandshaker.java:1514)
    	at sun.security.ssl.ClientHandshaker.processMessage(ClientHandshaker.java:216)
    	at sun.security.ssl.Handshaker.processLoop(Handshaker.java:1026)
    	at sun.security.ssl.Handshaker.process_record(Handshaker.java:961)
    	at sun.security.ssl.SSLSocketImpl.readRecord(SSLSocketImpl.java:1062)
    	at sun.security.ssl.SSLSocketImpl.performInitialHandshake(SSLSocketImpl.java:1375)
    	at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1403)
    	at sun.security.ssl.SSLSocketImpl.startHandshake(SSLSocketImpl.java:1387)
    	at sun.net.www.protocol.https.HttpsClient.afterConnect(HttpsClient.java:559)
    	at sun.net.www.protocol.https.AbstractDelegateHttpsURLConnection.connect(AbstractDelegateHttpsURLConnection.java:185)
    	at sun.net.www.protocol.https.HttpsURLConnectionImpl.connect(HttpsURLConnectionImpl.java:153)
    	at cn.joylau.code.job.executor.service.jobhandler.HttpJobHandler.execute(HttpJobHandler.java:155)
    	at cn.joylau.code.job.core.thread.JobThread.run(JobThread.java:151)
    Caused by: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    	at sun.security.validator.PKIXValidator.doBuild(PKIXValidator.java:387)
    	at sun.security.validator.PKIXValidator.engineValidate(PKIXValidator.java:292)
    	at sun.security.validator.Validator.validate(Validator.java:260)
    	at sun.security.ssl.X509TrustManagerImpl.validate(X509TrustManagerImpl.java:324)
    	at sun.security.ssl.X509TrustManagerImpl.checkTrusted(X509TrustManagerImpl.java:229)
    	at sun.security.ssl.X509TrustManagerImpl.checkServerTrusted(X509TrustManagerImpl.java:124)
    	at sun.security.ssl.ClientHandshaker.serverCertificate(ClientHandshaker.java:1496)
    	... 12 more
    Caused by: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
    	at sun.security.provider.certpath.SunCertPathBuilder.build(SunCertPathBuilder.java:141)
    	at sun.security.provider.certpath.SunCertPathBuilder.engineBuild(SunCertPathBuilder.java:126)
    	at java.security.cert.CertPathBuilder.build(CertPathBuilder.java:280)
    	at sun.security.validator.PKIXValidator.doBuild(PKIXValidator.java:382)
    	... 18 more


    I/O error on GET request for "https://xxxxxx": 
    sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target; nested exception is javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target
```

下面是解决方式

## 配置

1. 引入依赖

```gradle
    implementation 'org.apache.httpcomponents:httpclient'
```

2. 代码配置

``` java
    import org.apache.http.conn.ssl.NoopHostnameVerifier;
    import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
    import org.apache.http.conn.ssl.TrustSelfSignedStrategy;
    import org.apache.http.impl.client.CloseableHttpClient;
    import org.apache.http.impl.client.HttpClients;
    import org.apache.http.ssl.SSLContextBuilder;


    @Bean
    public RestTemplate restTemplate(){
        return restTemplateBuilder.build();
    }

    /**
     * HTTPS RestTemplate
     */
    @Bean
    public RestTemplate httpsRestTemplate() throws KeyStoreException, NoSuchAlgorithmException, KeyManagementException {
        SSLContextBuilder builder = new SSLContextBuilder();
        builder.loadTrustMaterial(null, new TrustSelfSignedStrategy());
        SSLConnectionSocketFactory sslConnectionSocketFactory = new SSLConnectionSocketFactory(builder.build(), NoopHostnameVerifier.INSTANCE);

        CloseableHttpClient httpClient
                = HttpClients.custom()
                .setSSLHostnameVerifier(new NoopHostnameVerifier())
                .setSSLSocketFactory(sslConnectionSocketFactory)
//                .setDefaultCredentialsProvider(credsProvider)
                .build();
        HttpComponentsClientHttpRequestFactory requestFactory
                = new HttpComponentsClientHttpRequestFactory();
        requestFactory.setHttpClient(httpClient);
        requestFactory.setConnectTimeout((int)Duration.ofSeconds(5).toMillis());
        return new RestTemplate(requestFactory);
    }
```

## 使用
之前使用方式不变:

``` java
    @Autowired
    private RestTemplate restTemplate;
``` 

使用 https RestTemplate

``` java
    @Autowired
    private RestTemplate httpsRestTemplate;
```