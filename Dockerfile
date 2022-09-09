FROM codefriar/serverless-drone-base:latest as build 

WORKDIR /app

COPY entrypoint.sh /app
COPY slackWebhookTemplate.json /app

RUN chmod +x /app/entrypoint.sh

CMD /app/entrypoint.sh