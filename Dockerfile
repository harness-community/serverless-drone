FROM ubuntu:jammy as build 

WORKDIR /app

COPY entrypoint.sh /app

RUN chmod +x /app/entrypoint.sh
RUN adduser --disabled-login test-user -q
RUN apt-get update && \ 
    apt-get install curl build-essential make git gcc g++ ca-certificates --yes --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/drone-runners/drone-runner-exec/releases/latest/download/drone_runner_exec_linux_amd64.tar.gz | tar zx
RUN install -t /usr/local/bin drone-runner-exec
    
CMD /app/entrypoint.sh