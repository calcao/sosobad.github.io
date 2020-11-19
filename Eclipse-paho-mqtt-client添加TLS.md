#Eclipse paho mqtt client TLS访问


## 准备调试Server

1. 准备配置文件
    创建mosquitto.conf文件添加以下内容：
    ```bash
    # 端口
    listener 8883
    # 证书
    cafile /certs/ca.crt
    certfile /certs/server.crt
    keyfile /certs/server.pem
    ```

2. 启动服务
    ```bash
    docker run -d \
        -p 8883:8883 \
        --name mosquitto \
        -v /root/mqtt/mosquitto.conf:/mosquitto/config/mosquitto.conf \
        -v /root/certs:/certs \
        eclipse-mosquitto:1.6.12-openssl
    ```

## client代码

```java
public void connect(){
        try {
            persistence  = new MemoryPersistence();
            client = new MqttClient(broker, clientId, persistence);
            options = new MqttConnectOptions();
            options.setCleanSession(true);
            if(SysEnv.ENABLE_SSL){
                SSLSocketFactory ssLocketFactory = getSSLocketFactory(SysEnv.MQTT_CA_FILE, SysEnv.MQTT_KEY_FILE, SysEnv.MQTT_CERT_FILE);
                options.setSocketFactory(ssLocketFactory);
            }
            if(username != null && password != null){
                options.setUserName(username);
                options.setPassword(password.toCharArray());
            }
            LOGGER.info("MQTT client connecting");
            LOGGER.info("broker: {}", broker);
            LOGGER.info("client ID: {}", clientId);
            client.setCallback(this);
            client.connect(options);
            if(client.isConnected()){
                LOGGER.info("MQTT client connected");
            }else{
                LOGGER.info("MQTT client connect failed");
            }
        } catch (Exception e) {
            LOGGER.error("exception occurred while MQTT client connect broker", e);
            LOGGER.error("");
        }
    }


public SSLSocketFactory getSSLocketFactory(String caFile, String keyFile, String certFile) throws Exception {
        Security.addProvider(new BouncyCastleProvider());
        PEMReader reader = new PEMReader(new InputStreamReader(new ByteArrayInputStream(Files.readAllBytes(Paths.get(caFile)))));
        X509Certificate ca = (X509Certificate) reader.readObject();
        reader.close();

        reader = new PEMReader(new InputStreamReader(new ByteArrayInputStream(Files.readAllBytes(Paths.get(certFile)))));
        X509Certificate cert = (X509Certificate) reader.readObject();
        reader.close();

        reader = new PEMReader(new InputStreamReader(new ByteArrayInputStream(Files.readAllBytes(Paths.get(keyFile)))));
        KeyPair key = (KeyPair) reader.readObject();
        reader.close();


        KeyStore cas = KeyStore.getInstance(KeyStore.getDefaultType());
        cas.load(null, null);
        cas.setCertificateEntry("ca-certificate", ca);
        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(cas);

        KeyStore cs = KeyStore.getInstance(KeyStore.getDefaultType());
        cs.load(null, null);
        cs.setCertificateEntry("certificate", cert);
        cs.setKeyEntry("private-key", key.getPrivate(), new char[]{}, new Certificate[]{cert});
        KeyManagerFactory kmf = KeyManagerFactory.getInstance(KeyManagerFactory.getDefaultAlgorithm());
        kmf.init(cs, new char[]{});
        SSLContext context = SSLContext.getInstance("TLSv1.2");
        context.init(kmf.getKeyManagers(), tmf.getTrustManagers(), null);
        return context.getSocketFactory();
}
```
