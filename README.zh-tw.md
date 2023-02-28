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
