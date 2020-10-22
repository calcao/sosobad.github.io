## K3S离线安装

### 下载离线文件
下载地址: [https://github.com/rancher/k3s/releases](https://github.com/rancher/k3s/releases)  
按照当前系统类型，下载以下文件：  
+ k3s-airgap-images-amd64.tar ---- 离线镜像包
+ k3s ---- k3s可执行文件

### 下载安装脚本
```bash
curl -sfL https://get.k3s.io > k3s-install.sh
```

### 安装K3S可执行文件
```bash
cp ./k3s /usr/local/bin
chmod 755 /usr/local/bin/k3s
```

### 配置离线镜像包
```bash
mkdir -p /var/lib/rancher/k3s/agent/images/
cp k3s-airgap-images-amd64.tar /var/lib/rancher/k3s/agent/images/
```

### 安装K3S Server
安装配置项可查看[install options](https://rancher.com/docs/k3s/latest/en/installation/install-options/)
```bash
chmod 755 k3s-install.sh
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_KUBECONFIG_MODE=644 ./packages/k3s-install.sh
```

### 验证安装
可通过kubctl查看k3s安装情况
```bash
kubectl -n kube-system get all
```

### 安装K3s Agent
```bash
export K3S_URL='your server address'
INSTALL_K3S_SKIP_DOWNLOAD=true K3S_KUBECONFIG_MODE=644 ./packages/k3s-install.sh
```

### 卸载
执行/usr/local/bin/k3s-uninstall.sh

