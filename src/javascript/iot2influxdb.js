const Influx = require('influx');

//This code writes data from IoT core rule via Lambda into InfluxDB 

exports.handler = async (event, context, callback) => {

    console.log("Event: ", event);
    const reported = event.reported;

    /*
    reported: {
    temperature: 21.1,
    pressure: 100941,
    altitude: 32.68705129847641,
    lux1: 469,
    lux2: 298,
    light: false
  }
  */
    var result = await writeToInfluxDB(
        reported.temperature, 
        reported.pressure,
        reported.lux1, 
        reported.lux2,
        reported.lux3,
        reported.lux4,
        reported.lux5,
        reported.lux6,
        reported.lux7,
        reported.lux8,
        reported.light);

    console.log("Finished executing", result);

    return callback(null, result);
  };

function writeToInfluxDB(temperature, pressure, lux1, lux2, lux3, lux4, lux5, lux6, lux7, lux8, light_state)
{
    console.log("Executing Influx insert");

    const client = new Influx.InfluxDB({
        database: process.env.INFLUXDB,
        username: process.env.INFLUXDBUSRNAME,
        password: process.env.INFLUXDBPWD,
        port: process.env.INFLUXDBPORT,
        hosts: [{ host: process.env.INFLUXDBHOST }],
        schema: [{
            measurement: 'temperature',
    
            fields: {
                celsius: Influx.FieldType.FLOAT
            },
    
            tags: []
        },
        {
            measurement: 'pressure',
    
            fields: {
                pascal: Influx.FieldType.FLOAT
            },

            tags: []
        },
        {
            measurement: 'lights',
    
            fields: {
                lux: Influx.FieldType.INTEGER
            },
    
            tags: ['sensor']
        },
        {
            measurement: 'light',
    
            fields: {
                state: Influx.FieldType.INTEGER
            },
    
            tags: []
        }
    ]
    });
    
    const resultPromise = client.writePoints([
        {
            measurement: 'temperature', fields: { celsius: temperature }
        },
        {
            measurement: 'pressure', fields: { pascal: pressure }
        },
        {
            measurement: 'lights', fields: { lux: lux1 },
            tags: { sensor: "sensor1"}
        },
        {
            measurement: 'lights', fields: { lux: lux2 },
            tags: { sensor: "sensor2"}
        },
        {
            measurement: 'lights', fields: { lux: lux3 },
            tags: { sensor: "sensor3"}
        },
        {
            measurement: 'lights', fields: { lux: lux4 },
            tags: { sensor: "sensor4"}
        },
        {
            measurement: 'lights', fields: { lux: lux5 },
            tags: { sensor: "sensor5"}
        },
        {
            measurement: 'lights', fields: { lux: lux6 },
            tags: { sensor: "sensor6"}
        },
        {
            measurement: 'lights', fields: { lux: lux7 },
            tags: { sensor: "sensor7"}
        },
        {
            measurement: 'lights', fields: { lux: lux8 },
            tags: { sensor: "sensor8"}
        },
        {
            measurement: 'light', fields: { state: light_state === true ? 1 : 0}
        }
    ]) 

    return resultPromise;
}    