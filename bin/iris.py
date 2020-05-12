#!/usr/bin/python

import RPi.GPIO as GPIO
import time
import sys

GPIO.setmode(GPIO.BOARD)
GPIO.setup(12, GPIO.OUT)

p = GPIO.PWM(12, 50)
p.start(7.5)

if sys.argv[1] == 'close':
	p.ChangeDutyCycle(7.5)
	time.sleep(1)
else:
	p.ChangeDutyCycle(12.5)
	time.sleep(1)

p.stop()
GPIO.cleanup()
