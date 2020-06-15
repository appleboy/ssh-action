FROM appleboy/drone-ssh:1.6.1-linux-amd64

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
