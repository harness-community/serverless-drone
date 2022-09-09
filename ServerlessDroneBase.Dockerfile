# You can build a serverless drone image from basically any image, but I recommend
# not using an Alpine image because it's use of libMUSL can cause compatability issues
# this one is basedo n Ubuntu
FROM ubuntu:jammy as build 

# There are a few required things that all serverless-drone images will need.
# this installs them, and cleans up the apt cache afterwards
RUN apt-get update && \ 
    DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Options::=--force-confdef --yes --no-install-recommends install \
    curl \
    build-essential \
    make \
    tcl-dev \
    zlib1g-dev \
    jq \
    git \
    gcc \
    g++ \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# create a test user in case your unit tests require a non-root user.
RUN adduser --disabled-login test-user -q    

# Install the drone-runner-exec binary
RUN curl -L https://github.com/drone-runners/drone-runner-exec/releases/latest/download/drone_runner_exec_linux_amd64.tar.gz | tar zx
RUN install -t /usr/local/bin drone-runner-exec