## letsencrypt安装
环境： ubuntu 16.04

### 关于certbot-auto
*certbot-auto*已过时，不再支持所有系统，详情见[https://community.letsencrypt.org/t/certbot-auto-no-longer-works-on-debian-based-systems/139702/6]('https://community.letsencrypt.org/t/certbot-auto-no-longer-works-on-debian-based-systems/139702/6')

### 基于snap安装

```bash
apt update

apt install snapd -y

ln -s /snap/bin/certbot /usr/bin/certbot

apt install certbot -y
```

## 启动Nginx

```bash
docker run \
    -d \
    --name example.com \
    -p 80:80 \
    -v /html/example:/usr/share/nginx/html \
    nginx
```


## 生成证书

```bash
certbot certonly  --webroot -w /html/example --email admin@example.com -d example.com -d www.example.com
```
-w指定web目录,需要确保存在至少一条A或者AAAA类型的dns记录指向当前server公网静态IP，并需要保证当前80端口可访问到当前web服务，否则验证失败，生成证书目录位于/etc/letsencrypt/live/example.com



## 配置nginx

```properties
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

    limit_req_zone $binary_remote_addr zone=mylimit:10m rate=10r/s;

    server {
        listen 443 ssl;
        server_name  example.com www.example.com;
        server_tokens off;
        ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

        add_header X-Frame-Options "SAMEORIGIN";
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=63072000; includeSubdomains; preload";
        add_header Cache-Control no-store;
        add_header X-Content-Type-Options: nosniff;
        add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; img-src 'self' data:; style-src 'self' 'unsafe-inline'; font-src 'self' ; frame-src 'self'; object-src 'self'";

        location / {
            root   /html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /html;
        }
    }


    server {
        listen 80;
        server_name  example.com www.example.com;
        return 301 https://$server_name$request_uri;
    }
}

```


## 创建https服务

+ 关闭原80端口Nginx container


+ 启动Nginx

```bash

docker run \
    -d \
    -p 80:80 \
    -p 443:443 \
    --name example.com \
    -v /nginx/nginx.conf:/etc/nginx/nginx.conf \
    -v /html/example:/html \
    -v /etc/letsencrypt:/etc/letsencrypt \
    nginx
```



## 自动更新证书
letsencrypt生成证书期限为90天，可以通过cron job自动刷新证书

编辑crontab文件

```bash
crontab -e
```

添加内容

```bash
0 23 1 * * /usr/bin/certbot renew --quiet
```
每个月的第一天的23点刷新

