FROM codefriar/serverless-drone-base:latest as build 

WORKDIR /app

COPY entrypoint.sh /app
COPY slackWebhookTemplate.json /app

RUN apt-get update && \ 
    DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Options::=--force-confdef --yes --no-install-recommends install \
    ruby-full \
    libxml2-dev \
    libmysqlclient-dev \
    libncurses-dev \ 
    libpq-dev \
    libsqlite3-dev \
    memcached \
    redis \
    nodejs \
    yarnpkg && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x /app/entrypoint.sh

CMD /app/entrypoint.sh