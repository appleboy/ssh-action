---
name: Bug report
about: Create a report to help us improve
title: ""
labels: bug
assignees: appleboy
---

## Describe the bug

A clear and concise description of what the bug is. If applicable, add screenshots to help explain your problem.

## Yaml Config

Please post your Yaml configuration file along with the output results.

```yaml
name: remote ssh command
on: [push]
jobs:
  build:
    name: Build
    runs-on: ubuntu-latest
    steps:
      - name: executing remote ssh commands using password
        uses: appleboy/ssh-action@v1.2.2
        with:
          host: ${{ secrets.HOST }}
          username: ${{ secrets.USERNAME }}
          password: ${{ secrets.PASSWORD }}
          port: ${{ secrets.PORT }}
          script: whoami
```

## Related environment

Please provide the following information:

1. Your hosting provider information, such as DigitalOcean, Linode, AWS, or GCP.
2. The version information of your host's SSH service.
3. The information from your host's SSH configuration file.
