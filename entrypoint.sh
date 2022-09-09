#!/bin/bash

METADATA=$(curl -X GET ${ECS_CONTAINER_METADATA_URI_V4}/task)

echo "Cloning Repo: $GITHTTP"
cd /tmp
su test-user -c "git clone $GITHTTP checkout"
cd checkout

echo "Checking out commit: $COMMIT"
su test-user -c "git checkout $COMMIT"

echo "executing drone pipeline $PIPELINE from $PIPELINE_FILENAME"
su test-user -c "drone-runner-exec exec --pretty /tmp $PIPELINE_FILENAME --stage-name=$PIPELINE"
SUCCESS=$([ "$?" == 0 ] && echo ":thumbsup:" || echo ":thumbsdown:")

echo "Firing Slack Webhook with pipeline results"
LOGARN=$(echo $METADATA | jq '.TaskARN' | cut -d'/' -f3 | sed 's/"//')
LOGURL="https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups/log-group/\$252Fecs\$252Fserverless-drone-task/log-events/ecs\$252Fserverless-drone\$252F$LOGARN"

sed -i -r "s#SUCCESS#$SUCCESS#g" /app/slackWebhookTemplate.json
sed -i -r "s|LOGURL|$LOGURL|g" /app/slackWebhookTemplate.json
sed -i -r "s#REPO#$GITURL#g" /app/slackWebhookTemplate.json
sed -i -r "s#COMMIT#$COMMIT#g" /app/slackWebhookTemplate.json
sed -i -r "s#PFILE#$PIPELINE_FILENAME#g" /app/slackWebhookTemplate.json
sed -i -r "s#PIPELINE#$PIPELINE#g" /app/slackWebhookTemplate.json

SLACK_MSG=$(< /app/slackWebhookTemplate.json)

curl -X POST -H 'Content-type: application/json' --data "$SLACK_MSG" $SLACK_WEBHOOK || true