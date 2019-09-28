workflow "Remote ssh commands" {
  resolves = [
    "Executing remote ssh commands",
  ]
  on = "push"
}

action "Executing remote ssh commands" {
  uses = "github"
  secrets = [
    "84.201.152.94",
    "934561",
  ]
  args = [
    "--user",
    "actions",
    "--script",
    "whoami",
  ]
}

    "--user",
    "actions",
    "--script",
    "'ls -al'",
  ]
}

action "Multiple Commands" {
  uses = "appleboy/ssh-action@master"
  secrets = [
    "HOST",
    "KEY",
  ]
  args = [
    "--user",
    "actions",
    "--script",
    "'whoami'",
    "--script",
    "'ls -al'",
  ]
}
