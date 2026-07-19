# Variables
TMP = .tmp
RTL = rtl
TB = tb
TEST = test

CC = riscv64-unknown-elf-gcc
CFLAGS = -O2 -mabi=ilp32 -march=rv32i -nostdlib -Ttext 0x00000000
C_SRC = $(TEST)/start.S $(TEST)/main.c
C_OUT = $(TMP)/firmware.elf
OBJ = riscv64-unknown-elf-objcopy
OBJFLAGS = -O binary
OBJ_OUT = $(TMP)/firmware.bin
HEX_OUT = $(TMP)/firmware.hex

VERILOG_SRC = $(RTL)/* $(TB)/*
SIM_VCD = $(TMP)/simulation.vcd
VV_FLAGS = -g2012 -DFIRMWARE_HEX='"$(HEX_OUT)"' -DSIMULATION_VCD='"$(SIM_VCD)"'
VV_OUT = $(TMP)/sim.vvp

# Declare targets as phony so they always run
.PHONY: all test clean

# Default target
all: test

test:
	@echo "\n=== Compiling source files to hex ===\n"
	mkdir -p $(TMP)
	$(CC) $(CFLAGS) $(C_SRC) -o $(C_OUT) # compile to elf
	$(OBJ) $(OBJFLAGS) $(C_OUT) $(OBJ_OUT) # objcopy to bin
	python3 -c "data = open('$(OBJ_OUT)', 'rb').read(); [print('%08x' % int.from_bytes(data[i:i+4], 'little')) for i in range(0, len(data), 4)]" > $(HEX_OUT) # convert to hex

	@echo "\n=== Compiling Verilog ===\n"
	iverilog $(VV_FLAGS) -o $(VV_OUT) $(VERILOG_SRC)

	@echo "\n=== Running simulation ===\n"
	vvp $(VV_OUT)

wave:
	@echo "\n=== Opening waveform viewer ===\n"	
	gtkwave $(SIM_VCD)

# Cleanup
clean:
	@echo "=== Cleaning temp directory ==="
	@rm -rf $(TMP)