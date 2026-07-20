`define PRINT_ADDR 32'h10000000
`define EXIT_ADDR 32'h20000000

// 64 KB memory
`define RAM_SIZE 32'h00010000

module bram(
    input wire clk,
    input wire mem_valid,
    input wire mem_instr,
    input wire [31:0] mem_addr,
    input wire [31:0] mem_wdata,
    input wire [3:0] mem_wstrb,
    output reg mem_ready,
    output reg [31:0] mem_rdata
);

    reg [31:0] memory [0:(`RAM_SIZE/4)-1];

    // Simulate reading binary from flash
    initial $readmemh(`FIRMWARE_HEX, memory);

    always @(posedge clk) begin
        mem_ready <= 0;
        
        if (mem_valid && !mem_ready) begin
            mem_ready <= 1; // Respond to the core in the next cycle
            
            // Intercept MMIO Print Address
            if (mem_addr == `PRINT_ADDR && |mem_wstrb) begin
                $write("%c", mem_wdata[7:0]);
                $fflush();
            end
            else if (mem_addr == `EXIT_ADDR && |mem_wstrb) begin
                $display("Simulation Exit Requested");
                $finish;
            end
            // Standard Memory Access
            else if (mem_addr < `RAM_SIZE) begin
                if (mem_wstrb[0]) memory[mem_addr[31:2]][7:0]   <= mem_wdata[7:0];
                if (mem_wstrb[1]) memory[mem_addr[31:2]][15:8]  <= mem_wdata[15:8];
                if (mem_wstrb[2]) memory[mem_addr[31:2]][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) memory[mem_addr[31:2]][31:24] <= mem_wdata[31:24];
                
                mem_rdata <= memory[mem_addr[31:2]];
            end
        end
    end
endmodule