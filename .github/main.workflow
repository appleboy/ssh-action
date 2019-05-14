workflow "Remote ssh commands" {
  on = "push"
  resolves = [
    "Executing remote ssh commands",
    "Support Private Key",
  ]
}

action "Executing remote ssh commands" {
  uses = "appleboy/ssh-action@master"
  secrets = [
    "HOST",
    "PASSWORD",
  ]
  args = [
    "--user", "actions",
    "--script", "whoami",
  ]
}

action "Support Private Key" {
  uses = "appleboy/ssh-action@master"
  secrets = [
    "HOST",
    "KEY",
  ]
  args = [
    "--user", "actions",
    "--script", "ls -al",
  ]
}
