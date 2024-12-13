# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

LABEL maintainer="seu-email@exemplo.com"

RUN apt-get update && \
    apt-get install -y curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /home/container

ENTRYPOINT ["/entrypoint.sh"]
