#!/bin/bash

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 625483889928.dkr.ecr.us-east-1.amazonaws.com
#docker buildx build --platform linux/amd64 -t codefriar/serverless-drone-base . --push -f ServerlessDroneBase.Dockerfile
docker buildx build --platform linux/amd64 -t serverless-ruby . --load -f ruby.Dockerfile
docker tag serverless-ruby:latest 625483889928.dkr.ecr.us-east-1.amazonaws.com/serverless-ruby:latest
docker push 625483889928.dkr.ecr.us-east-1.amazonaws.com/serverless-ruby:latest