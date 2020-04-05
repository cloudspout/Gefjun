from signal import signal, SIGINT
from sys import exit
import logging
import time
import json

from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTShadowClient
from Greenhouse import PhysicalEnvironment, Greenhouse

# Configure logging
logger = logging.getLogger("Gefjun,core")
logger.setLevel(logging.INFO)

logging.getLogger("AWSIoTPythonSDK.core").setLevel(logging.WARNING)
streamHandler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
streamHandler.setFormatter(formatter)
logger.addHandler(streamHandler)
    
def generateEnironmentUpdatePayload(greenhouse):
    env = greenhouse.measureEnvironment()
    envDict = {'temperature': env.temperature, 'pressure': env.pressure, 'altitude': env.altitude,
               'lux1': env.lux1, 'lux2': env.lux2,
               'lux3': env.lux3, 'lux4': env.lux4,
               'lux5': env.lux5, 'lux6': env.lux6,
               'lux7': env.lux7, 'lux8': env.lux8,
               'light': env.light}
    stateDict = {'reported': envDict}
    payloadDict = {"state": stateDict}
    JSONPayload = json.dumps(payloadDict)
    logger.debug(JSONPayload)
    return JSONPayload

# Custom Shadow callback
def customShadowCallback_Update(payload, responseStatus, token):
    # payload is a JSON string ready to be parsed using json.loads(...)
    # in both Py2.x and Py3.x
    if responseStatus == "timeout":
        logger.info('Update request %s time out!', token)
    if responseStatus == "accepted":
        payloadDict = json.loads(payload)
        logger.info('Update request with token: %s accepted!', token)
    if responseStatus == "rejected":
        logger.info('Update request %s rejected!', token)

def handleLightsUpdate(stateDict, greenhouse):
    desiredLightState = stateDict['light']
    if (desiredLightState):
        greenhouse.turnLightsOn()
    else:
        greenhouse.turnLightsOff()
    
    return desiredLightState

def customShadowCallback_Delta(greenhouse):
    def inner_delta(payload, responseStatus, token):
        logger.info('delta: %s', payload)
        if responseStatus == 'delta/sensor':
            payloadDict = json.loads(payload)
            stateDict = payloadDict['state']
            if 'light' in stateDict:
                lights = handleLightsUpdate(stateDict, greenhouse)
                    
        JSONPayload = generateEnironmentUpdatePayload(greenhouse)
        logger.info('Environment for delta: %s', JSONPayload)
        deviceShadowHandler.shadowUpdate(JSONPayload, customShadowCallback_Update, 5)
    return inner_delta
    
def customShadowCallback_Delete(payload, responseStatus, token):
    if responseStatus == "timeout":
        logger.info('Delete request %s time out!', token)
    if responseStatus == "accepted":
        logger.info("~~~~~~~~~~~~~~~~~~~~~~~")
        logger.info("Delete request with token: %s accepted!", token)
        logger.info("~~~~~~~~~~~~~~~~~~~~~~~\n\n")
    if responseStatus == "rejected":
        logger.info("Delete request %s rejected!", token)

rootCAPath = 'root-CA.crt'
certificatePath = 'sensor.pem'
privateKeyPath = 'private.key'
host = 'a3bsusgkvg1eik-ats.iot.us-east-1.amazonaws.com'
port = 8883
clientId = 'RaspberryPi'
thingName = 'sensor'

# Init AWSIoTMQTTShadowClient
myAWSIoTMQTTShadowClient = AWSIoTMQTTShadowClient(clientId)
myAWSIoTMQTTShadowClient.configureEndpoint(host, port)
myAWSIoTMQTTShadowClient.configureCredentials(rootCAPath, privateKeyPath, certificatePath)

# AWSIoTMQTTShadowClient configuration
myAWSIoTMQTTShadowClient.configureAutoReconnectBackoffTime(1, 32, 20)
myAWSIoTMQTTShadowClient.configureConnectDisconnectTimeout(10)  # 10 sec
myAWSIoTMQTTShadowClient.configureMQTTOperationTimeout(5)  # 5 sec

# Connect to AWS IoT
myAWSIoTMQTTShadowClient.connect()

# Create a deviceShadow with persistent subscription
deviceShadowHandler = myAWSIoTMQTTShadowClient.createShadowHandlerWithName(thingName, True)

def main():
# Update shadow in a loop
    with Greenhouse() as greenhouse:
        
        # Delete shadow JSON doc
        #deviceShadowHandler.shadowDelete(customShadowCallback_Delete, 5)

        deviceShadowHandler.shadowRegisterDeltaCallback(customShadowCallback_Delta(greenhouse))

        while True:
            try:
                JSONPayload = generateEnironmentUpdatePayload(greenhouse)
                logger.info('Environment state for update: %s', JSONPayload)

                deviceShadowHandler.shadowUpdate(JSONPayload, customShadowCallback_Update, 5)
            except publishQueueDisabledException:
                logger.warning('Device offline - Retrying: %s', e)
                
            time.sleep(15)

if __name__ == '__main__':
    def handler(signal_received, frame):
        # Handle any cleanup here
        logger.error('SIGINT or CTRL-C detected. Exiting gracefully')
        exit(0)
    # Tell Python to run the handler() function when SIGINT is recieved
    signal(SIGINT, handler)

    main()
