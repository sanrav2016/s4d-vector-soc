# S4D Vector SoC

Edge AI mini SoC with [PicoRV32](https://github.com/YosysHQ/picorv32) RISC-V CPU and S4D fixed-point accelerator

### Summary
This design enables accelerated inference of an S4D (Diagonal State Space Sequence Model) model. In general, state space models are defined by two equations:

$$
\begin{aligned}
\dot{\mathbf{h}}(t) &= \mathbf{A}\mathbf{h}(t) + \mathbf{B}\mathbf{x}(t) \\
\mathbf{y}(t) &= \mathbf{C}\mathbf{h}(t) + \mathbf{D}\mathbf{x}(t)
\end{aligned}
$$

where $ h $ is the state vector, $ x $ (or $ u $) is the input vector, and $ y $ is the output vector. These equations can also be represented in a loop diagram; [this video](https://www.youtube.com/watch?v=BDTVVlUU1Ck) has a pretty good one:

<div align="center">
<img width="400" src="assets/ssm-equations.png" />
</div>

### Dependencies
- riscv64-unknown-elf-gcc
- python3
- iverilog
- gtkwave (optional)

[IIC-OSIC-Tools](https://github.com/iic-jku/iic-osic-tools) (listed in ```devcontainer.json```) bundles all these tools and more!

### Usage
```
> git clone https://github.com/sanrav2016/s4d-vector-soc.git
> cd s4d-vector-soc
> make test-soc     # run firmware
> make wave         # view waveform
> make clean        # delete .tmp dir
```

### References
- https://arxiv.org/abs/2111.00396
- https://arxiv.org/abs/2206.11893
- https://github.com/state-spaces/s4
- https://www.youtube.com/watch?v=BDTVVlUU1Ck
- https://www.youtube.com/watch?v=Qgjawf20v7Y