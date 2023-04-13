# 🚀 用於 GitHub Actions 的 SSH

[GitHub Action](https://github.com/features/actions) for executing remote ssh commands.

![ssh workflow](./images/ssh-workflow.png)

[![Actions Status](https://github.com/appleboy/ssh-action/workflows/remote%20ssh%20command/badge.svg)](https://github.com/appleboy/ssh-action/actions)

**注意**： 只支援在 **Linux** [docker](https://www.docker.com/) 容器上執行。

## 輸入變數

更詳細的資訊，請參閱 [action.yml](./action.yml)。

* `host` - SSH 主機
* `port` - SSH 連接埠，預設為 `22`
* `username` - SSH 使用者名稱
* `password` - SSH 密碼
* `passphrase` - 通常用於加密私鑰的 passphrase
* `sync` - 同步執行多個主機上的命令，預設為 false
* `timeout` - SSH 連接到遠端主機的超時時間，預設為 `30s`
* `command_timeout` - SSH 命令超時時間，預設為 10m
* `key` - SSH 私鑰的內容，例如 ~/.ssh/id_rsa 的原始內容，請記得包含 BEGIN 和 END 行
* `key_path` - SSH 私鑰的路徑
* `fingerprint` - 主機公鑰的 SHA256 指紋，預設為略過驗證
* `script` - 執行命令
* `script_stop` - 當出現第一個錯誤時停止執行命令
* `envs` - 傳遞環境變數到 shell script
* `debug` - 啟用偵錯模式
* `use_insecure_cipher` - 使用不安全的密碼（ciphers）進行加密，參見 [#56](https://github.com/appleboy/ssh-action/issues/56)
* `cipher` - 允許使用的密碼（ciphers）演算法。如果未指定，則使用適當的演算法

SSH 代理設置:

* `proxy_host` - 代理主機
* `proxy_port` - 代理端口，預設為 `22`
* `proxy_username` - 代理使用者名稱
* `proxy_password` - 代理密碼
* `proxy_passphrase` - 密碼通常用於加密私有金鑰
* `proxy_timeout` - SSH 連線至代理主機的逾時時間，預設為 `30s`
* `proxy_key` - SSH 代理私有金鑰內容
* `proxy_key_path` - SSH 代理私有金鑰路徑
* `proxy_fingerprint` - 代理主機公鑰的 SHA256 指紋，預設為跳過驗證
* `proxy_use_insecure_cipher` - 使用不安全的加密方式，請參閱 [#56](https://github.com/appleboy/ssh-action/issues/56)
* `proxy_cipher` - 允許的加密算法。如果未指定，則使用合理的算法

## 使用方式

執行遠端 SSH 命令

```yaml
name: remote ssh command
on: [push]
jobs:

  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - name: executing remote ssh commands using password
      uses: appleboy/ssh-action@v0.1.10
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        password: ${{ secrets.PASSWORD }}
        port: ${{ secrets.PORT }}
        script: whoami
```

畫面輸出

```sh
======CMD======
whoami
======END======
out: ***
==============================================
✅ Successfully executed commands to all host.
==============================================
```

### 設置 SSH 金鑰

請在創建 SSH 金鑰並使用 SSH 金鑰時遵循以下步驟。最佳做法是在本地機器上創建 SSH 金鑰而不是遠端機器上。請使用 Github Secrets 中指定的用戶名登錄。生成 RSA 金鑰：

### 生成 RSA 金鑰

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### 生成 ed25519 金鑰

```bash
ssh-keygen -t ed25519 -a 200 -C "your_email@example.com"
```

將新生成的金鑰添加到已授權的金鑰中。詳細了解已授權的金鑰請點擊[此處](https://www.ssh.com/ssh/authorized_keys/).

### 將 RSA 金鑰添加到已授權金鑰中

```bash
cat .ssh/id_rsa.pub | ssh b@B 'cat >> .ssh/authorized_keys'
```

### 將 ed25519 金鑰添加到已授權金鑰中

```bash
cat .ssh/id_ed25519.pub | ssh b@B 'cat >> .ssh/authorized_keys'
```

複製私鑰內容，然後將其粘貼到 Github Secrets 中。

### 複製 rsa 私鑰內容

```bash
clip < ~/.ssh/id_rsa
```

### 複製 ed25519 私鑰內容

```bash
clip < ~/.ssh/id_ed25519
```

有關無需密碼登錄 SSH 的詳細信息，請[參見該網站](http://www.linuxproblem.org/art_9.html)。

**來自讀者的注意事項**： 根據您的 SSH 版本，您可能還需要進行以下更改：

* 將公鑰放在 `.ssh/authorized_keys2` 中
* 將 `.ssh` 的權限更改為700
* 將 `.ssh/authorized_keys2` 的權限更改為640

### 如果你使用的是 OpenSSH

如果您正在使用 OpenSSH，並出現以下錯誤：

```bash
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey]
```

請確保您所選擇的密鑰演算法得到支援。在 Ubuntu 20.04 或更高版本上，您必須明確允許使用 SSH-RSA 演算法。請在 OpenSSH 守護進程文件中添加以下行（它可以是 `/etc/ssh/sshd_config` 或 `/etc/ssh/sshd_config.d/` 中的一個附著文件）：

```bash
CASignatureAlgorithms +ssh-rsa
```

或者，`Ed25519` 密鑰在 OpenSSH 中默認被接受。如果需要，您可以使用它來替代 RSA。

```bash
ssh-keygen -t ed25519 -a 200 -C "your_email@example.com"
```

### Example

#### 使用密碼執行遠端 SSH 命令

```yaml
- name: executing remote ssh commands using password
  uses: appleboy/ssh-action@v0.1.10
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    password: ${{ secrets.PASSWORD }}
    port: ${{ secrets.PORT }}
    script: whoami
```

#### 使用私鑰

```yaml
- name: executing remote ssh commands using ssh key
  uses: appleboy/ssh-action@v0.1.10
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    script: whoami
```

#### 多個命令

```yaml
- name: multiple command
  uses: appleboy/ssh-action@v0.1.10
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    script: |
      whoami
      ls -al
```

![result](./images/output-result.png)

#### 多台主機

```diff
  - name: multiple host
    uses: appleboy/ssh-action@v0.1.10
    with:
-     host: "foo.com"
+     host: "foo.com,bar.com"
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      port: ${{ secrets.PORT }}
      script: |
        whoami
        ls -al
```

#### 多個不同端口的主機

```diff
  - name: multiple host
    uses: appleboy/ssh-action@v0.1.10
    with:
-     host: "foo.com"
+     host: "foo.com:1234,bar.com:5678"
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      script: |
        whoami
        ls -al
```

#### 在多個主機上同步執行

```diff
  - name: multiple host
    uses: appleboy/ssh-action@v0.1.10
    with:
      host: "foo.com,bar.com"
+     sync: true
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      port: ${{ secrets.PORT }}
      script: |
        whoami
        ls -al
```

#### 將環境變量傳遞到 Shell 腳本

```diff
  - name: pass environment
    uses: appleboy/ssh-action@v0.1.10
+   env:
+     FOO: "BAR"
+     BAR: "FOO"
+     SHA: ${{ github.sha }}
    with:
      host: ${{ secrets.HOST }}
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      port: ${{ secrets.PORT }}
+     envs: FOO,BAR,SHA
      script: |
        echo "I am $FOO"
        echo "I am $BAR"
        echo "sha: $SHA"
```

_在 `env` 對象中，您需要將每個環境變量作為字符串傳遞，傳遞 `Integer` 數據類型或任何其他類型可能會產生意外結果。_

#### 在第一次失敗後停止腳本

> ex: missing `abc` folder

```diff
  - name: stop script if command error
    uses: appleboy/ssh-action@v0.1.10
    with:
      host: ${{ secrets.HOST }}
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      port: ${{ secrets.PORT }}
+     script_stop: true
      script: |
        mkdir abc/def
        ls -al
```

畫面輸出:

```sh
======CMD======
mkdir abc/def
ls -al

======END======
2019/11/21 01:16:21 Process exited with status 1
err: mkdir: cannot create directory ‘abc/def’: No such file or directory
##[error]Docker run failed with exit code 1
```

#### 如何使用 `ProxyCommand` 連接遠程服務器？

```bash
+--------+       +----------+      +-----------+
| Laptop | <-->  | Jumphost | <--> | FooServer |
+--------+       +----------+      +-----------+
```

在您的 `~/.ssh/config` 文件中，您會看到以下內容。

```bash
Host Jumphost
  HostName Jumphost
  User ubuntu
  Port 22
  IdentityFile ~/.ssh/keys/jump_host.pem

Host FooServer
  HostName FooServer
  User ubuntu
  Port 22
  ProxyCommand ssh -q -W %h:%p Jumphost
```

#### 如何將其轉換為 GitHubActions 的 YAML 格式？

```diff
  - name: ssh proxy command
    uses: appleboy/ssh-action@v0.1.10
    with:
      host: ${{ secrets.HOST }}
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      port: ${{ secrets.PORT }}
+     proxy_host: ${{ secrets.PROXY_HOST }}
+     proxy_username: ${{ secrets.PROXY_USERNAME }}
+     proxy_key: ${{ secrets.PROXY_KEY }}
+     proxy_port: ${{ secrets.PROXY_PORT }}
      script: |
        mkdir abc/def
        ls -al
```

#### 如何保護私鑰？

密碼短語通常用於加密私鑰。這使得攻擊者無法單獨使用密鑰文件。文件泄露可能來自備份或停用的硬件，黑客通常可以從受攻擊系統中洩露文件。因此，保護私鑰非常重要。

```diff
  - name: ssh key passphrase
    uses: appleboy/ssh-action@v0.1.10
    with:
      host: ${{ secrets.HOST }}
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      port: ${{ secrets.PORT }}
+     passphrase: ${{ secrets.PASSPHRASE }}
      script: |
        whoami
        ls -al
```

#### 使用主機指紋驗證

設置 SSH 主機指紋驗證可以幫助防止中間人攻擊。在設置之前，運行以下命令以獲取 SSH 主機指紋。請記得將 `ed25519` 替換為您的適當金鑰類型（`rsa`、 `dsa`等），而 `example.com` 則替換為您的主機。

現代 OpenSSH 版本中，需要提取的_默認金鑰_類型是 `rsa`（從版本 5.1 開始）、`ecdsa`（從版本 6.0 開始）和 `ed25519`（從版本 6.7 開始）。

```sh
ssh example.com ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub | cut -d ' ' -f2
```

現在您可以調整您的配置：

```diff
  - name: ssh key passphrase
    uses: appleboy/ssh-action@v0.1.10
    with:
      host: ${{ secrets.HOST }}
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      port: ${{ secrets.PORT }}
+     fingerprint: ${{ secrets.FINGERPRINT }}
      script: |
        whoami
        ls -al
```

## 貢獻

我們非常希望您為 `appleboy/ssh-action` 做出貢獻，歡迎提交請求！

## 授權方式

本項目中的腳本和文檔采用 [MIT](LICENSE) 許可證 發布。
