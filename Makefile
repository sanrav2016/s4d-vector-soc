# Variables
TMP = .tmp
RTL = rtl
TB = tb
TEST = firmware

CC_PREFIX = riscv64-unknown-elf
CC = $(CC_PREFIX)-gcc
CC_LINK = $(TEST)/linker.ld
CFLAGS = -O3 -mabi=ilp32 -march=rv32im -nostdlib -nostartfiles -T $(CC_LINK) -mno-relax
C_SRC = $(TEST)/start.S $(wildcard $(TEST)/*.c)
C_OUT = $(TMP)/firmware.elf
OBJ = $(CC_PREFIX)-objcopy
OBJFLAGS = -O binary
OBJ_OUT = $(TMP)/firmware.bin
HEX_OUT = $(TMP)/firmware.hex

RTL_SRC = $(RTL)/*
SOC_TEST_TB = $(TB)/soc_tb.v
ACCEL_TEST_TB = $(TB)/accelerator_tb.v
SIM_VCD = $(TMP)/simulation.vcd
VV_FLAGS = -g2012 -DFIRMWARE_HEX='"$(HEX_OUT)"' -DSIMULATION_VCD='"$(SIM_VCD)"'
VV_OUT = $(TMP)/sim.vvp

.PHONY: all build test clean

# Default target
all: build

build:
	@echo "\n=== Compiling source files to hex ===\n"
	mkdir -p $(TMP)
	$(CC) $(CFLAGS) $(C_SRC) -o $(C_OUT) # compile to elf
	$(OBJ) $(OBJFLAGS) $(C_OUT) $(OBJ_OUT) # objcopy to bin
	python3 -c "data = open('$(OBJ_OUT)', 'rb').read(); [print('%08x' % int.from_bytes(data[i:i+4], 'little')) for i in range(0, len(data), 4)]" > $(HEX_OUT) # convert to hex

test-soc: build
	@echo "\n=== Compiling Verilog ===\n"
	iverilog $(VV_FLAGS) -o $(VV_OUT) $(RTL_SRC) $(SOC_TEST_TB)

	@echo "\n=== Running simulation ===\n"
	vvp $(VV_OUT)

test-accelerator: build
	@echo "\n=== Compiling Verilog ===\n"
	iverilog $(VV_FLAGS) -o $(VV_OUT) $(RTL_SRC) $(ACCEL_TEST_TB)

	@echo "\n=== Running simulation ===\n"
	vvp $(VV_OUT)

wave:
	@echo "\n=== Opening waveform viewer ===\n"	
	gtkwave $(SIM_VCD)

# Cleanup
clean:
	@echo "\n=== Cleaning temp directory ===\n"
	@rm -rf $(TMP)