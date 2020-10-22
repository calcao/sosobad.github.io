## create kubectl config file
+ create namespace
```bash
kubectl create namespace interface
```

+ create service account of namespace
```bash
kubectl create serviceaccount -n interface interface-user
```

+ get service account yaml
```bash
kubectl -n interface get serviceaccounts interface-user -o yaml
```

+ get service acount secret
```bash
kubectl -n interface get secret interface-user-token-tk9c9 -o yaml
```


+ create config file

```bash
# your server name goes here
server=https://localhost:8443
# the name of the secret containing the service account token goes here
name=default-token-sg96k
ca=$(kubectl get secret/$name -o jsonpath='{.data.ca\.crt}')
token=$(kubectl get secret/$name -o jsonpath='{.data.token}' | base64 --decode)
namespace=$(kubectl get secret/$name -o jsonpath='{.data.namespace}' | base64 --decode)
echo "
apiVersion: v1
kind: Config
clusters:
- name: default-cluster
  cluster:
    certificate-authority-data: ${ca}
    server: ${server}
contexts:
- name: default-context
  context:
    cluster: default-cluster
    namespace: default
    user: default-user
current-context: default-context
users:
- name: default-user
  user:
    token: ${token}
" > sa.kubeconfig
```