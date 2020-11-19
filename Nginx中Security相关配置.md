## nginx安全相关配置


```properties

# 隐藏nginx版本号
server_tokens off;


# 禁止页面被iframe渲染
add_header X-Frame-Options SAMEORIGIN;



# 通过设置"X-Content-Type-Options: nosniff"响应标头，对script 和 styleSheet 在执行是通过MIME 类型来过滤掉不安全的文件
add_header X-Content-Type-Options: nosniff;


# XXS过滤， 1; mode = block 如果找到XSS，则不要渲染文档
add_header X-XSS-Protection "1; mode=block";

# CSP 的实质就是告诉浏览器哪些外部资源可以加载和执行，等同于提供白名单。它的实现和执行全部由浏览器完成，开发者只需提供配置
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; img-src 'self' ; style-src 'self' 'unsafe-inline'; font-src 'self' ; frame-src 'self'; object-src 'none'";


# 告诉浏览器只能通过HTTPS访问当前资源
add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

ssl_prefer_server_ciphers on;
# disable SSLv3
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers 'EECDH+ECDSA+AESGCM EECDH+aRSA+AESGCM EECDH+ECDSA+SHA384 EECDH+ECDSA+SHA256 EECDH+aRSA+SHA384 EECDH+aRSA+SHA256 EECDH+aRSA+RC4 EECDH RSA+AESGCM RSA+AES !RC4 !aNULL !eNULL !LOW !3DES !MD5 !EXP !PSK !SRP !DSS';

# 开启session恢复提高https性能
ssl_session_cache shared:SSL:50m;
ssl_session_timeout 1d;
ssl_session_tickets off;
```

参考：[https://gist.github.com/plentz/6737338#file-nginx-conf](https://gist.github.com/plentz/6737338#file-nginx-conf)
