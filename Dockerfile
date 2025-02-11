FROM ubuntu:24.10

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl wget jq zip unzip \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
COPY sh/*.sh /sh/
ENTRYPOINT ["/entrypoint.sh"]