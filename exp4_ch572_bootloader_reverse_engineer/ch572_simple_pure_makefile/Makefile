# Minimal CH572 blink (PA11). Link.ld and startup_CH572.S live in this folder
# (vendored from WCH CH32V Arduino core). Toolchain and wchisp still come from
# ../arduino_cli/data/packages by default.
ARDUINO_PACKAGES ?= ../arduino_cli/data/packages
TOOLBIN ?= $(ARDUINO_PACKAGES)/WCH/tools/riscv-none-embed-gcc/ide_2.2.0_trimmed/bin

# wchisp from the same Arduino package tree (lexicographically last version folder).
WCHISP_ROOT ?= $(ARDUINO_PACKAGES)/WCH/tools/wchisp
WCHISP ?= $(lastword $(sort $(wildcard $(WCHISP_ROOT)/*/wchisp)))
# Optional: pulse ch55xRebootTool so the chip enters USB ISP (same as upload_hex_ch572.py).
REBOOT_SCRIPT ?= reboot.py

PREFIX := $(TOOLBIN)/riscv-wch-elf-
CC      := $(PREFIX)gcc
CXX     := $(PREFIX)g++
OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump
SIZE    := $(PREFIX)size

LDSCRIPT := Link.ld
STARTUP  := startup_CH572.S

TARGET := ch572_pa11_blink
BUILD  := build

ARCHFLAGS := -march=rv32imc_zba_zbb_zbc_zbs_xw -mabi=ilp32 --param=highcode-gen-section-name=1
COMMON    := $(ARCHFLAGS) -msmall-data-limit=8 -msave-restore -fmessage-length=0 -fsigned-char \
             -ffunction-sections -fdata-sections -fno-common -Os -DNDEBUG

CPPFLAGS := -DCH572 -DARDUINO_ARCH_CH32

CFLAGS   := $(COMMON) $(CPPFLAGS) -std=gnu11
CXXFLAGS := $(COMMON) $(CPPFLAGS) -std=gnu++14 -fno-threadsafe-statics -fno-rtti -fno-exceptions \
            -fno-use-cxa-atexit

LDFLAGS := $(ARCHFLAGS) -T $(LDSCRIPT) -nostartfiles -Wl,--gc-sections \
           -Wl,-Map=$(BUILD)/$(TARGET).map \
           -Wl,--defsym=__FLASH_SIZE=245760 -Wl,--defsym=__RAM_SIZE=12288 \
           --specs=nano.specs --specs=nosys.specs \
           -Wl,--start-group $(BUILD)/main.cpp.o $(BUILD)/startup_CH572.o -lc -Wl,--end-group

.PHONY: all clean flash

# MAP is written by the same link line as ELF (see -Wl,-Map=...); it is not a separate rule.
all: $(BUILD)/$(TARGET).elf $(BUILD)/$(TARGET).hex $(BUILD)/$(TARGET).lst
	$(SIZE) -A $(BUILD)/$(TARGET).elf

$(BUILD)/$(TARGET).elf: $(BUILD)/main.cpp.o $(BUILD)/startup_CH572.o $(LDSCRIPT) | $(BUILD)
	$(CXX) $(LDFLAGS) -o $@

$(BUILD)/$(TARGET).hex: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -O ihex $< $@

$(BUILD)/$(TARGET).bin: $(BUILD)/$(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(BUILD)/$(TARGET).lst: $(BUILD)/$(TARGET).elf
	$(OBJDUMP) -xdS $< > $@

$(BUILD)/main.cpp.o: main.cpp | $(BUILD)
	$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

$(BUILD)/startup_CH572.o: $(STARTUP) | $(BUILD)
	$(CC) $(ARCHFLAGS) -c $< -o $@

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)

flash: $(BUILD)/$(TARGET).hex
	@if [ ! -f "$(WCHISP)" ]; then \
		echo "ERROR: wchisp not found. Expected under $(WCHISP_ROOT)/*/wchisp"; \
		echo "Set WCHISP=/path/to/wchisp or fix ARDUINO_PACKAGES."; exit 1; \
	fi
	@if [ -f "$(REBOOT_SCRIPT)" ]; then \
		echo "Running $(REBOOT_SCRIPT) ..."; python3 "$(REBOOT_SCRIPT)" || true; sleep 0.7; \
	fi
	@echo "Flashing: $(WCHISP) --retry 2 flash $<"
	"$(WCHISP)" --retry 2 flash "$<"

-include $(BUILD)/main.cpp.d
