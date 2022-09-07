#!/bin/bash

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 625483889928.dkr.ecr.us-east-1.amazonaws.com
docker buildx build --platform linux/amd64 -t serverless . --load
docker tag serverless:latest 625483889928.dkr.ecr.us-east-1.amazonaws.com/serverless:latest
docker push 625483889928.dkr.ecr.us-east-1.amazonaws.com/serverless:latest