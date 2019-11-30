# 🚀 SSH for GitHub Actions

[GitHub Action](https://github.com/features/actions) for executing remote ssh commands.

![ssh workflow](./images/ssh-workflow.png)

[![Actions Status](https://github.com/appleboy/ssh-action/workflows/remote%20ssh%20command/badge.svg)](https://github.com/appleboy/ssh-action/actions)

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

* host - remote host
* port - remote port, default is `22`
* username - ssh username
* password - ssh password
* timeout - timeout for ssh to remote host, default is `30s`
* command_timeout - timeout for ssh command, default is `10m`
* key - content of ssh private key. ex raw content of ~/.ssh/id_rsa
* key_path - path of ssh private key
* script - execute commands
* script_stop - stop script after first failure
* envs - pass environment variable to shell script
* debug - enable debug mode

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

Pass environment variable to shell script

```diff
  - name: pass environment
    uses: appleboy/ssh-action@master
+   env:
+     FOO: "BAR"
    with:
      host: ${{ secrets.HOST }}
      username: ${{ secrets.USERNAME }}
      key: ${{ secrets.KEY }}
      port: ${{ secrets.PORT }}
+     envs: FOO
      script: |
        echo "I am $FOO"
        echo "I am $BAR"
```

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
