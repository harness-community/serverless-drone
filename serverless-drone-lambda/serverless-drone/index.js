import { ECSClient, RunTaskCommand } from "@aws-sdk/client-ecs";
import githubHelper from "./githubHelper.js";
import payloadHelper from "./payloadHelper.js";
import fargateHelper from "./fargateHelper.js";

export const handler = async (event, context) => {
  githubHelper.validateGithubRequest(event, context);
  const client = new ECSClient();
  const fHelper = new fargateHelper();
  const parsedPayload = payloadHelper.parseEventPayload(event, context);
  const fargateParameters = await fHelper.buildFargateParameters(parsedPayload);

  try {
    console.log("Launching Fargate task");
    console.debug("Fargate Parameters: " + JSON.stringify(fargateParameters));
    const command = new RunTaskCommand(fargateParameters);
    const result = await client.send(command);
    console.debug("logs: " + JSON.stringify(result));
  } catch (error) {
    console.log("Failed to launch fargate container. Error is: " + error);
    throw "Failed to launch " + error;
  }

  context.succeed("200 OK");
};
