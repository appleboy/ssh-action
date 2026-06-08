# 🚀 GitHub Actions 的 SSH

[English](./README.md) | 繁體中文 | [简体中文](./README.zh-cn.md)

## 目錄

- [🚀 GitHub Actions 的 SSH](#-github-actions-的-ssh)
  - [目錄](#目錄)
  - [📖 簡介](#-簡介)
  - [🧩 核心概念與輸入參數](#-核心概念與輸入參數)
    - [🔌 連線設定](#-連線設定)
    - [🛠️ 指令設定](#️-指令設定)
    - [🌐 代理設定](#-代理設定)
  - [📤 輸出變數](#-輸出變數)
  - [⚡ 快速開始](#-快速開始)
  - [🔑 SSH 金鑰設定與 OpenSSH 相容性](#-ssh-金鑰設定與-openssh-相容性)
    - [設定 SSH 金鑰](#設定-ssh-金鑰)
      - [產生 RSA 金鑰](#產生-rsa-金鑰)
      - [產生 ED25519 金鑰](#產生-ed25519-金鑰)
    - [OpenSSH 相容性](#openssh-相容性)
  - [🛠️ 用法場景與進階範例](#️-用法場景與進階範例)
    - [使用密碼認證](#使用密碼認證)
    - [使用私鑰認證](#使用私鑰認證)
    - [多條指令](#多條指令)
    - [從檔案執行指令](#從檔案執行指令)
    - [多主機](#多主機)
    - [多主機不同埠號](#多主機不同埠號)
    - [多主機同步執行](#多主機同步執行)
    - [傳遞環境變數到 shell 腳本](#傳遞環境變數到-shell-腳本)
    - [擷取指令輸出](#擷取指令輸出)
  - [🌐 代理與跳板機用法](#-代理與跳板機用法)
  - [🛡️ 安全最佳實踐](#️-安全最佳實踐)
    - [保護你的私鑰](#保護你的私鑰)
    - [主機指紋驗證](#主機指紋驗證)
  - [🚨 錯誤處理與疑難排解](#-錯誤處理與疑難排解)
    - [常見問題](#常見問題)
      - [指令找不到（npm 或其他指令）](#指令找不到npm-或其他指令)
  - [🤝 貢獻](#-貢獻)
  - [📝 授權](#-授權)

---

## 📖 簡介

**SSH for GitHub Actions** 是一個強大的 [GitHub Action](https://github.com/features/actions)，可讓你在 CI/CD 工作流程中輕鬆且安全地執行遠端 SSH 指令。  
本專案以 [Golang](https://go.dev) 和 [drone-ssh](https://github.com/appleboy/drone-ssh) 建立，支援多主機、代理、進階認證等多種 SSH 場景。

![ssh workflow](./images/ssh-agent.png)

[![testing main branch](https://github.com/appleboy/ssh-action/actions/workflows/main.yml/badge.svg)](https://github.com/appleboy/ssh-action/actions/workflows/main.yml)
[![Trivy Security Scan](https://github.com/appleboy/ssh-action/actions/workflows/trivy-scan.yml/badge.svg)](https://github.com/appleboy/ssh-action/actions/workflows/trivy-scan.yml)

**簡報：** [SSH for GitHub Actions](https://speakerdeck.com/appleboy/ssh-for-github-actions)

---

## 🧩 核心概念與輸入參數

本 Action 提供彈性的 SSH 指令執行能力，並具備豐富的設定選項。

完整參數請參閱 [action.yml](./action.yml)。

### 🔌 連線設定

這些參數用於控制如何連線到遠端主機。

| 參數                | 說明                                          | 預設值 |
| ------------------- | --------------------------------------------- | ------ |
| host                | SSH 主機位址                                  |        |
| port                | SSH 埠號                                      | 22     |
| username            | SSH 使用者名稱                                |        |
| password            | SSH 密碼                                      |        |
| protocol            | SSH 協議版本（`tcp`、`tcp4`、`tcp6`）         | tcp    |
| sync                | 指定多個主機時同步執行                        | false  |
| timeout             | SSH 連線主機的逾時時間                        | 30s    |
| key                 | SSH 私鑰內容（如 `~/.ssh/id_rsa` 的原始內容） |        |
| key_path            | SSH 私鑰路徑                                  |        |
| passphrase          | SSH 私鑰密碼                                  |        |
| fingerprint         | 主機公鑰的 SHA256 指紋                        |        |
| use_insecure_cipher | 允許額外（不安全）的加密演算法                | false  |
| cipher              | 允許的加密演算法，未指定時使用預設值          |        |

---

### 🛠️ 指令設定

這些參數用於控制在遠端主機上執行的指令及相關行為。

| 參數            | 說明                                                  | 預設值 |
| --------------- | ----------------------------------------------------- | ------ |
| script          | 遠端執行的指令                                        |        |
| script_path     | 儲存庫中包含要遠端執行指令的檔案路徑                  |        |
| envs            | 傳遞給 shell 腳本的環境變數                           |        |
| envs_format     | 環境變數傳遞的彈性設定                                |        |
| allenvs         | 傳遞所有帶 `GITHUB_` 和 `INPUT_` 前綴的環境變數到腳本 | false  |
| command_timeout | SSH 指令執行逾時時間                                  | 10m    |
| debug           | 啟用除錯模式                                          | false  |
| request_pty     | 向伺服器請求偽終端                                    | false  |
| curl_insecure   | 允許 curl 連線無憑證的 SSL 網站                       | false  |
| capture_stdout  | 擷取指令的標準輸出作為 Action 輸出                    | false  |
| version         | drone-ssh 執行檔版本，未指定時使用最新版本            |        |
| retry_attempts  | SSH 連線失敗後的重試次數                              | 0      |
| retry_delay     | 每次重試之間的延遲                                      | 0s     |

---

### 🌐 代理設定

這些參數用於透過代理（跳板機）連線到目標主機。

| 參數                      | 說明                                      | 預設值 |
| ------------------------- | ----------------------------------------- | ------ |
| proxy_host                | SSH 代理主機                              |        |
| proxy_port                | SSH 代理埠號                              | 22     |
| proxy_username            | SSH 代理使用者名稱                        |        |
| proxy_password            | SSH 代理密碼                              |        |
| proxy_passphrase          | SSH 代理私鑰密碼                          |        |
| proxy_protocol            | SSH 代理協議版本（`tcp`、`tcp4`、`tcp6`） | tcp    |
| proxy_timeout             | SSH 連線代理主機的逾時時間                | 30s    |
| proxy_key                 | SSH 代理私鑰內容                          |        |
| proxy_key_path            | SSH 代理私鑰路徑                          |        |
| proxy_fingerprint         | 代理主機公鑰的 SHA256 指紋                |        |
| proxy_cipher              | 代理允許的加密演算法                      |        |
| proxy_use_insecure_cipher | 代理允許額外（不安全）的加密演算法        | false  |

> **注意：** 如需實現已移除的 `script_stop` 功能，請在 shell 腳本最上方加上 `set -e`。

---

## 📤 輸出變數

本 Action 提供以下輸出，可在後續步驟中使用：

| 輸出   | 說明                                                  |
| ------ | ----------------------------------------------------- |
| stdout | 執行指令的標準輸出（需設定 `capture_stdout: true`） |

---

## ⚡ 快速開始

只需簡單設定，即可在工作流程中執行遠端 SSH 指令：

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
          username: ${{ secrets.USERNAME }}
          password: ${{ secrets.PASSWORD }}
          port: ${{ secrets.PORT }}
          script: whoami
```

**輸出：**

```sh
======CMD======
whoami
======END======
out: your_username
===============================================
✅ Successfully executed commands to all hosts.
===============================================
```

---

## 🔑 SSH 金鑰設定與 OpenSSH 相容性

### 設定 SSH 金鑰

建議於本地端（非遠端伺服器）產生 SSH 金鑰。請以 GitHub Secrets 指定的使用者名稱登入並產生金鑰對：

#### 產生 RSA 金鑰

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

#### 產生 ED25519 金鑰

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

### OpenSSH 相容性

若出現以下錯誤：

```bash
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey]
```

在 Ubuntu 20.04+，你可能需明確允許 `ssh-rsa` 演算法。請於 OpenSSH 設定檔（`/etc/ssh/sshd_config` 或 `/etc/ssh/sshd_config.d/` 下的 drop-in 檔案）加入：

```text
CASignatureAlgorithms +ssh-rsa
```

或直接使用預設支援的 ED25519 金鑰：

```bash
ssh-keygen -t ed25519 -a 200 -C "your_email@example.com"
```

---

## 🛠️ 用法場景與進階範例

本節涵蓋常見與進階用法，包括多主機、代理、環境變數傳遞等。

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

### 重試 SSH 連線失敗

使用 `retry_attempts` 重試暫時性 SSH 連線失敗，例如 `dial tcp ...: i/o timeout`。預設不重試。遠端指令失敗不會重試。

```yaml
- name: 重試暫時性 SSH 連線失敗
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    retry_attempts: 3
    retry_delay: 5s
    script: whoami
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

### 擷取指令輸出

你可以擷取遠端指令的標準輸出，並在後續步驟中使用：

```yaml
- name: 執行並擷取輸出
  id: ssh
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    capture_stdout: true
    script: |
      echo "Hello World"
      hostname

- name: 使用擷取的輸出
  run: echo "SSH 輸出為 ${{ steps.ssh.outputs.stdout }}"
```

---

## 🌐 代理與跳板機用法

你可以透過代理（跳板機）連線到遠端主機，適用於進階網路拓撲。

```bash
+--------+       +----------+      +-----------+
| Laptop | <-->  | Jumphost | <--> | FooServer |
+--------+       +----------+      +-----------+
```

範例 `~/.ssh/config`：

```text
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

## 🛡️ 安全最佳實踐

### 保護你的私鑰

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

### 主機指紋驗證

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

## 🚨 錯誤處理與疑難排解

### 常見問題

#### 指令找不到（npm 或其他指令）

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
