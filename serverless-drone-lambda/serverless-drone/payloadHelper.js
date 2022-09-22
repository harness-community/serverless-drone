
export default class payloadHelper {
  static parseEventPayload(event, context){
  let parsedPayload;
  try {
    parsedPayload = JSON.parse(event.body);
  } catch (error) {
    context.fail(
      "Failed to parse the body property of the Event object. Body is: " +
        event.body +
        " Error is: " +
        JSON.stringify(error) +
        " Event object is: " +
        JSON.stringify(event)
    );
  }
  return parsedPayload;
  }
}