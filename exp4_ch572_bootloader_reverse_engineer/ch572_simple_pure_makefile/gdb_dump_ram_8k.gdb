# Use with OpenOCD already listening for GDB (default :3333).
# From this directory: riscv-wch-elf-gdb -x gdb_dump_ram_8k.gdb
# Or: riscv-wch-elf-gdb -q -batch -x gdb_dump_ram_8k.gdb

set pagination off
set confirm off
set remotetimeout 30

file build/ch572_pa11_blink.elf

# OpenOCD’s bundled GDB server is plain remote (port 3333 in your log).
target remote localhost:3333

# If this errors, try: mon halt   or   mon reset
monitor reset halt

# Line 20 in main.cpp: patch write right after the 0x2000-byte ROM→RAM copy.
break main.cpp:20

printf "Continuing until breakpoint (GPIO blink loop then copy)...\n"
continue

printf "Dumping 8192 bytes from 0x20000000 (after ROM copy, before patch) ...\n"
dump binary memory build/ram_0x20000000_8k.bin 0x20000000 0x20002000

# After patch + clear loop; before asm / mret (main.cpp line 27).
clear main.cpp:20
break main.cpp:27
printf "Continuing to line 27 ...\n"
continue

printf "Dumping 8192 bytes from 0x20000000 again (after patch + clear) ...\n"
dump binary memory build/ram_0x20000000_8k_line27.bin 0x20000000 0x20002000

printf "Done. RAM dumps:\n  build/ram_0x20000000_8k.bin (line 20)\n  build/ram_0x20000000_8k_line27.bin (line 27)\n"
detach
quit
