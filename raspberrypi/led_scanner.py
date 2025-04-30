import time
from machine import Pin

# Test pins 0 through 28 (Pico has GP0 to GP28)
def test_pins():
    for pin_number in range(29):
        print(f"Testing PIN {pin_number}")
        led = Pin(pin_number, Pin.OUT)
        
        # Blink 3 times for each pin
        for _ in range(3):
            led.value(1)
            time.sleep(0.2)
            led.value(0)
            time.sleep(0.2)
            
        # Pause between pins
        time.sleep(0.5)

try:
    test_pins()
except Exception as e:
    print(f"Error: {e}")
