FROM ghcr.io/appleboy/drone-ssh:1.6.14

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
