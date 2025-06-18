# 🚀 用于 GitHub Actions 的 SSH

[English](./README.md) | [繁體中文](./README.zh-tw.md) | 简体中文

## 目录

- [🚀 用于 GitHub Actions 的 SSH](#-用于-github-actions-的-ssh)
  - [目录](#目录)
  - [📖 简介](#-简介)
  - [🧩 核心概念与输入参数](#-核心概念与输入参数)
    - [🔌 连接设置](#-连接设置)
    - [🛠️ 指令设置](#️-指令设置)
    - [🌐 代理设置](#-代理设置)
  - [⚡ 快速开始](#-快速开始)
  - [🔑 SSH 密钥配置与 OpenSSH 兼容性](#-ssh-密钥配置与-openssh-兼容性)
    - [配置 SSH 密钥](#配置-ssh-密钥)
      - [生成 RSA 密钥](#生成-rsa-密钥)
      - [生成 ED25519 密钥](#生成-ed25519-密钥)
    - [OpenSSH 兼容性](#openssh-兼容性)
  - [🛠️ 用法场景与进阶示例](#️-用法场景与进阶示例)
    - [使用密码认证](#使用密码认证)
    - [使用私钥认证](#使用私钥认证)
    - [多条命令](#多条命令)
    - [从文件执行命令](#从文件执行命令)
    - [多主机](#多主机)
    - [多主机不同端口](#多主机不同端口)
    - [多主机同步执行](#多主机同步执行)
    - [传递环境变量到 shell 脚本](#传递环境变量到-shell-脚本)
  - [🌐 代理与跳板机用法](#-代理与跳板机用法)
  - [🛡️ 安全最佳实践](#️-安全最佳实践)
    - [保护你的私钥](#保护你的私钥)
    - [主机指纹验证](#主机指纹验证)
  - [🚨 错误处理与疑难解答](#-错误处理与疑难解答)
    - [常见问题](#常见问题)
      - [命令未找到（npm 或其他命令）](#命令未找到npm-或其他命令)
  - [🤝 贡献](#-贡献)
  - [📝 许可证](#-许可证)

---

## 📖 简介

**SSH for GitHub Actions** 是一个强大的 [GitHub Action](https://github.com/features/actions)，可让你在 CI/CD 工作流中轻松且安全地执行远程 SSH 命令。  
本项目基于 [Golang](https://go.dev) 和 [drone-ssh](https://github.com/appleboy/drone-ssh) 构建，支持多主机、代理、高级认证等多种 SSH 场景。

![ssh workflow](./images/ssh-workflow.png)

[![testing main branch](https://github.com/appleboy/ssh-action/actions/workflows/main.yml/badge.svg)](https://github.com/appleboy/ssh-action/actions/workflows/main.yml)

---

## 🧩 核心概念与输入参数

本 Action 提供灵活的 SSH 命令执行能力，并具备丰富的配置选项。

详细参数请参阅 [action.yml](./action.yml)。

### 🔌 连接设置

这些参数用于控制如何连接到远程主机。

| 参数                | 描述                                          | 默认值 |
| ------------------- | --------------------------------------------- | ------ |
| host                | SSH 主机地址                                  |        |
| port                | SSH 端口号                                    | 22     |
| username            | SSH 用户名                                    |        |
| password            | SSH 密码                                      |        |
| protocol            | SSH 协议版本（`tcp`、`tcp4`、`tcp6`）         | tcp    |
| sync                | 指定多个主机时同步执行                        | false  |
| timeout             | SSH 连接主机的超时时间                        | 30s    |
| key                 | SSH 私钥内容（如 `~/.ssh/id_rsa` 的原始内容） |        |
| key_path            | SSH 私钥路径                                  |        |
| passphrase          | SSH 私钥密码短语                              |        |
| fingerprint         | 主机公钥的 SHA256 指纹                        |        |
| use_insecure_cipher | 允许额外（不安全）的加密算法                  | false  |
| cipher              | 允许的加密算法，未指定时使用默认值            |        |

---

### 🛠️ 指令设置

这些参数用于控制在远程主机上执行的命令及相关行为。

| 参数            | 描述                                                  | 默认值 |
| --------------- | ----------------------------------------------------- | ------ |
| script          | 远程执行的命令                                        |        |
| script_path     | 仓库中包含要远程执行命令的文件路径                    |        |
| envs            | 传递给 shell 脚本的环境变量                           |        |
| envs_format     | 环境变量传递的灵活配置                                |        |
| allenvs         | 传递所有带 `GITHUB_` 和 `INPUT_` 前缀的环境变量到脚本 | false  |
| command_timeout | SSH 命令执行超时时间                                  | 10m    |
| debug           | 启用调试模式                                          | false  |
| request_pty     | 向服务器请求伪终端                                    | false  |
| curl_insecure   | 允许 curl 连接无证书的 SSL 站点                       | false  |
| version         | drone-ssh 二进制版本，未指定时使用最新版本            |        |

---

### 🌐 代理设置

这些参数用于通过代理（跳板机）连接到目标主机。

| 参数                      | 描述                                      | 默认值 |
| ------------------------- | ----------------------------------------- | ------ |
| proxy_host                | SSH 代理主机                              |        |
| proxy_port                | SSH 代理端口                              | 22     |
| proxy_username            | SSH 代理用户名                            |        |
| proxy_password            | SSH 代理密码                              |        |
| proxy_passphrase          | SSH 代理私钥密码短语                      |        |
| proxy_protocol            | SSH 代理协议版本（`tcp`、`tcp4`、`tcp6`） | tcp    |
| proxy_timeout             | SSH 连接代理主机的超时时间                | 30s    |
| proxy_key                 | SSH 代理私钥内容                          |        |
| proxy_key_path            | SSH 代理私钥路径                          |        |
| proxy_fingerprint         | 代理主机公钥的 SHA256 指纹                |        |
| proxy_cipher              | 代理允许的加密算法                        |        |
| proxy_use_insecure_cipher | 代理允许额外（不安全）的加密算法          | false  |

> **注意：** 如需实现已移除的 `script_stop` 功能，请在 shell 脚本顶部添加 `set -e`。

---

## ⚡ 快速开始

只需简单配置，即可在工作流中执行远程 SSH 命令：

```yaml
name: Remote SSH Command
on: [push]
jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: 执行远程 SSH 命令（密码认证）
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.HOST }}
          username: linuxserver.io
          password: ${{ secrets.PASSWORD }}
          port: ${{ secrets.PORT }}
          script: whoami
```

**输出：**

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

## 🔑 SSH 密钥配置与 OpenSSH 兼容性

### 配置 SSH 密钥

建议在本地机器（而非远程服务器）上创建 SSH 密钥。请使用 GitHub Secrets 中指定的用户名登录并生成密钥对：

#### 生成 RSA 密钥

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

#### 生成 ED25519 密钥

```bash
ssh-keygen -t ed25519 -a 200 -C "your_email@example.com"
```

将新生成的公钥添加到服务器的 authorized_keys。 [了解更多 authorized_keys](https://www.ssh.com/ssh/authorized_keys/)

```bash
# 添加 RSA 公钥
cat .ssh/id_rsa.pub | ssh user@host 'cat >> .ssh/authorized_keys'

# 添加 ED25519 公钥
cat .ssh/id_ed25519.pub | ssh user@host 'cat >> .ssh/authorized_keys'
```

复制私钥内容并粘贴到 GitHub Secrets。

```bash
# macOS
pbcopy < ~/.ssh/id_rsa
# Ubuntu
xclip < ~/.ssh/id_rsa
```

> **提示：** 复制内容需包含 `-----BEGIN OPENSSH PRIVATE KEY-----` 到 `-----END OPENSSH PRIVATE KEY-----`（含）。

ED25519 同理：

```bash
# macOS
pbcopy < ~/.ssh/id_ed25519
# Ubuntu
xclip < ~/.ssh/id_ed25519
```

更多信息：[SSH 无密码登录](http://www.linuxproblem.org/art_9.html)。

> **注意：** 根据 SSH 版本，可能还需：
>
> - 将公钥放入 `.ssh/authorized_keys2`
> - 设置 `.ssh` 权限为 700
> - 设置 `.ssh/authorized_keys2` 权限为 640

### OpenSSH 兼容性

如果出现如下错误：

```bash
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey]
```

在 Ubuntu 20.04+，你可能需要显式允许 `ssh-rsa` 算法。请在 OpenSSH 配置文件（`/etc/ssh/sshd_config` 或 `/etc/ssh/sshd_config.d/` 下的 drop-in 文件）中添加：

```bash
CASignatureAlgorithms +ssh-rsa
```

或者，直接使用默认支持的 ED25519 密钥：

```bash
ssh-keygen -t ed25519 -a 200 -C "your_email@example.com"
```

---

## 🛠️ 用法场景与进阶示例

本节涵盖常见与进阶用法，包括多主机、代理、环境变量传递等。

### 使用密码认证

```yaml
- name: 执行远程 SSH 命令（密码认证）
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    password: ${{ secrets.PASSWORD }}
    port: ${{ secrets.PORT }}
    script: whoami
```

### 使用私钥认证

```yaml
- name: 执行远程 SSH 命令（密钥认证）
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    script: whoami
```

### 多条命令

```yaml
- name: 多条命令
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

### 从文件执行命令

```yaml
- name: 文件命令
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    script_path: scripts/script.sh
```

### 多主机

```diff
  - name: 多主机
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

默认 `port` 为 `22`。

### 多主机不同端口

```diff
  - name: 多主机
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

### 多主机同步执行

```diff
  - name: 多主机
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

### 传递环境变量到 shell 脚本

```diff
  - name: 传递环境变量
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

> _`env` 对象中的所有环境变量必须为字符串。传递整数或其他类型可能导致意外结果。_

---

## 🌐 代理与跳板机用法

你可以通过代理（跳板机）连接到远程主机，适用于进阶网络拓扑。

```bash
+--------+       +----------+      +-----------+
| Laptop | <-->  | Jumphost | <--> | FooServer |
+--------+       +----------+      +-----------+
```

示例 `~/.ssh/config`：

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
  - name: SSH 代理命令
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

## 🛡️ 安全最佳实践

### 保护你的私钥

密码短语会加密你的私钥，即使泄露也无法被攻击者直接利用。请务必妥善保管私钥。

```diff
  - name: SSH 密钥密码短语
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

### 主机指纹验证

验证 SSH 主机指纹有助于防止中间人攻击。获取主机指纹（将 `ed25519` 替换为你的密钥类型，`example.com` 替换为你的主机）：

```sh
ssh example.com ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub | cut -d ' ' -f2
```

更新配置：

```diff
  - name: SSH 密钥密码短语
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

## 🚨 错误处理与疑难解答

### 常见问题

#### 命令未找到（npm 或其他命令）

如果遇到 "command not found" 错误，请参考 [此评论](https://github.com/appleboy/ssh-action/issues/31#issuecomment-1006565847) 了解交互式与非交互式 shell 的区别。

许多 Linux 发行版的 `/etc/bash.bashrc` 包含如下内容：

```sh
# If not running interactively, don't do anything
[ -z "$PS1" ] && return
```

注释掉该行或使用命令的绝对路径。

---

## 🤝 贡献

欢迎贡献！请提交 Pull Request 改进 `appleboy/ssh-action`。

---

## 📝 许可证

本项目采用 [MIT License](LICENSE) 授权。
