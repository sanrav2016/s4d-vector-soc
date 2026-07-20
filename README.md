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

--- Timestep t = 0 ---
Sample State Ch0, State0: Real=2048, Imag=0
Output Feature Map y_t  : [408, -207, -106, 48, 22, 9, 3, -7, 0, -10, -16, -29, -55, 99, 202, -411]

--- Timestep t = 1 ---
Sample State Ch0, State0: Real=2950, Imag=150
Output Feature Map y_t  : [465, -445, -325, 238, 215, 207, 199, -206, -100, 91, 88, 73, 65, 20, 139, -233]

--- Timestep t = 2 ---
Sample State Ch0, State0: Real=6893, Imag=358
Output Feature Map y_t  : [1104, -499, -1186, 197, 970, 182, 944, -245, 703, 74, -759, 66, -778, 11, 947, -161]