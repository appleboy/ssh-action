FROM ghcr.io/appleboy/drone-ssh:1.7.2

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
