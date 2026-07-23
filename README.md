# S4D Vector SoC

Edge AI mini SoC with
- [PicoRV32](https://github.com/YosysHQ/picorv32) RISC-V CPU
- S4D (Diagonal State Space Sequence Model) fixed-point accelerator
- AXI4-Lite interconnect
- UART peripheral

### Summary
WiP

### Dependencies
- riscv64-unknown-elf-gcc
- python3
- iverilog
- gtkwave (optional)

### Usage
```
> git clone https://github.com/sanrav2016/s4d-vector-soc.git
> cd s4d-vector-soc
> make
> make wave     # view waveform
> make clean    # delete .tmp dir
```

### References
- https://arxiv.org/abs/2111.00396
- https://arxiv.org/abs/2206.11893
- https://github.com/state-spaces/s4
- https://www.youtube.com/watch?v=BDTVVlUU1Ck