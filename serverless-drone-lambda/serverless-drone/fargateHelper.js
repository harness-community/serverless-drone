import fetch from "node-fetch";
export default class fargateHelper {
  async getPrimaryLanguage(languageURL) {
    const response = await fetch(languageURL);
    const languages = await response.json();
    return Object.keys(languages)[0].toLowerCase();
  }

  /**
   * This method is where the meat of this function's logic exists. It
   * serves to identify the proper 'build pack' to use for your CI task.
   * You can modify this method to define your own logic for determining
   * the build pack. This method's current (naïve) logic is based on what *github*
   * believes the primary language of the repository is.
   *
   * @param {*} parsedPayload - a Object parsed from the Event JSON body property
   * @returns Fargate launch parameters used to launch the Fargate task.
   */
  async buildFargateParameters(parsedPayload) {
    // taskName refers to the Fargate defined Task Definition
    let taskName = "";
    /**
     * imageName refers to the docker image to be used by the Task Definition
     * Note: You can use a single Fargate task definition and use this to
     * simply override the task's image.
     *
     * You'll want to use TASK to specify different resource definitions and
     * IMAGE to define different software configurations.
     */
    let imageName = "";

    /**
     * This boolean allows you to define a flag that is passed to the entrypoint.sh file.
     * Some build systems / build packs require root access. Setting this to true will
     * let the entrypoint.sh know to execute it's tasks as root.
     */
    let executeAsRoot = false;

    // NOTE: I have only build-out two images - Ruby and C.
    // this demonstrates how you'd specify an override task or image name.
    const primaryLanguage = await this.getPrimaryLanguage(
      parsedPayload.repository.languages_url
    );
    switch (primaryLanguage) {
      case "c":
        taskName = "serverless-drone-task";
        imageName = "serverless-drone";
        break;
      case "ruby":
        taskName = "serverless-drone-ruby-task";
        imageName = "serverless-drone-ruby";
        executeAsRoot = true;
        break;
      // case "c++":
      //   break;
      // case "c#":
      //   break;
      // case "php":
      //   break;
      // case "python":
      //   break;
      // case "javascript":
      //   break;
      // case "typescript":
      //   break;
      // case "js":
      //   break;
      // case "swift":
      //   break;
      // case "java":
      //   break;
      // case "dart":
      //   break;
      // case "objective-c":
      //   break;
      // case "rust":
      //   break;
      // case "kotlin":
      //   break;
      default:
        taskName = "serverless-drone-task";
        imageName = "serverless-drone";
    }

    return {
      cluster: `${process.env.FARGATE_CLUSTER}`,
      launchType: "FARGATE",
      count: 1,
      taskDefinition: `${taskName}`,
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
            name: `${imageName}`,
            environment: [
              {
                name: "GITURL",
                value: `${parsedPayload.repository.git_url}`,
              },
              {
                name: "GITHTTP",
                value: `${parsedPayload.repository.url}`,
              },
              {
                name: "COMMIT",
                value: `${parsedPayload.after}`,
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
                name: "SLACK_WEBHOOK",
                value: `${process.env.SLACK_WEBHOOK}`,
              },
              {
                name: "EXECUTEASROOT",
                value: `${executeAsRoot}`,
              },
            ],
          },
        ],
      },
    };
  }
}
