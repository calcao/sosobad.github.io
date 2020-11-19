## ubuntu防火墙配置


### 1.查看防火墙状态
```bash
ufw status
```

如果防火墙状态为 Status: inactive，则需要开启防火墙，如果需要使用Docker，可能会有冲突，因为他们都同时修改iptables，需要将修改Docker配置，在/etc/default/docker文件中添加
```bash
DOCKER_OPTS="--iptables=false"
```
重启docker
```bash
systemctl restart docker
```
开启防火墙
```bash
sudo ufw enable
```


### 2.配置策略

默认关闭又有端口
```bash
sudo ufw default deny
```

开启22，443端口
```bash
sudo ufw allow 22
sudo ufw allow 443
```

开放所有端口给某个网段
```bash
sudo ufw allow from 192.168.1.0/24
```


### 3.删除规则
查看规则序号
```bash
sudo ufw status numbered
```

通过序号删除规则
```bash
sudo ufw delete 1
```




参考：[1](https://help.ubuntu.com/community/UFW)
     [2](https://www.digitalocean.com/community/questions/sudo-ufw-status-return-inactive)