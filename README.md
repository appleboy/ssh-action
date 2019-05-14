# 🚀 SSH for GitHub Actions

[GitHub Action](https://developer.github.com/actions/) for executing remote ssh commands.

## Usage

copy files and artifacts via SSH as blow.

```
action "Copy multiple file" {
  uses = "appleboy/scp-action@master"
  env = {
    HOST = "example.com"
    USERNAME = "foo"
    PASSWORD = "bar"
    PORT = "22"
    SOURCE = "tests/a.txt,tests/b.txt"
    TARGET = "/home/foo/test"
  }
  secrets = [
    "PASSWORD",
  ]
}
```

## Environment variables

* HOST - ssh server host
* PORT - ssh server port
* USERNAME - ssh server username
* PASSWORD - ssh server password
* KEY - ssh server private key
* SCRIPT - execute the scripts
