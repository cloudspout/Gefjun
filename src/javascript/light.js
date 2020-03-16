const AWS = require('aws-sdk')

AWS.config.region = process.env.AWS_REGION

const iotdata = new AWS.IotData({
    endpoint: process.env.MQTT_BROKER_ENDPOINT
})

exports.handler = async (event, context) => {
  console.log(event);

  const desiredState = true == event.desiredState;

  var params = {
    payload: `{"state":{"desired":{"light":${desiredState}}}}`,
    thingName: process.env.THING_NAME,
  }

  return await iotdata.updateThingShadow(params).promise()
    .then(data => {
      console.log(`update thing shadow response: ${JSON.stringify(data)}`)
//      currentState = desiredState
      return Promise.resolve({"update thing shadow response": data});
    })
    .catch(err => {
        console.log(err, err.stack)
        Promise.reject(`Failed to update thing shadow: ${err.errorMessage}`)
    });
};
