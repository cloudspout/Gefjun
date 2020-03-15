import logging
import RPi.GPIO as GPIO
from signal import signal, SIGINT, SIGTERM

# Configure logging
logger = logging.getLogger("Gefjun.Greenhouse")
logger.setLevel(logging.INFO)

from mcp3208 import MCP3208
import Adafruit_BMP.BMP085 as BMP085
from dataclasses import dataclass

@dataclass
class PhysicalEnvironment:
    pressure: float
    altitude: float
    temperature: float
    lux1: int
    lux2: int
    light: bool

class Greenhouse:
    """The connetion to the physical world"""
    CHANNEL1=17
    CHANNEL2=18
    
    def __init__(self):
        self.light = False
        
        self.adc = MCP3208()
        self.sensor2 = BMP085.BMP085(mode=BMP085.BMP085_ULTRAHIGHRES)
        
        signal(SIGTERM, self.__cleanup)

        GPIO.setmode(GPIO.BCM)
        GPIO.setup(self.CHANNEL1, GPIO.OUT)
        GPIO.output(self.CHANNEL1, GPIO.HIGH)
        GPIO.setup(self.CHANNEL2, GPIO.OUT)
        GPIO.output(self.CHANNEL2, GPIO.HIGH)
        
    def __enter__(self):
        logger.info('enter')
        return self

    def __cleanup(self):
        logger.info('GPIO cleanup')
        GPIO.cleanup()
        
    def __exit__(self, whatever, this, might):
        self.__cleanup()
    
    def __del__(self):
        self.__cleanup()
    
    def turnLightsOn(self):
        logger.warn('Light on!')
        self.light = True
        GPIO.output(self.CHANNEL1, GPIO.LOW)
        GPIO.output(self.CHANNEL2, GPIO.LOW)
        
    def turnLightsOff(self):
        logger.warn('Light off!')
        self.light = False
        GPIO.output(self.CHANNEL1, GPIO.HIGH)
        GPIO.output(self.CHANNEL2, GPIO.HIGH)
    
    def measureEnvironment(self):
        env = PhysicalEnvironment(pressure=self.sensor2.read_pressure(),
                                  altitude=self.sensor2.read_altitude(),
                                  temperature=self.sensor2.read_temperature(),
                                  lux1=self.adc.read(0),
                                  lux2=self.adc.read(1),
                                  light=self.light)
        logger.debug('Current environment: %s', env)
        return env
