module soc_top(
    input wire clk,
    input wire resetn
);

    wire mem_valid;
    wire mem_instr;
    wire mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0] mem_wstrb;
    wire [31:0] mem_rdata;

    wire pcpi_valid;
    wire [31:0] pcpi_insn;
    wire [31:0] pcpi_rs1;
    wire [31:0] pcpi_rs2;
    wire pcpi_wr;
    wire [31:0] pcpi_rd;
    wire pcpi_wait;
    wire pcpi_ready;

    wire [3:0] accel_mem_wstrb;
    wire [31:0] accel_mem_addr;
    wire [31:0] accel_mem_wdata;
    wire [31:0] accel_mem_rdata;
    wire accel_mem_ready;
    wire accel_mem_valid;

    // Native block RAM
    native_bram bram (
        .clk(clk),

        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),

        .accel_mem_wstrb(accel_mem_wstrb),
        .accel_mem_addr(accel_mem_addr),
        .accel_mem_wdata(accel_mem_wdata),
        .accel_mem_rdata(accel_mem_rdata),
        .accel_mem_ready(accel_mem_ready),
        .accel_mem_valid(accel_mem_valid)
    );

    // Accelerator core
    accelerator_core accel (
        .clk(clk),
        .resetn(resetn),

        .pcpi_valid(pcpi_valid),
        .pcpi_insn(pcpi_insn),
        .pcpi_rs1(pcpi_rs1),
        .pcpi_rs2(pcpi_rs2),
        .pcpi_wr(pcpi_wr),
        .pcpi_rd(pcpi_rd),
        .pcpi_wait(pcpi_wait),
        .pcpi_ready(pcpi_ready),

        .accel_mem_wstrb(accel_mem_wstrb),
        .accel_mem_addr(accel_mem_addr),
        .accel_mem_wdata(accel_mem_wdata),
        .accel_mem_rdata(accel_mem_rdata),
        .accel_mem_ready(accel_mem_ready),
        .accel_mem_valid(accel_mem_valid)
    );

    // CPU  
    picorv32 #(
        .ENABLE_REGS_16_31(1),
        .BARREL_SHIFTER(1),
        .ENABLE_MUL(1),
        .ENABLE_PCPI(1)
    ) cpu (
        .clk(clk),
        .resetn(resetn),

        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),

        .pcpi_valid(pcpi_valid),
        .pcpi_insn(pcpi_insn),
        .pcpi_rs1(pcpi_rs1),
        .pcpi_rs2(pcpi_rs2),
        .pcpi_wr(pcpi_wr),
        .pcpi_rd(pcpi_rd),
        .pcpi_wait(pcpi_wait),
        .pcpi_ready(pcpi_ready)
    );

endmodule