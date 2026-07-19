`timescale 1ns/1ps

module tb;
    reg clk = 0;
    reg resetn = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile(`SIMULATION_VCD);
        $dumpvars(0, tb);
        resetn = 0;
        #20 resetn = 1;
        #100000 $finish;
    end

    wire mem_valid;
    wire mem_instr;
    reg mem_ready;
    wire [31:0] mem_addr;
    wire [31:0] mem_wdata;
    wire [3:0] mem_wstrb;
    reg [31:0] mem_rdata;

    // 16KB RAM (4096 words x 32 bits)
    reg [31:0] memory [0:4095];

    // Load the compiled C code hex file
    initial $readmemh(`FIRMWARE_HEX, memory);

    always @(posedge clk) begin
        mem_ready <= 0;
        
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1; // Respond to the core in the next cycle
            
            // Intercept MMIO Print Address
            if (mem_addr == 32'h10000000 && |mem_wstrb) begin
                $write("%c", mem_wdata[7:0]);
                $fflush();
            end
            else if (mem_addr == 32'h20000000 && |mem_wstrb) begin
                $display("Simulation Exit Requested");
                $finish;
            end
            // Standard Memory Access
            else if (mem_addr < 32'h00004000) begin
                if (mem_wstrb[0]) memory[mem_addr[13:2]][7:0]   <= mem_wdata[7:0];
                if (mem_wstrb[1]) memory[mem_addr[13:2]][15:8]  <= mem_wdata[15:8];
                if (mem_wstrb[2]) memory[mem_addr[13:2]][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) memory[mem_addr[13:2]][31:24] <= mem_wdata[31:24];
                
                mem_rdata <= memory[mem_addr[13:2]];
            end
        end
    end

    // Instantiate PicoRV32 Core
    picorv32 #(
        .ENABLE_REGS_16_31(1),
        .BARREL_SHIFTER(1)
    ) uut (
        .clk(clk),
        .resetn(resetn),
        .mem_valid(mem_valid),
        .mem_instr(mem_instr),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata)
    );
endmodule