## 自签证书


### 1.创建CA证书配置文件

```bash
[req]
distinguished_name  = req_distinguished_name
req_extensions = v3_req

[req_distinguished_name]
countryName           = Country Name (2 letter code)
countryName_default = CN
stateOrProvinceName   = State or Province Name (full name)
stateOrProvinceName_default = Beijing
organizationName          = Organization Name (eg, company)
organizationName_default = some company
commonName            = Common Name (eg, YOUR name)
commonName_default = myca

[v3_req]
basicConstraints = CA:true
keyUsage = critical, keyCertSign
```



### 2.创建服务端证书配置文件

```bash
[req]
distinguished_name  = req_distinguished_name
req_extensions     = v3_req

[req_distinguished_name]
countryName           = Country Name (2 letter code)
countryName_default   = CN
stateOrProvinceName   = State or Province Name (full name)
stateOrProvinceName_default = Beijing
localityName          = Locality Name (eg, city)
localityName_default  = Beijing
organizationName          = Organization Name (eg, company)
organizationName_default  = Example, Co.
commonName            = Common Name (eg, YOUR name)
commonName_max        = 64

####################################################################
[ ca ]
default_ca  = CA_default        # The default ca section

####################################################################
[ CA_default ]

dir     = . # Where everything is kept
certs       = $dir # Where the issued certs are kept
crl_dir     = $dir      # Where the issued crl are kept
database    = $dir/index.txt    # database index file.
#unique_subject = no            # Set to 'no' to allow creation of
                    # several ctificates with same subject.
new_certs_dir   = $dir      # default place for new certs.

certificate = $dir/ca.pem   # The CA certificate
serial      = $dir/serial       # The current serial number
crlnumber   = $dir/crlnumber    # the current crl number
                    # must be commented out to leave a V1 CRL
crl     = $dir/crl.pem      # The current CRL
private_key = $dir/private/cakey.pem# The private key
RANDFILE    = $dir/private/.rand    # private random number file

x509_extensions = usr_cert      # The extentions to add to the cert

# Comment out the following two lines for the "traditional"
# (and highly broken) format.
name_opt    = ca_default        # Subject Name options
cert_opt    = ca_default        # Certificate field options

# Extension copying option: use with caution.
# copy_extensions = copy

# Extensions to add to a CRL. Note: Netscape communicator chokes on V2 CRLs
# so this is commented out by default to leave a V1 CRL.
# crlnumber must also be commented out to leave a V1 CRL.
# crl_extensions    = crl_ext

default_days    = 365           # how long to certify for
default_crl_days= 30            # how long before next CRL
default_md  = default       # use public key default MD
preserve    = no            # keep passed DN ordering

# A few difference way of specifying how similar the request should look
# For type CA, the listed attributes must be the same, and the optional
# and supplied fields are just that :-)
policy      = policy_anything
[ policy_anything ]
countryName     = optional
stateOrProvinceName = optional
localityName        = optional
organizationName    = optional
organizationalUnitName  = optional
commonName      = supplied
emailAddress        = optional

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
IP.1 = 192.168.1.11
```



### 3.生成根证书

生成RSA私钥
```bash
openssl genrsa -out ca.key 2048
```
生成自谦证书
```bash
 openssl req -new -x509 -days 365 -key ca.key -out ca.crt \
            -subj "/C=CN/ST=Shanghai/L=Shanghai/O=somecompany/OU=test/CN=testssl" \
            -config ssl.conf \
            -extensions v3_req
```

### 4.生成服务端证书

生成服务端私钥
```bash
openssl genrsa -out server.key 2048
```

如果是IP地址，需要修改server.ssl.conf中[alt_name] IP.1地址，可以添加多个IP地址，如果为dns，common name(CN)填写dns即可，如CN=*.myweb.com

生成请求文件
```bash
 openssl req -new -key server.key \
        -out server.csr \
        -subj "/C=CN/ST=Shanghai/L=Shanghai/O=somecompany/OU=test/CN=localhost" \
        -config server.ssl.conf 
```

生成证书
```bash
openssl x509 -req -days 365 \
        -in server.csr \
        -CA ca.crt \
        -CAkey ca.key \
        -set_serial 01 \
        -out server.crt \
        -extensions v3_req \
        -extfile server.ssl.conf
```

私钥转换pkcs8格式，非必须
```bash
openssl pkcs8 -topk8 -nocrypt -in server.key -out server.pem
```

转der格式，非必须
```bash
openssl pkcs8 -topk8 -nocrypt -in server.key -outform DER -out server.der
```


### 5.生成客户端证书
如果需要双向认证，需要创建客户端证书
生成客户端秘钥
```bash
openssl genrsa -out client.key 2048
```

生成客户端请求文件
```bash
openssl req -new -key client.key -out client.csr \
        -subj "/C=CN/ST=Shanghai/L=Shanghai/O=somecompany/OU=test/CN=localhost"
```

生成证书
```bash
openssl x509 -req \
        -days 365 \
        -in client.csr \
        -CA ca.crt \
        -CAkey ca.key \
        -set_serial 01 \
        -out client.crt
```

转pkcs8格式，非必须
```bash
openssl pkcs8 -topk8 -nocrypt -in client.key -out client.pem
```

转der格式，非必须
```bash
openssl pkcs8 -topk8 -nocrypt -in client.key -outform DER -out client.der
```

### 6.删除请求文件

```bash
rm *.csr
```



### 7.使用openssl查看证书

查看key内容
```bash
openssl rsa -noout -text -in server.key
```

查看csr
```bash
openssl req -noout -text -in server.csr
```

查看证书
```bash
openssl x509 -noout -text -in server.crt
```

