## Ubuntu添加开机启动项


1. 添加脚本到/etc/init.d/目录下
```bash
chmod 0755 my-service.sh
cp my-service.sh /etc/init.d/
```


2. 添加开机启动服务
```bash
update-rc.d my-service.sh defaults 200
```
其中200为启动顺序，如需依赖网络等，需要设置一个较大的数据

