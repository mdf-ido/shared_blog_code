import neopixel
from machine import Pin
from time import sleep

pixPin = 0
pixSize = 16
pix = neopixel.NeoPixel(Pin(pixPin), pixSize)

# Colors
red = (255, 0, 0)
green = (0, 255, 0)
off = (0, 0, 0)

POMODORO_MINUTES = 1
SECONDS_PER_MINUTE = 60
total_seconds = POMODORO_MINUTES * SECONDS_PER_MINUTE
seconds_per_pixel = total_seconds / pixSize

def set_progress(remaining_seconds):
    # Calculate how many LEDs should be lit
    active_pixels = int((remaining_seconds / total_seconds) * pixSize)
    
    # Turn off all pixels first
    for i in range(pixSize):
        pix[i] = off
    
    # Light up the remaining time pixels in green
    for i in range(active_pixels):
        pix[i] = green
    
    pix.write()

# Main timer loop
remaining_seconds = total_seconds

while remaining_seconds > 0:
    set_progress(remaining_seconds)
    sleep(1)
    remaining_seconds -= 1

# Timer finished - flash red
for _ in range(5):
    for i in range(pixSize):
        pix[i] = red
    pix.write()
    sleep(0.5)
    for i in range(pixSize):
        pix[i] = off
    pix.write()
    sleep(0.5)