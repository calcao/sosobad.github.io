## git常用操作

### 完整迁移git仓库

1. 使用以下命令克隆就仓库，会在当前目录生成xxx.git文件夹
    ```bash
    git clone --bare 旧仓库地址
    ```

2. 推送到新地址
    ```bash
    cd xxx.git
    git push --mirror 新地址
    ```

### 取消追踪

```bash
git rm -r --cached file
```


### 丢弃本地修改

```bash
git checkout .
```

### git tag

1. 添加tag
    ```bash
    git tag v0.0.1
    ```

2. 删除tag 
    ```bash
    git tag -d v0.0.1
    ```

3. 在之前的某个commit上打tag
    ```bash
    git tang -a v0.0.2 [commitId]
    ```

4. 提交tag
    ```bash
    git push origin v0.1.2 # 将v0.1.2标签提交到git服务器
    git push origin –tags # 将本地所有标签一次性提交到git服务器
    ```

5. 删除远端tag
   ```bash
    git tag -d v0.1.1

    git push origin :refs/tags/v0.1.1

   ```