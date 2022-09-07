#!/bin/bash

echo "Installing required apt packages..."
apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Options::=--force-confdef install $APT_DEPENDENCIES --yes

echo "Cloning Repo: $GITHTTP"
cd /tmp
su test-user -c "git clone $GITHTTP checkout"
cd checkout

echo "Checking out commit: $COMMIT"
su test-user -c "git checkout $COMMIT"

echo "executing drone pipeline $PIPELINE from $PIPELINE_FILENAME"
ls -lah 
touch .test
su test-user -c "drone-runner-exec exec --pretty /tmp $PIPELINE_FILENAME --stage-name=$PIPELINE"