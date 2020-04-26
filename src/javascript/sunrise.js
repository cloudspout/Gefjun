const SunCalc = require('suncalc');
const AWS = require('aws-sdk')

const tiny = require('tiny-json-http')

AWS.config.region = process.env.AWS_REGION

const GRAFANA_API_ANNOTATION = process.env.GRAFANA_API_ANNOTATION;
const GRAFANA_API_SECRET_ID = process.env.GRAFANA_API_SECRET_ID;
const location_lat = process.env.LOCATION_LAT
const location_lng = process.env.LOCATION_LNG
const rule_on = process.env.RULE_ON
const rule_off = process.env.RULE_OFF
const duration = process.env.DURATION

exports.handler = async (event, context) => {
  console.log("Input: ", event);
  var times = SunCalc.getTimes(new Date(), location_lat, location_lng);

  const cloudwatchevents = new AWS.CloudWatchEvents();
  const secretsManager = new AWS.SecretsManager({});

  const onPromise = cloudwatchevents.describeRule({Name: rule_on}).promise()
    .then(data => {
      const onTime = times.sunriseEnd;
      console.log(onTime)

      data.ScheduleExpression = `cron(${onTime.getUTCMinutes()} ${onTime.getUTCHours()} * * ? *)`;
      data.State = 'ENABLED';
      delete data.Arn;

      const sunriseAnnoation = {
        time: onTime.getTime(),
        tags:["sunrise"],
        text:"🌄"
      };

      return Promise.all([
        secretsManager.getSecretValue({ SecretId: GRAFANA_API_SECRET_ID }).promise()
          .then(data => tiny.post({url: GRAFANA_API_ANNOTATION, data: sunriseAnnoation, headers: {Authorization: 'Bearer ' + data.SecretString}})),
        cloudwatchevents.putRule(data).promise()
      ]);
    }).then(data => {
      console.log('Updated ON cron: ', data);
      return data;
    });

  const offPromise = cloudwatchevents.describeRule({Name: rule_off}).promise()
    .then(data => {
      const offTime = times.sunsetStart;
      console.log(offTime)

      data.ScheduleExpression = `cron(${offTime.getUTCMinutes()} ${offTime.getUTCHours()} * * ? *)`;
      data.State = 'ENABLED';
      delete data.Arn;
      
      const sunsetAnnoation = {
        time: offTime.getTime(),
        tags: ["sunset"],
        text: "🌅"
      };

      return Promise.all([
        secretsManager.getSecretValue({ SecretId: GRAFANA_API_SECRET_ID }).promise()
          .then(data => tiny.post({url: GRAFANA_API_ANNOTATION, data: sunsetAnnoation, headers: {Authorization: 'Bearer ' + data.SecretString}})),
        cloudwatchevents.putRule(data).promise()
      ]);
    }).then(data => {
      console.log('Updated OFF cron: ', data);
      return data;
    });

    return await Promise.all([onPromise, offPromise])
      .catch(err => {
        console.log(err, err.stack)
        Promise.reject(`Failed to update cron: ${err.errorMessage}`)
      });
}
