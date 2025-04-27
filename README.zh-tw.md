# 🚀 GitHub Actions 的 SSH

[English](./README.md) | 繁體中文 | [简体中文](./README.zh-cn.md)

## 目錄

- [🚀 GitHub Actions 的 SSH](#-github-actions-的-ssh)
  - [目錄](#目錄)
  - [📥 輸入參數](#-輸入參數)
  - [🚦 使用範例](#-使用範例)
  - [🔑 設定 SSH 金鑰](#-設定-ssh-金鑰)
    - [產生 RSA 金鑰](#產生-rsa-金鑰)
    - [產生 ED25519 金鑰](#產生-ed25519-金鑰)
  - [🛡️ OpenSSH 相容性](#️-openssh-相容性)
  - [🧑‍💻 更多用法範例](#-更多用法範例)
    - [使用密碼認證](#使用密碼認證)
    - [使用私鑰認證](#使用私鑰認證)
    - [多條指令](#多條指令)
    - [從檔案執行指令](#從檔案執行指令)
    - [多主機](#多主機)
    - [多主機不同埠號](#多主機不同埠號)
    - [多主機同步執行](#多主機同步執行)
    - [傳遞環境變數到 shell 腳本](#傳遞環境變數到-shell-腳本)
  - [🌐 使用 ProxyCommand（跳板機）](#-使用-proxycommand跳板機)
  - [🔒 保護你的私鑰](#-保護你的私鑰)
  - [🖐️ 主機指紋驗證](#️-主機指紋驗證)
  - [❓ 常見問題](#-常見問題)
    - [指令找不到（npm 或其他指令）](#指令找不到npm-或其他指令)
  - [🤝 貢獻](#-貢獻)
  - [📝 授權](#-授權)

一個讓你輕鬆安全執行遠端 SSH 指令的 [GitHub Action](https://github.com/features/actions)。

![ssh workflow](./images/ssh-workflow.png)

[![testing main branch](https://github.com/appleboy/ssh-action/actions/workflows/main.yml/badge.svg)](https://github.com/appleboy/ssh-action/actions/workflows/main.yml)

本專案以 [Golang](https://go.dev) 和 [drone-ssh](https://github.com/appleboy/drone-ssh) 建立。

---

## 📥 輸入參數

完整參數請參閱 [action.yml](./action.yml)。

| 參數                      | 說明                                                  | 預設值 |
| ------------------------- | ----------------------------------------------------- | ------ |
| host                      | SSH 主機位址                                          |        |
| port                      | SSH 埠號                                              | 22     |
| passphrase                | SSH 私鑰密碼                                          |        |
| username                  | SSH 使用者名稱                                        |        |
| password                  | SSH 密碼                                              |        |
| protocol                  | SSH 協議版本（`tcp`、`tcp4`、`tcp6`）                 | tcp    |
| sync                      | 指定多個主機時同步執行                                | false  |
| use_insecure_cipher       | 允許額外（不安全）的加密演算法                        | false  |
| cipher                    | 允許的加密演算法，未指定時使用預設值                  |        |
| timeout                   | SSH 連線主機的逾時時間                                | 30s    |
| command_timeout           | SSH 指令執行逾時時間                                  | 10m    |
| key                       | SSH 私鑰內容（如 `~/.ssh/id_rsa` 的原始內容）         |        |
| key_path                  | SSH 私鑰路徑                                          |        |
| fingerprint               | 主機公鑰的 SHA256 指紋                                |        |
| proxy_host                | SSH 代理主機                                          |        |
| proxy_port                | SSH 代理埠號                                          | 22     |
| proxy_protocol            | SSH 代理協議版本（`tcp`、`tcp4`、`tcp6`）             | tcp    |
| proxy_username            | SSH 代理使用者名稱                                    |        |
| proxy_password            | SSH 代理密碼                                          |        |
| proxy_passphrase          | SSH 代理私鑰密碼                                      |        |
| proxy_timeout             | SSH 連線代理主機的逾時時間                            | 30s    |
| proxy_key                 | SSH 代理私鑰內容                                      |        |
| proxy_key_path            | SSH 代理私鑰路徑                                      |        |
| proxy_fingerprint         | 代理主機公鑰的 SHA256 指紋                            |        |
| proxy_cipher              | 代理允許的加密演算法                                  |        |
| proxy_use_insecure_cipher | 代理允許額外（不安全）的加密演算法                    | false  |
| script                    | 遠端執行的指令                                        |        |
| script_path               | 包含要執行指令的檔案路徑                              |        |
| envs                      | 傳遞給 shell 腳本的環境變數                           |        |
| envs_format               | 環境變數傳遞的彈性設定                                |        |
| debug                     | 啟用除錯模式                                          | false  |
| allenvs                   | 傳遞所有帶 `GITHUB_` 和 `INPUT_` 前綴的環境變數到腳本 | false  |
| request_pty               | 向伺服器請求偽終端                                    | false  |
| curl_insecure             | 允許 curl 連線無憑證的 SSL 網站                       | false  |
| version                   | drone-ssh 執行檔版本，未指定時使用最新版本            |        |

> **注意：** 如需實現已移除的 `script_stop` 功能，請在 shell 腳本最上方加上 `set -e`。

---

## 🚦 使用範例

在工作流程中執行遠端 SSH 指令：

```yaml
name: Remote SSH Command
on: [push]
jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: 執行遠端 SSH 指令（密碼認證）
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.HOST }}
          username: linuxserver.io
          password: ${{ secrets.PASSWORD }}
          port: ${{ secrets.PORT }}
          script: whoami
```

**輸出：**

```sh
======CMD======
whoami
======END======
linuxserver.io
===============================================
✅ Successfully executed commands to all hosts.
===============================================
```

---

## 🔑 設定 SSH 金鑰

建議於本地端（非遠端伺服器）產生 SSH 金鑰。請以 GitHub Secrets 指定的使用者名稱登入並產生金鑰對：

### 產生 RSA 金鑰

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### 產生 ED25519 金鑰

```bash
ssh-keygen -t ed25519 -a 200 -C "your_email@example.com"
```

將新產生的公鑰加入伺服器的 authorized_keys。 [了解更多 authorized_keys](https://www.ssh.com/ssh/authorized_keys/)

```bash
# 加入 RSA 公鑰
cat .ssh/id_rsa.pub | ssh user@host 'cat >> .ssh/authorized_keys'

# 加入 ED25519 公鑰
cat .ssh/id_ed25519.pub | ssh user@host 'cat >> .ssh/authorized_keys'
```

複製私鑰內容並貼到 GitHub Secrets。

```bash
# macOS
pbcopy < ~/.ssh/id_rsa
# Ubuntu
xclip < ~/.ssh/id_rsa
```

> **提示：** 複製內容需包含 `-----BEGIN OPENSSH PRIVATE KEY-----` 到 `-----END OPENSSH PRIVATE KEY-----`（含）。

ED25519 同理：

```bash
# macOS
pbcopy < ~/.ssh/id_ed25519
# Ubuntu
xclip < ~/.ssh/id_ed25519
```

更多資訊：[SSH 免密碼登入](http://www.linuxproblem.org/art_9.html)。

> **注意：** 根據 SSH 版本，可能還需：
>
> - 將公鑰放入 `.ssh/authorized_keys2`
> - 設定 `.ssh` 權限為 700
> - 設定 `.ssh/authorized_keys2` 權限為 640

---

## 🛡️ OpenSSH 相容性

若出現以下錯誤：

```bash
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey]
```

在 Ubuntu 20.04+，你可能需明確允許 `ssh-rsa` 演算法。請於 OpenSSH 設定檔（`/etc/ssh/sshd_config` 或 `/etc/ssh/sshd_config.d/` 下的 drop-in 檔案）加入：

```bash
CASignatureAlgorithms +ssh-rsa
```

或直接使用預設支援的 ED25519 金鑰：

```bash
ssh-keygen -t ed25519 -a 200 -C "your_email@example.com"
```

---

## 🧑‍💻 更多用法範例

### 使用密碼認證

```yaml
- name: 執行遠端 SSH 指令（密碼認證）
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    password: ${{ secrets.PASSWORD }}
    port: ${{ secrets.PORT }}
    script: whoami
```

### 使用私鑰認證

```yaml
- name: 執行遠端 SSH 指令（私鑰認證）
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    script: whoami
```

### 多條指令

```yaml
- name: 多條指令
  uses: appleboy/ssh-action@v1
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

### 從檔案執行指令

```yaml
- name: 檔案指令
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    script_path: scripts/script.sh
```

### 多主機

```diff
  - name: 多主機
    uses: appleboy/ssh-action@v1
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

預設 `port` 為 `22`。

### 多主機不同埠號

```diff
  - name: 多主機
    uses: appleboy/ssh-action@v1
    with:
-     host: "foo.com"
+     host: "foo.com:1234,bar.com:5678"
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      script: |
        whoami
        ls -al
```

### 多主機同步執行

```diff
  - name: 多主機
    uses: appleboy/ssh-action@v1
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

### 傳遞環境變數到 shell 腳本

```diff
  - name: 傳遞環境變數
    uses: appleboy/ssh-action@v1
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

> _`env` 物件中的所有環境變數必須為字串。傳遞整數或其他型別可能導致非預期結果。_

---

## 🌐 使用 ProxyCommand（跳板機）

```bash
+--------+       +----------+      +-----------+
| Laptop | <-->  | Jumphost | <--> | FooServer |
+--------+       +----------+      +-----------+
```

範例 `~/.ssh/config`：

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

**GitHub Actions YAML:**

```diff
  - name: SSH 代理指令
    uses: appleboy/ssh-action@v1
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

---

## 🔒 保護你的私鑰

密碼短語會加密你的私鑰，即使外洩也無法被攻擊者直接利用。請務必妥善保管私鑰。

```diff
  - name: SSH 私鑰密碼
    uses: appleboy/ssh-action@v1
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

---

## 🖐️ 主機指紋驗證

驗證 SSH 主機指紋有助於防止中間人攻擊。取得主機指紋（將 `ed25519` 換成你的金鑰型別，`example.com` 換成你的主機）：

```sh
ssh example.com ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub | cut -d ' ' -f2
```

更新設定：

```diff
  - name: SSH 私鑰密碼
    uses: appleboy/ssh-action@v1
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

---

## ❓ 常見問題

### 指令找不到（npm 或其他指令）

若遇到 "command not found" 錯誤，請參考 [此討論](https://github.com/appleboy/ssh-action/issues/31#issuecomment-1006565847) 了解互動式與非互動式 shell 差異。

許多 Linux 發行版的 `/etc/bash.bashrc` 包含如下內容：

```sh
# If not running interactively, don't do anything
[ -z "$PS1" ] && return
```

請將該行註解掉或使用指令的絕對路徑。

---

## 🤝 貢獻

歡迎貢獻！請提交 Pull Request 改善 `appleboy/ssh-action`。

---

## 📝 授權

本專案採用 [MIT License](LICENSE) 授權。
