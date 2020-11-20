
```bash

user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;

    keepalive_timeout  65;


    map $http_upgrade $connection_upgrade {
            default upgrade;
            '' close;
    }

    upstream api {
       server 192.168.1.101:8080;
    }

    limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;

    server {
        listen       443 ssl;
        server_name  localhost;


        location / {
            root   /html;
            index  index.html index.htm;
        }

        # api
        location /api {
            limit_req zone=mylimit burst=30 nodelay;
            limit_req_status 598;
            rewrite /v1/(.*) /$1  break;
            proxy_pass https://_nsapi/v1;
            # proxy_ssl_name localhost;
            # proxy_ssl_certificate /certs/client.crt;
            # proxy_ssl_certificate_key /certs/client.pem;
            # proxy_ssl_trusted_certificate /certs/ca.crt;
            # proxy_ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
            # proxy_ssl_ciphers HIGH:!aNULL:!MD5;
            # proxy_ssl_verify on;
            # proxy_ssl_verify_depth 2;
        }

        # web
        location /web {
            rewrite ^/web(.*) /$1 break;
            limit_req zone=mylimit burst=30 nodelay;
            limit_req_status 598;
            proxy_pass http://192.168.1.102;
        }

        # websocket
        location /websocket {
            limit_req zone=mylimit burst=30 nodelay;
            limit_req_status 598;
            proxy_read_timeout 999999999;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $connection_upgrade;
            proxy_pass https://api;
            # proxy_ssl_name localhost;
            # proxy_ssl_certificate /certs/client.crt;
            # proxy_ssl_certificate_key /certs/client.pem;
            # proxy_ssl_trusted_certificate /certs/ca.crt;
            # proxy_ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
            # proxy_ssl_ciphers HIGH:!aNULL:!MD5;
            # proxy_ssl_verify on;
            # proxy_ssl_verify_depth 2;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /html;
        }
    }
}



```