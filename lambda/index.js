const AWS = require("aws-sdk");
const githubValidator = require("./validateGithubRequest");

exports.handler = async (event, context) => {
  const ecs = new AWS.ECS();

  githubValidator.isValidGithubRequest(event, context);

  let givenPayload = "";
  try {
    givenPayload = JSON.parse(event.body);
    console.debug("event.after: " + givenPayload.after);
    console.debug("event after hash: " + givenPayload["after"]);
    console.debug("givenPayload string: " + JSON.stringify(givenPayload));
  } catch (error) {
    console.debug(error);
    context.fail(
      "Failed to parse the body property of the Event object. Body is: " +
        event.body +
        " Error is: " +
        JSON.stringify(error) +
        " Event object is: " +
        JSON.stringify(event)
    );
  }

  const fargateParameters = {
    cluster: `${process.env.FARGATE_CLUSTER}`,
    launchType: "FARGATE",
    count: 1,
    taskDefinition: `serverless-drone-task`,
    networkConfiguration: {
      awsvpcConfiguration: {
        subnets: ["subnet-de02d4f2"],
        securityGroups: ["sg-fe712f80"],
        assignPublicIp: "ENABLED",
      },
    },
    overrides: {
      containerOverrides: [
        {
          name: "serverless-drone",
          environment: [
            {
              name: "GITURL",
              value: `${givenPayload.repository.git_url}`,
            },
            {
              name: "GITHTTP",
              value: `${givenPayload.repository.url}`,
            },
            {
              name: "COMMIT",
              value: `${givenPayload.after}`,
            },
            {
              name: "PIPELINE_FILENAME",
              value: `${process.env.PIPELINE_FILENAME}`,
            },
            {
              name: "PIPELINE",
              value: `${process.env.PIPELINE_NAME}`,
            },
            {
              name: "APT_DEPENDENCIES",
              value: `${process.env.APT_DEPENDENCIES}`,
            },
          ],
        },
      ],
    },
  };

  try {
    console.log("Launching Fargate task");
    let result = await ecs.runTask(fargateParameters).promise();
    console.debug("logs: " + JSON.stringify(result));
  } catch (error) {
    console.log("Failed to launch fargate container. Error is: " + error);
    throw "Failed to launch " + error;
    //error('Failed to launch fargate container. error is: ' + error);
  }

  context.succeed("200 OK");
};
