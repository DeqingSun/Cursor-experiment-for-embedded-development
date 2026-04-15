# Basic blink LED

## Just make a blink LED with Arduino Uno

Making a blinking LED is most basic Hello World code for electronics. You just download Arduino IDE, open the example, choose the correct board and port, press upload and you are done. 

I guess the agent prefer Arduino Cli, so let's get started!

I typed the following in the chat window of cursor.

```
Can you help me install Arduino cli in a folder called "arduino_cli", inside the exp1_LED_blink_on_Arduino_uno. Ideally, I want you to write a shell script inside exp1_LED_blink_on_Arduino_uno, it will download pre-compiled macOS ARM binary and unzip it there. You can test if it works. And ultimately, I will be able to run the script anywhere to get the Arduino CLI ready.
You can keep try the script you made until you've verified it works.
I found the Binary on https://arduino.github.io/arduino-cli/1.4/installation/ 
```

And I got install_arduino_cli.sh, and the "arduino_cli" folder pops up!

Then I typed:

```
That is nice, I can confirn the Arduino Cli is ready. Do I need to install anything to compile and upload Arduino Uno? If so I also want it to stay inside the "arduino_cli" folder
```

And I got another setup_arduino_uno.sh

Now let‘s create a blink code.

```
Great! now please create a blinking LED code on pin13 for Arduino, inside the exp1_LED_blink_on_Arduino_uno, and another shell script to compile and upload through serial
```

And the "blink_pin13" shows up and the "compile_and_upload.sh" script can compile and upload the code, I can see the LED blink!

![Blinking LED on Arduino Uno](imgs/uno_blink.gif)

But wait, my goal was to remove myself from the loop. maybe I can use a logic analyzer to check the signal instead of me look into it.

I have Saleae Logic Analyzer and it supports API access, so it should be able to automate the measurement. The Saleae Logic support "logic2-automation" library and it can be installed with ```python3 -m pip install logic2-automation```.

And inside Logic2 software, we need to enable "Automation Server", and configure the channel correctly.

![Logic2 config](imgs/logic2Setup.png)

![Logic2 to Arduino connection](imgs/saleae_connect.jpg)

Then I give Cursor agent instruction:

```
I want to use saleae logic to check if the LED is blinking with correct interval. I have connected channel 0 of Saleae logic to the pin 13. And I've installed logic2-automation. 
Can you help me write code to use API to measure it? You need to test the code until it runs well. 
```

And I did get the ```saleae_measure_blink.py```, when the script runs. The logic2 software start to capture signals. And I got result:

```
% python3 saleae_measure_blink.py
Connected to Logic2 app_version=2.4.43 api=Version(major=1, minor=0, patch=0)
period: n=2 mean=1.997296s stdev=0.000001s min=1.997294s max=1.997297s
high  : n=3 mean=0.998649s stdev=0.000000s min=0.998649s max=0.998650s
low   : n=3 mean=0.997124s stdev=0.002152s min=0.994080s max=0.998647s
PASS: blink timing within tolerance
```  

And yes! This experiment proves the agent is possble to use API of hardware tools to replace human in this blinking example.
