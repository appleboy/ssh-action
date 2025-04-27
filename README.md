# 🚀 SSH for GitHub Actions

English | [繁體中文](./README.zh-tw.md) | [简体中文](./README.zh-cn.md)

## Table of Contents

- [🚀 SSH for GitHub Actions](#-ssh-for-github-actions)
  - [Table of Contents](#table-of-contents)
  - [📥 Input Parameters](#-input-parameters)
  - [🚦 Usage Example](#-usage-example)
  - [🔑 Setting Up SSH Keys](#-setting-up-ssh-keys)
    - [Generate RSA key](#generate-rsa-key)
    - [Generate ED25519 key](#generate-ed25519-key)
  - [🛡️ OpenSSH Compatibility](#️-openssh-compatibility)
  - [🧑‍💻 More Usage Examples](#-more-usage-examples)
    - [Using password authentication](#using-password-authentication)
    - [Using private key authentication](#using-private-key-authentication)
    - [Multiple commands](#multiple-commands)
    - [Run commands from a file](#run-commands-from-a-file)
    - [Multiple hosts](#multiple-hosts)
    - [Multiple hosts with different ports](#multiple-hosts-with-different-ports)
    - [Synchronous execution on multiple hosts](#synchronous-execution-on-multiple-hosts)
    - [Pass environment variables to shell script](#pass-environment-variables-to-shell-script)
  - [🌐 Using ProxyCommand (Jump Host)](#-using-proxycommand-jump-host)
  - [🔒 Protecting Your Private Key](#-protecting-your-private-key)
  - [🖐️ Host Fingerprint Verification](#️-host-fingerprint-verification)
  - [❓ Q\&A](#-qa)
    - [Command not found (npm or other command)](#command-not-found-npm-or-other-command)
  - [🤝 Contributing](#-contributing)
  - [📝 License](#-license)

A [GitHub Action](https://github.com/features/actions) for executing remote SSH commands easily and securely.

![ssh workflow](./images/ssh-workflow.png)

[![testing main branch](https://github.com/appleboy/ssh-action/actions/workflows/main.yml/badge.svg)](https://github.com/appleboy/ssh-action/actions/workflows/main.yml)

This project is built with [Golang](https://go.dev) and [drone-ssh](https://github.com/appleboy/drone-ssh).

---

## 📥 Input Parameters

For full details, see [action.yml](./action.yml).

| Parameter                 | Description                                                                       | Default |
| ------------------------- | --------------------------------------------------------------------------------- | ------- |
| host                      | SSH host address                                                                  |         |
| port                      | SSH port number                                                                   | 22      |
| passphrase                | Passphrase for the SSH private key                                                |         |
| username                  | SSH username                                                                      |         |
| password                  | SSH password                                                                      |         |
| protocol                  | SSH protocol version (`tcp`, `tcp4`, `tcp6`)                                      | tcp     |
| sync                      | Run synchronously if multiple hosts are specified                                 | false   |
| use_insecure_cipher       | Allow additional (less secure) ciphers                                            | false   |
| cipher                    | Allowed cipher algorithms. Uses sensible defaults if unspecified                  |         |
| timeout                   | Timeout for SSH connection to host                                                | 30s     |
| command_timeout           | Timeout for SSH command execution                                                 | 10m     |
| key                       | Content of SSH private key (e.g., raw content of `~/.ssh/id_rsa`)                 |         |
| key_path                  | Path to SSH private key                                                           |         |
| fingerprint               | SHA256 fingerprint of the host public key                                         |         |
| proxy_host                | SSH proxy host                                                                    |         |
| proxy_port                | SSH proxy port                                                                    | 22      |
| proxy_protocol            | SSH proxy protocol version (`tcp`, `tcp4`, `tcp6`)                                | tcp     |
| proxy_username            | SSH proxy username                                                                |         |
| proxy_password            | SSH proxy password                                                                |         |
| proxy_passphrase          | SSH proxy key passphrase                                                          |         |
| proxy_timeout             | Timeout for SSH connection to proxy host                                          | 30s     |
| proxy_key                 | Content of SSH proxy private key                                                  |         |
| proxy_key_path            | Path to SSH proxy private key                                                     |         |
| proxy_fingerprint         | SHA256 fingerprint of the proxy host public key                                   |         |
| proxy_cipher              | Allowed cipher algorithms for the proxy                                           |         |
| proxy_use_insecure_cipher | Allow additional (less secure) ciphers for the proxy                              | false   |
| script                    | Commands to execute remotely                                                      |         |
| script_path               | Path to a file containing commands to execute                                     |         |
| envs                      | Environment variables to pass to the shell script                                 |         |
| envs_format               | Flexible configuration for environment variable transfer                          |         |
| debug                     | Enable debug mode                                                                 | false   |
| allenvs                   | Pass all environment variables with `GITHUB_` and `INPUT_` prefixes to the script | false   |
| request_pty               | Request a pseudo-terminal from the server                                         | false   |
| curl_insecure             | Allow curl to connect to SSL sites without certificates                           | false   |
| version                   | drone-ssh binary version. If not specified, the latest version will be used.      |         |

> **Note:** To mimic the removed `script_stop` option, add `set -e` at the top of your shell script.

---

## 🚦 Usage Example

Run remote SSH commands in your workflow:

```yaml
name: Remote SSH Command
on: [push]
jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: Execute remote SSH commands using password
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.HOST }}
          username: linuxserver.io
          password: ${{ secrets.PASSWORD }}
          port: ${{ secrets.PORT }}
          script: whoami
```

**Output:**

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

## 🔑 Setting Up SSH Keys

It is best practice to create SSH keys on your local machine (not on a remote server). Log in with the username specified in GitHub Secrets and generate a key pair:

### Generate RSA key

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### Generate ED25519 key

```bash
ssh-keygen -t ed25519 -a 200 -C "your_email@example.com"
```

Add the new public key to the authorized keys on your server. [Learn more about authorized keys.](https://www.ssh.com/ssh/authorized_keys/)

```bash
# Add RSA key
cat .ssh/id_rsa.pub | ssh user@host 'cat >> .ssh/authorized_keys'

# Add ED25519 key
cat .ssh/id_ed25519.pub | ssh user@host 'cat >> .ssh/authorized_keys'
```

Copy the private key content and paste it into GitHub Secrets.

```bash
# macOS
pbcopy < ~/.ssh/id_rsa
# Ubuntu
xclip < ~/.ssh/id_rsa
```

> **Tip:** Copy from `-----BEGIN OPENSSH PRIVATE KEY-----` to `-----END OPENSSH PRIVATE KEY-----` (inclusive).

For ED25519:

```bash
# macOS
pbcopy < ~/.ssh/id_ed25519
# Ubuntu
xclip < ~/.ssh/id_ed25519
```

See more: [SSH login without a password](http://www.linuxproblem.org/art_9.html).

> **Note:** Depending on your SSH version, you may also need to:
>
> - Place the public key in `.ssh/authorized_keys2`
> - Set `.ssh` permissions to 700
> - Set `.ssh/authorized_keys2` permissions to 640

---

## 🛡️ OpenSSH Compatibility

If you see this error:

```bash
ssh: handshake failed: ssh: unable to authenticate, attempted methods [none publickey]
```

On Ubuntu 20.04+ you may need to explicitly allow the `ssh-rsa` algorithm. Add this to your OpenSSH daemon config (`/etc/ssh/sshd_config` or a drop-in under `/etc/ssh/sshd_config.d/`):

```bash
CASignatureAlgorithms +ssh-rsa
```

Alternatively, use ED25519 keys (supported by default):

```bash
ssh-keygen -t ed25519 -a 200 -C "your_email@example.com"
```

---

## 🧑‍💻 More Usage Examples

### Using password authentication

```yaml
- name: Execute remote SSH commands using password
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    password: ${{ secrets.PASSWORD }}
    port: ${{ secrets.PORT }}
    script: whoami
```

### Using private key authentication

```yaml
- name: Execute remote SSH commands using SSH key
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    script: whoami
```

### Multiple commands

```yaml
- name: Multiple commands
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

### Run commands from a file

```yaml
- name: File commands
  uses: appleboy/ssh-action@v1
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    script_path: scripts/script.sh
```

### Multiple hosts

```diff
  - name: Multiple hosts
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

Default `port` is `22`.

### Multiple hosts with different ports

```diff
  - name: Multiple hosts
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

### Synchronous execution on multiple hosts

```diff
  - name: Multiple hosts
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

### Pass environment variables to shell script

```diff
  - name: Pass environment
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

> _All environment variables in the `env` object must be strings. Using integers or other types may cause unexpected results._

---

## 🌐 Using ProxyCommand (Jump Host)

```bash
+--------+       +----------+      +-----------+
| Laptop | <-->  | Jumphost | <--> | FooServer |
+--------+       +----------+      +-----------+
```

Example `~/.ssh/config`:

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
  - name: SSH proxy command
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

## 🔒 Protecting Your Private Key

A passphrase encrypts your private key, making it useless to attackers if leaked. Always store your private key securely.

```diff
  - name: SSH key passphrase
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

## 🖐️ Host Fingerprint Verification

Verifying the SSH host fingerprint helps prevent man-in-the-middle attacks. To get your host's fingerprint (replace `ed25519` with your key type and `example.com` with your host):

```sh
ssh example.com ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub | cut -d ' ' -f2
```

Update your config:

```diff
  - name: SSH key passphrase
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

## ❓ Q&A

### Command not found (npm or other command)

If you encounter "command not found" errors, see [this issue comment](https://github.com/appleboy/ssh-action/issues/31#issuecomment-1006565847) about interactive vs non-interactive shells.

On many Linux distros, `/etc/bash.bashrc` contains:

```sh
# If not running interactively, don't do anything
[ -z "$PS1" ] && return
```

Comment out this line or use absolute paths for your commands.

---

## 🤝 Contributing

Contributions are welcome! Please submit a pull request to help improve `appleboy/ssh-action`.

---

## 📝 License

This project is licensed under the [MIT License](LICENSE).
