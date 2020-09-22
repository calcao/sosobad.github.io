## git常用操作

### 完整迁移git仓库

1. 使用以下命令克隆就仓库，会在当前目录生成xxx.git文件夹
    ```bash
    git clone -bare 旧仓库地址
    ```

2. 推送到新地址
    ```bash
    cd xxx.git
    git push --mirror 新地址
    ```