## 树莓派无屏幕无线远程


### 配置wifi
在/boot目录下添加wpa_supplicant.conf文件，内容如下：

```bash
country=CN
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
 
network={
    ssid="无线网络名称"
    psk="密码"
    key_mgmt=WPA-PSK
    priority=1
}

network={
    ssid="无线网络名称2"
    psk="密码2"
    key_mgmt=WPA-PSK
    priority=2
}

```


### 配置SSH
在/boot目录下创建空白ssh文件（小写）