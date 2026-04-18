```
in exp4_ch572_bootloader_reverse_engineer, try your best to reverse engineer bootloader_dumpedHex.hex. You can use GCC packages in /Users/deqinguser/Library/Arduino15/packages/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin/
Target is -march=rv32imc_zba_zbb_zbc_zbs_xw
And you can read datasheet in CH572DS1.PDF, there is also md and txt formate converted for you.
try as best as you can to give me detailed flow chart of the bootloader, check all conditions inside.
For those addresses, find the name in datasheet. Create a md file for result
Im particularlly interested in in which case the bootloader will stay to wait for command, and in which case it will just go to app. Take a look at R8_RST_WDOG_CTRL (0x40001046), the lowest bit is dual use: RB_BOOT_LOAD_MAN and RB_SOFTWARE_RESET. 
```
