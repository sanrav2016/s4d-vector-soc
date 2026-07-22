module native_bram #(
    // 64 KB default
    // make sure to update start.S and linker.ld in firmware if changing
    parameter [31:0] RAM_SIZE = 32'h0001_0000, 
    // MMIO params
    parameter [31:0] PRINT_ADDR = 32'h1000_0000,
    parameter [31:0] EXIT_ADDR = 32'h2000_0000,
    // must be greater than RAM_SIZE
    parameter [31:0] ACCEL_RAM_BASE_ADDR = 32'h4000_0000
) (
    input wire clk,
    
    input wire mem_valid,
    input wire mem_instr,
    input wire [31:0] mem_addr,
    input wire [31:0] mem_wdata,
    input wire [3:0] mem_wstrb,
    output reg mem_ready,
    output reg [31:0] mem_rdata,

    output reg [3:0] accel_mem_wstrb,
    output reg [31:0] accel_mem_addr,
    output reg [31:0] accel_mem_wdata,
    input wire [31:0] accel_mem_rdata,
    output reg accel_mem_valid,
    input wire accel_mem_ready
);

    reg [31:0] memory [0:(RAM_SIZE/4)-1];

    always @(posedge clk) begin
        mem_ready <= 0;
        accel_mem_valid <= 0;
        
        if (mem_valid && !mem_ready) begin

            // Intercept MMIO print address
            if (mem_addr == PRINT_ADDR && |mem_wstrb) begin
                mem_ready <= 1;
                $write("%c", mem_wdata[7:0]);
                $fflush();
            end

            // Intercept MMIO exit address
            else if (mem_addr == EXIT_ADDR && |mem_wstrb) begin
                mem_ready <= 1;
                $display("Simulation Exit Requested");
                $finish;
            end

            // Native BRAM access
            else if (mem_addr < RAM_SIZE) begin
                mem_ready <= 1;
                // From picorv32 documentation: 
                // The 4 bits of mem_wstrb are write enables for the four bytes in the addressed word.
                if (mem_wstrb[0]) memory[mem_addr[31:2]][7:0]   <= mem_wdata[7:0];
                if (mem_wstrb[1]) memory[mem_addr[31:2]][15:8]  <= mem_wdata[15:8];
                if (mem_wstrb[2]) memory[mem_addr[31:2]][23:16] <= mem_wdata[23:16];
                if (mem_wstrb[3]) memory[mem_addr[31:2]][31:24] <= mem_wdata[31:24];
                mem_rdata <= memory[mem_addr[31:2]];
            end

            // Accelerator memory access
            else if (mem_addr >= ACCEL_RAM_BASE_ADDR) begin
                // Hold valid high and pass data
                accel_mem_valid <= 1;
                accel_mem_wstrb <= mem_wstrb;
                accel_mem_addr <= mem_addr;
                accel_mem_wdata <= mem_wdata;
                
                // Only complete the CPU transaction when accelerator responds
                if (accel_mem_ready) begin
                    mem_ready <= 1;
                    mem_rdata <= accel_mem_rdata;
                    accel_mem_valid <= 0; // Drop valid
                end
            end
        end
    end
endmodule