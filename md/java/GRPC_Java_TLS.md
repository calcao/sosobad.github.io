# GRPC-Java添加TLS双向认证



## 生成证书

+ 创建私钥
    ```bash
    openssl genrsa -out ca.key 4096
    ```

+ 创建CA证书
    ```bash
    openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Honeywell/OU=Ess/CN=localhost"
    ```

+ 生成服务端私钥证书
    ```bash
    openssl genrsa -out server.key 4096
    openssl req -new -key server.key -out server.csr -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Honeywell/OU=Ess/CN=localhost"
    openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt
    ```

+ 生成客户端证书
    ```bash
    openssl genrsa -out client.key 4096
    openssl req -new -key client.key -out client.csr -subj "/C=CN/ST=Shanghai/L=Shanghai/O=Honeywell/OU=Ess/CN=localhost"
    openssl x509 -req -days 3650 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
    ```

+ 转换pkcs8格式
    ```bash
    openssl pkcs8 -topk8 -nocrypt -in client.key -out client.pem
    openssl pkcs8 -topk8 -nocrypt -in server.key -out server.pem
    ```

    ```bash
    openssl pkcs8 -topk8 -nocrypt -in client.key -outform DER -out client.der
    openssl pkcs8 -topk8 -nocrypt -in server.key -outform DER -out server.der
    ```



## Server端代码
```java
        try {
            if(SysEnv.ENABLE_SSL){
                LOGGER.info("GRPC server start with SSL mode");
                File certFile = new File("./server.crt");
                File privateKeyFile = new File("./server.pem");
                File trustCrtFile = new File("./ca.crt");
                SslContextBuilder builder = SslContextBuilder.forServer(certFile, privateKeyFile)
                        .trustManager(trustCrtFile)
                        // 需要双向认证
                        .clientAuth(ClientAuth.REQUIRE);
                sslContext = GrpcSslContexts.configure(builder, SslProvider.OPENSSL).build();
            }
            server = NettyServerBuilder.forPort(port)
                    .sslContext(sslContext)
                    .addService(new GatewayServiceGrpcImpl())
                    .keepAliveTime(KEEP_ALIVE_TIME, TimeUnit.SECONDS)
                    .keepAliveTimeout(KEEP_ALIVE_TIMEOUT, TimeUnit.SECONDS)
                    .maxConnectionIdle(MAX_CONNECTION_IDLE, TimeUnit.SECONDS)
                    .permitKeepAliveWithoutCalls(PERMIT_KEEP_ALIVE_WITHOUT_CALLS)
                    .handshakeTimeout(HANDSHAKE_TIMEOUT, TimeUnit.SECONDS)
                    .build()
                    .start();
        } catch (IOException e) {
            LOGGER.error("Exception starting grpc server", e);
        }
        LOGGER.info("GRPC server running at {}", port);
```



## Client代码
```java

        File trustCrts = new File("./ca.crt");
        File clientCrt = new File("./client.crt");
        File clientPrivateKey = new File("./client.pem");

        SslContext sslContext = GrpcSslContexts
                .forClient()
                .trustManager(trustCrts)
                .keyManager(clientCrt, clientPrivateKey)
                .build();

        ManagedChannel channel = NettyChannelBuilder.forAddress("localhost", 9001)
                .negotiationType(NegotiationType.TLS)
                .sslContext(sslContext)
                .build();

        GatewayServiceGrpc.GatewayServiceBlockingStub gateway = GatewayServiceGrpc.newBlockingStub(channel);

        HistoryMsgRequest request = HistoryMsgRequest.newBuilder()
                .setPage(1)
                .setPageSize(1)
                .setStartTime(System.currentTimeMillis() - 10*24*60*60*1000)
                .setEndTime(System.currentTimeMillis())
                .setPaging(1)
                .build();

        HistoryMsgResponse historyMsg = gateway.getHistoryMsg(request);
```