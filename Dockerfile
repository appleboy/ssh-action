FROM appleboy/drone-ssh:1.5.1-linux-amd64

# Github labels
LABEL "com.github.actions.name"="SSH Commands"
LABEL "com.github.actions.description"="Executing remote ssh commands"
LABEL "com.github.actions.icon"="terminal"
LABEL "com.github.actions.color"="gray-dark"

LABEL "repository"="https://github.com/appleboy/ssh-action"
LABEL "homepage"="https://github.com/appleboy"
LABEL "maintainer"="Bo-Yi Wu <appleboy.tw@gmail.com>"
LABEL "version"="0.0.2"

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
