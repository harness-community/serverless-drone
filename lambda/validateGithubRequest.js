"use strict";
const crypto = require("crypto");
const secret = process.env.GITHUB_SECRET;

module.exports.isValidGithubRequest = function (event, context) {
  let calculatedSignature =
    "sha1=" +
    crypto.createHmac("sha1", secret).update(event.body).digest("hex");
  let githubSignature = event.headers["x-hub-signature"];

  if (calculatedSignature !== githubSignature) {
    console.debug("Secret from Environment is not null: " + secret != null);
    console.debug(
      "Calculated Signature is: " +
        calculatedSignature +
        " but Github sent this signature: " +
        githubSignature
    );
    context.fail(
      "Unable to verify HMAC signature - Not a valid github webhook invocation of this function"
    );
  }
};
