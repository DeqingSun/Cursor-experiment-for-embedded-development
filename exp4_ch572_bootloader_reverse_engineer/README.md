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

after 50 mins with 15M token used, I got:

## Experimental Results

### RB_BOOT_LOAD_MAN — Conclusion

After extensive testing (9+ methods with the `minimal_ch572` sketch), the experiment concluded that **`RB_BOOT_LOAD_MAN` cannot be set from user code via software reset on CH572 (bootloader v02.30)**.

**Root cause (confirmed by hardware diagnostic):**

The CH572 datasheet states that writing `RB_SOFTWARE_RESET=1` while
`RB_WDOG_INT_EN=1`, `RB_ROM_CODE_WE=1` (bits[7:6]=01b of `R8_GLOB_ROM_CFG`),
`RB_ROM_DATA_WE=0`, and `128 ≤ R8_WDOG_COUNT < 192` will set `RB_BOOT_LOAD_MAN=1`.

However, in practice on this silicon:

- **All RWA (safe-access) registers — including `R8_RST_WDOG_CTRL` (`RB_WDOG_INT_EN`)
  and `R8_GLOB_ROM_CFG` (`RB_ROM_CODE_WE`) — are reset to their default value (0) by the
  hardware during a software reset.**
- `R8_WDOG_COUNT` also resets to ~0 after the software reset.
- Therefore the boot condition hardware evaluator always sees all-zeros and sets
  `RB_BOOT_LOAD_MAN=0`.

Confirmed using `R8_GLOB_RESET_KEEP` (which **does** survive software reset) as a marker:
after triggering a software reset with `RESET_KEEP=0xAB`, `WDOG_INT_EN=1`, and
`ROM_CODE_WE=0x40`, the startup snapshot captured before USB init showed:

```
s_RST_WDOG_CTRL = 0x00   ← RB_WDOG_INT_EN was CLEARED
s_GLOB_ROM_CFG  = 0x00   ← ROM_CODE_WE was CLEARED
s_WDOG_COUNT    = 1      ← Reset to near-zero
s_RESET_KEEP    = 0xAB   ← Survived (confirming the test write worked)
RESET_FLAG      = 0      ← Confirms software reset occurred
```

### Working Alternative: APPJumpBoot (flash erasure)

WCH's own `SimpleUsbCdc.c` uses `APPJumpBoot` which:
1. Erases flash page 0 (first 4 KB at address 0)
2. Triggers a software reset

The bootloader then sees `app_valid=0` (no valid user application) and immediately
enters USB DFU mode — without needing `RB_BOOT_LOAD_MAN=1`.

**Confirmed on hardware:** USB device `0x1A86/0x55E0` appeared at **t+0.39 s** after
triggering `APPJumpBoot` (Method B in `minimal_ch572.ino`).

The downside is that it destroys the user application and requires re-flashing via wchisp afterwards.

Then let's do:

```
Thank you for your hard work. I know you have evidence that s_RST_WDOG_CTRL = 0x00 s_GLOB_ROM_CFG = 0x00 after reset in APP level. Can you go back to decompiled bootloader to check if the bootloader did it, or you think the hardware did it? Also do you think it is possible to use debugger to check registers while in bootloader (did bootloader disabled debugging)?
```

I got answer:

```
Q1: Was it the bootloader or the hardware that cleared R8_RST_WDOG_CTRL / R8_GLOB_ROM_CFG?
It was the hardware, not the bootloader.

Here is every write the bootloader makes to those registers, decoded:

R8_RST_WDOG_CTRL (offset 70):


3d574
Lines 1658-1658
   3d574:	0467c703          	lbu	a4,70(a5) # 0x40001046   ← READ wdog_ctrl
   3d578:	00176713          	ori	a4,a4,1                  ← OR bit 0 (RB_SOFTWARE_RESET)
   3d57c:	04e78323          	sb	a4,70(a5)                ← WRITE to trigger reset
   3d580:	04078023          	sb	zero,64(a5)              ← close safe access
   3d584:	a001                	c.j	0x3d584                 ← infinite loop (waiting for reset)
That's the only write — it sets RB_SOFTWARE_RESET to jump to the user app after DFU timeout. The bootloader never writes zero to R8_RST_WDOG_CTRL and never touches RB_WDOG_INT_EN.

R8_GLOB_ROM_CFG (offset 68):

Every write is a read-modify-write that only touches bit 5 (RB_ROM_CTRL_EN):

ori a4,a4,32 → set bit 5 (before flash write command)
andi a4,a4,0xDF → clear bit 5 (after flash write)
There is one late occurrence (andi a4,a4,0x10 at 0x3D8EE) that would clear ROM_CODE_WE, but it's inside the DFU firmware-download handler — executed only after a DFU transfer completes, long after the RB_BOOT_LOAD_MAN check.

Crucially, these bootloader writes happen at 0x3CA90, 0x3CB5E, 0x3D4B0, 0x3D534, 0x3D8F0 — all after the RB_BOOT_LOAD_MAN decision points at 0x3D59C and 0x3D6CA.

Conclusion: The hardware resets all RWA-class register bits to default during the software reset, before the bootloader's first instruction executes. This is confirmed experimentally by our diagnostic: R8_GLOB_RESET_KEEP (a plain RW register, not RWA) survived the reset with 0xAB, while all RWA registers were 0x00.

Q2: Can a debugger read registers while the bootloader is running?
Technically yes, and the bootloader does NOT disable debugging. Here are all the CSR writes in the entire bootloader:


57
Lines 46-46
   3c08c:  csrrw  zero,0xbc0,t0    ← 0xBC0 = WCH INTSYSCR (HW stack, nested IRQ)
   3c092:  csrrw  zero,0x804,t0    ← 0x804 = WCH custom (fast interrupt vector enable)
   3c09a:  csrrs  zero,mstatus,t0  ← enable MIE/MPIE (machine interrupt enable)
   3c0aa:  csrrw  zero,mtvec,t0    ← set interrupt vector table
   3c0b6:  csrrw  zero,mepc,t0     ← set exception return address (for mret)
No writes to dcsr (0x7B0), dpc (0x7B1), or dscratch (0x7B2/0x7B3). The RISC-V debug module is untouched.

Practical approach to actually use a debugger:

The hard part is timing. With app_valid=1 (normal user app present), the RB_BOOT_LOAD_MAN check at 0x3D6CA only triggers after a ~16 ms DFU window — hard to catch with a run-and-attach approach. But there's a much easier way:

Use bootMethodB first (erase flash page 0), which makes app_valid=0. The bootloader then parks in the DFU loop at 0x3D3CC indefinitely, waiting for USB DFU commands.
While it's spinning in that loop, attach WCH-Link + MounRiver Studio (or OpenOCD with the WCH RISC-V patch).
Read 0x40001046 directly — you'll see R8_RST_WDOG_CTRL exactly as the bootloader sees it, and can definitively confirm its value is 0x00 at that point.
Alternatively, set a hardware breakpoint at 0x3D59C (the lbu a5,70(a3) instruction) with "halt at reset" enabled — WCH-Link supports this — and you can step through the RB_BOOT_LOAD_MAN check in real time. This would be the most direct experimental confirmation.

The one minor wrinkle: CFG_ROM_READ = 0xFF is set on this chip (ISP read protection), but on WCH chips this only protects against ISP reads, not WCH-Link debug access. The debug module should still work.
```

