from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTShadowClient
from AWSIoTPythonSDK.MQTTLib import AWSIoTMQTTClient
import logging
import time
import json
import argparse
from dataclasses import dataclass


import RPi.GPIO as GPIO
CHANNEL1=17
CHANNEL2=18
GPIO.setmode(GPIO.BCM)
GPIO.setup(CHANNEL1, GPIO.OUT)
lights=False
GPIO.setup(CHANNEL2, GPIO.OUT)
from mcp3208 import MCP3208
adc = MCP3208()
import Adafruit_BMP.BMP085 as BMP085
sensor2 = BMP085.BMP085(mode=BMP085.BMP085_ULTRAHIGHRES)

def meassureLight():
    return lights

@dataclass
class PhysicalEnvironment:
    pressure: float
    altitude: float
    temperature: float
    light1: int
    light2: int

def measureEnvironment():
    env = PhysicalEnvironment(sensor2.read_pressure(), sensor2.read_altitude(), sensor2.read_temperature(),
                              adc.read(0), adc.read(1))
    print(env)
    return env

# Custom Shadow callback
def customShadowCallback_Update(payload, responseStatus, token):
    # payload is a JSON string ready to be parsed using json.loads(...)
    # in both Py2.x and Py3.x
    if responseStatus == "timeout":
        print("Update request " + token + " time out!")
    if responseStatus == "accepted":
        payloadDict = json.loads(payload)
        print("Update request with token: " + token + " accepted!")
    if responseStatus == "rejected":
        print("Update request " + token + " rejected!")

def customShadowCallback_Delta(payload, responseStatus, token):
    if responseStatus == 'delta/sensor':
        payloadDict = json.loads(payload)
        stateDict = payloadDict['state']
        if 'lights' in stateDict:
            lights = stateDict['lights']
        if (lights):
            print('Lights on!')
            GPIO.output(CHANNEL1, GPIO.LOW)
            GPIO.output(CHANNEL2, GPIO.LOW)
        else:
            print('Lights off!')
            GPIO.output(CHANNEL1, GPIO.HIGH)
            GPIO.output(CHANNEL2, GPIO.HIGH)

def customShadowCallback_Delete(payload, responseStatus, token):
    if responseStatus == "timeout":
        print("Delete request " + token + " time out!")
    if responseStatus == "accepted":
        print("~~~~~~~~~~~~~~~~~~~~~~~")
        print("Delete request with token: " + token + " accepted!")
        print("~~~~~~~~~~~~~~~~~~~~~~~\n\n")
    if responseStatus == "rejected":
        print("Delete request " + token + " rejected!")

rootCAPath = 'root-CA.crt'
certificatePath = 'sensor.pem'
privateKeyPath = 'private.key'
host = 'a3bsusgkvg1eik-ats.iot.us-east-1.amazonaws.com'
port = 8883
clientId = 'RaspberryPi'
thingName = 'sensor'

# Configure logging
logger = logging.getLogger("AWSIoTPythonSDK.core")
logger.setLevel(logging.DEBUG)
streamHandler = logging.StreamHandler()
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
streamHandler.setFormatter(formatter)
logger.addHandler(streamHandler)

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

# Delete shadow JSON doc
deviceShadowHandler.shadowDelete(customShadowCallback_Delete, 5)
deviceShadowHandler.shadowRegisterDeltaCallback(customShadowCallback_Delta)

# Update shadow in a loop
try:
    while True:
        env = measureEnvironment()
        light = meassureLight()
        envDict = {'temperature': env.temperature, 'pressure': env.pressure, 'altitude': env.altitude,
                   'light1': env.light1, 'light2': env.light2, 'light': light}
        stateDict = {'reported': envDict}
        payloadDict = {"state": stateDict}
        JSONPayload = json.dumps(payloadDict)
        print(JSONPayload)

        deviceShadowHandler.shadowUpdate(JSONPayload, customShadowCallback_Update, 5)
        time.sleep(5)
finally:
    GPIO.cleanup()
