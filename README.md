# 🚀 SSH for GitHub Actions

[GitHub Action](https://github.com/features/actions) for executing remote ssh commands.

![ssh workflow](./images/ssh-workflow.png)

[![Actions Status](https://github.com/appleboy/ssh-action/workflows/remote%20ssh%20command/badge.svg)](https://github.com/appleboy/ssh-action/actions)

**Important**: Only support **Linux** [docker](https://www.docker.com/) container.

## Usage

Executing remote ssh commands.

```yaml
name: remote ssh command
on: [push]
jobs:

  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
    - name: executing remote ssh commands using password
      uses: appleboy/ssh-action@master
      with:
        host: ${{ secrets.HOST }}
        username: ${{ secrets.USERNAME }}
        password: ${{ secrets.PASSWORD }}
        port: ${{ secrets.PORT }}
        script: whoami
```

output:

```sh
======CMD======
whoami
======END======
out: ***
==============================================
✅ Successfully executed commands to all host.
==============================================
```

## Input variables

See [action.yml](./action.yml) for more detailed information.

* host - ssh host
* port - ssh port, default is `22`
* username - ssh username
* password - ssh password
* passphrase - the passphrase is usually to encrypt the private key
* sync - synchronous execution if multiple hosts, default is false
* timeout - timeout for ssh to remote host, default is `30s`
* command_timeout - timeout for ssh command, default is `10m`
* key - content of ssh private key. ex raw content of ~/.ssh/id_rsa
* key_path - path of ssh private key
* fingerprint - fingerprint SHA256 of the host public key, default is to skip verification
* script - execute commands
* script_stop - stop script after first failure
* envs - pass environment variable to shell script
* debug - enable debug mode
* use_insecure_cipher - include more ciphers with use_insecure_cipher (see [#56](https://github.com/appleboy/ssh-action/issues/56))
* cipher - the allowed cipher algorithms. If unspecified then a sensible

SSH Proxy Setting:

* proxy_host - proxy host
* proxy_port - proxy port, default is `22`
* proxy_username - proxy username
* proxy_password - proxy password
* proxy_passphrase - the passphrase is usually to encrypt the private key
* proxy_timeout - timeout for ssh to proxy host, default is `30s`
* proxy_key - content of ssh proxy private key.
* proxy_key_path - path of ssh proxy private key
* proxy_fingerprint - fingerprint SHA256 of the proxy host public key, default is to skip verification
* proxy_use_insecure_cipher - include more ciphers with use_insecure_cipher (see [#56](https://github.com/appleboy/ssh-action/issues/56))
* proxy_cipher - the allowed cipher algorithms. If unspecified then a sensible

### Example

Executing remote ssh commands using password.

```yaml
- name: executing remote ssh commands using password
  uses: appleboy/ssh-action@master
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    password: ${{ secrets.PASSWORD }}
    port: ${{ secrets.PORT }}
    script: whoami
```

Using private key

```yaml
- name: executing remote ssh commands using ssh key
  uses: appleboy/ssh-action@master
  with:
    host: ${{ secrets.HOST }}
    username: ${{ secrets.USERNAME }}
    key: ${{ secrets.KEY }}
    port: ${{ secrets.PORT }}
    script: whoami
```

Multiple Commands

```yaml
- name: multiple command
  uses: appleboy/ssh-action@master
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

Multiple Hosts

```diff
  - name: multiple host
    uses: appleboy/ssh-action@master
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

Synchronous execution on multiple hosts

```diff
  - name: multiple host
    uses: appleboy/ssh-action@master
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

Pass environment variable to shell script

```diff
  - name: pass environment
    uses: appleboy/ssh-action@master
+   env:
+     FOO: "BAR"
+     BAR: "FOO"
+     SHA: ${{ github.sha }}
    with:
      host: ${{ secrets.HOST }}
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      port: ${{ secrets.PORT }}
+     envs: FOO,BAR
      script: |
        echo "I am $FOO"
        echo "I am $BAR"
        echo "sha: $SHA"
```

_Inside `env` object, you need to pass every environment variable as a string, passing `Integer` data type or any other may output unexpected results._

Stop script after first failure. ex: missing `abc` folder

```diff
  - name: stop script if command error
    uses: appleboy/ssh-action@master
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

output:

```sh
======CMD======
mkdir abc/def
ls -al

======END======
2019/11/21 01:16:21 Process exited with status 1
err: mkdir: cannot create directory ‘abc/def’: No such file or directory
##[error]Docker run failed with exit code 1
```

How to connect remote server using `ProxyCommand`?

```bash
+--------+       +----------+      +-----------+
| Laptop | <-->  | Jumphost | <--> | FooServer |
+--------+       +----------+      +-----------+
```

in your `~/.ssh/config`, you will see the following.

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

How to convert to YAML format of GitHubActions.

```diff
  - name: ssh proxy command
    uses: appleboy/ssh-action@master
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

Protecting a Private Key. The purpose of the passphrase is usually to encrypt the private key. This makes the key file by itself useless to an attacker. It is not uncommon for files to leak from backups or decommissioned hardware, and hackers commonly exfiltrate files from compromised systems.

```diff
  - name: ssh key passphrase
    uses: appleboy/ssh-action@master
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
