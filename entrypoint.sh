#!/bin/bash

METADATA=$(curl --no-progress-meter -X GET ${ECS_CONTAINER_METADATA_URI_V4}/task)
AWSGROUP=$(echo $METADATA | jq '.Containers[0].LogOptions["awslogs-group"]' | sed 's#\/#\$252F#g' | sed 's/"//g')
AWSREGION=$(echo $METADATA | jq '.Containers[0].LogOptions["awslogs-region"]' | sed 's/"//g')
AWSSTREAM=$(echo $METADATA | jq '.Containers[0].LogOptions["awslogs-stream"]' | sed 's/\$/\$252F/' | sed 's#\[#\$255B#' | sed 's/\]/\$255D/' | sed 's/\//\$252F/g' | sed 's/"//g')

echo "--------------------------------"
echo "Cloning Repo: $GITHTTP"
cd /tmp

echo "Execute as root? $EXECUTEASROOT"

if [ $EXECUTEASROOT = true ]; then
    git clone $GITHTTP checkout
else
    su test-user -c "git clone $GITHTTP checkout"
fi
cd checkout

echo "Checking out commit: $COMMIT"
if [ $EXECUTEASROOT = true ]; then
    git checkout $COMMIT
else
    su test-user -c "git checkout $COMMIT"
fi

echo "executing drone pipeline $PIPELINE from $PIPELINE_FILENAME"
if [ $EXECUTEASROOT = true ]; then
    drone-runner-exec exec --pretty /tmp $PIPELINE_FILENAME --stage-name=$PIPELINE
else
    su test-user -c "drone-runner-exec exec --pretty /tmp $PIPELINE_FILENAME --stage-name=$PIPELINE"
fi

SUCCESS=$([ "$?" == 0 ] && echo ":thumbsup:" || echo ":thumbsdown:")

echo "Firing Slack Webhook with pipeline results"
LOGURL="https://$AWSREGION.console.aws.amazon.com/cloudwatch/home?region=$AWSREGION#logsV2:log-groups/log-group/$AWSGROUP/log-events/$AWSSTREAM"

sed -i -r "s#SUCCESS#$SUCCESS#g" /app/slackWebhookTemplate.json
sed -i -r "s|LOGURL|$LOGURL|g" /app/slackWebhookTemplate.json
sed -i -r "s#REPO#$GITURL#g" /app/slackWebhookTemplate.json
sed -i -r "s#COMMIT#$COMMIT#g" /app/slackWebhookTemplate.json
sed -i -r "s#PFILE#$PIPELINE_FILENAME#g" /app/slackWebhookTemplate.json
sed -i -r "s#PIPELINE#$PIPELINE#g" /app/slackWebhookTemplate.json

SLACK_MSG=$(< /app/slackWebhookTemplate.json)

curl --no-progress-meter -X POST -H 'Content-type: application/json' --data "$SLACK_MSG" $SLACK_WEBHOOK || true