# Reverse engineer a bootloader and test the undocumented feature.

## Reverse engineer bootloader to check code logic

OK, we got LED blinking, and now let's do something real. Just like this Abstruse Goose comic. ([Archive since original website is down](https://github.com/s-macke/Abstruse-Goose-Archive/blob/master/comics/474.md))

![Arithmetic for Beginners](imgs/If_the_authors_of_computer_programming_books_wrote_arithmetic_text_books.png)

A little background: WCH microcontroller generally come with USB bootloader but the protocol is confidential, back to the early chip CH552 (24Mhz 8051 chip with USB peripheral for $0.2~0.3), a bunch of [Germany enthusiasts](https://www.mikrocontroller.net/topic/462538) dumped the firmware until bootloader version v2.4 prevent them from doing so. With some reverse engineering effort both on microcontroller and ISP tool, some tools like [vnproch551](https://github.com/NgoHungCuong/vnproch551) and [wchisp](https://github.com/ch32-rs/wchisp) appears. 

I was able to dump the bootloader on CH572 with FLASH_ROM_READ, which is just a pointer read. Since I personally want to make every microcontroller Arduino, I want to find a way to jump from user code to bootloader. I can do it by [erase the first sector](https://www.cnblogs.com/debugdabiaoge/p/15880780.html) but it will brick the chip before another program process. To make things even worse, if the microcontroller is battery powered, the bootloader will timeout and lock the microcontroller from doing anything.

There is one sentence in datasheets mentions the RB_BOOT_LOAD_MAN can keep the chip in bootloader mode. And I did not get more help from customer support. So let's try to see if we get something by poking around.

First let's prepare the datasheet as text, location of GCC toolchain, and the dumped bootloader. I tried a few times with cursor agent. But it seems "Auto" mode does not really get something very useful, but "Sonnet 4.6" really works and give me some useful info.

I asked:

```
in exp4_ch572_bootloader_reverse_engineer, try your best to reverse engineer bootloader_dumpedHex.hex. You can use GCC packages in /Users/deqinguser/Library/Arduino15/packages/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin/
Target is -march=rv32imc_zba_zbb_zbc_zbs_xw
And you can read datasheet in CH572DS1.PDF, there is also md and txt formate converted for you.
try as best as you can to give me detailed flow chart of the bootloader, check all conditions inside.
For those addresses, find the name in datasheet. Create a md file for result
Im particularlly interested in in which case the bootloader will stay to wait for command, and in which case it will just go to app. Take a look at R8_RST_WDOG_CTRL (0x40001046), the lowest bit is dual use: RB_BOOT_LOAD_MAN and RB_SOFTWARE_RESET. 
```

And the generated "BOOTLOADER_REVERSE_ENGINEERING_REPORT.md", there is mentioned RB_BOOT_LOAD_MAN is checked for whether it is 1. The next step is to do experiment on real hardware to see how to set the bit, as the datasheet is not clear how to do it.

## Test undocumented feature

First we need to prepare the test environment. I connected a [ch55xRebootTool](https://github.com/DeqingSun/ch55xduino/tree/ch55xduino/pcb/ch55xRebootTool) to power cycle and kick CH572 into bootloader, and the CH572 target is a general board with USB connection. 

Let's get the Arduino ready:

```
in exp4_ch572_bootloader_reverse_engineer, first create a shell script to install Arduino cli, and add ch572 package from https://github.com/DeqingSun/arduino_core_ch32/releases/download/initBinStorage/package_ch32v_index_release.json, refer to scripts in exp1_LED_blink_on_Arduino_uno. When compile, the board should be "CH572_EVT", and the upload method should be "WCH-ISP". 
After you create the shell script to install Arduino, run it to install Arduino. Then, create a minimal sketch and a script to compile it. Then create a python script that can accept a hex file, run the "reboot.py" to kick CH572 into bootloader, and then upload the script to the CH572 with WCH-ISP (already in Arduino package). The upload script should only take the hex file. No serial port is needed because reboot.py can search for port, and WCH-ISP does not need a port.
Test all the script before you end.
```

Then let's do the real thing.

```
in "exp4_ch572_bootloader_reverse_engineer", As we researched in "BOOTLOADER_REVERSE_ENGINEERING_REPORT.md", the CH572 can stay in bootload if the RB_BOOT_LOAD_MAN is 1 during reboot. I want you to do experiment to confirm how to set RB_BOOT_LOAD_MAN to 1, as the datasheet is not very accurate.
You may create sketch and compile and upload to test it in real hardware. "upload_hex_ch572.py" can help you to upload. If you want to see registers, you should be able to copy it into a variable to send it through serial. Refer to exp4_ch572_bootloader_reverse_engineer/arduino_cli/data/packages/WCH/hardware/ch32v/26.2.6/libraries/SimpleUsbSerial/example/Simple_USB_CDC_TEST for serial communication. "APPJumpBoot" in exp4_ch572_bootloader_reverse_engineer/arduino_cli/data/packages/WCH/hardware/ch32v/26.2.6/libraries/SimpleUsbSerial/src/SimpleUsbCdc.c has somd code showing how to modify protected register and how to reboot system. Info about registers can be found both in datasheet CH572DS1.txt and board support source in exp4_ch572_bootloader_reverse_engineer/arduino_cli/data/packages/WCH/hardware/ch32v/26.2.6/system/CH572
The ultimate goal is, you write a sketch, it can run on the CH572, set correct register, reset and the CH572 stay in bootloader for 10 seconds. You should be able to see a USB device with Device VendorID/ProductID: 0x1A86/0x55E0.
The hardware setup is ready and tested. You just code, upload and test by yourself over and over again until you reach the ultimate goal. 
```