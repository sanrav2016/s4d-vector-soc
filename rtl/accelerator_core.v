`define D_MODEL 16
`define D_STATE 8
`define LOCAL_RAM_BASE_ADDR 32'h4000_0000

// 32-bit RAM Word Offsets (128-bit state = 4 x 32-bit words per channel)
`define WORDS_PER_CHANNEL 4
`define WORDS_PER_MATRIX  (`D_MODEL * `WORDS_PER_CHANNEL) // 16 * 4 = 64 words

`define A_REAL_START    0
`define A_IMAG_START    `WORDS_PER_MATRIX                  // 64
`define C_REAL_START    (`WORDS_PER_MATRIX * 2)             // 128
`define C_IMAG_START    (`WORDS_PER_MATRIX * 3)             // 192
`define U_START         (`WORDS_PER_MATRIX * 4)             // 256 (8 words = 16 x 16-bit)
`define Y_START         (`WORDS_PER_MATRIX * 4 + 8)         // 264 (8 words = 16 x 16-bit)

module accelerator_core #(
    LOCAL_RAM_SIZE = 32'h0000_1000
) (
    input wire clk,
    input wire resetn,
    
    input wire [3:0] accel_mem_wstrb,
    input wire [31:0] accel_mem_addr,
    input wire [31:0] accel_mem_wdata,
    output reg [31:0] accel_mem_rdata,
    output reg accel_mem_ready,

    input wire pcpi_valid,
    input wire [31:0] pcpi_insn,
    input [31:0] pcpi_rs1,
    input [31:0] pcpi_rs2,
    output reg pcpi_wr,
    output reg [31:0] pcpi_rd,
    output reg pcpi_wait,
    output reg pcpi_ready,
    input wire accel_mem_valid
);

    // 4 KB local RAM
    reg [31:0] local_memory [0:(LOCAL_RAM_SIZE/4)-1];

    reg [2:0] idx;
    reg enable;

    wire signed [127:0] h_real_out [0:`D_MODEL - 1];
    wire signed [127:0] h_imag_out [0:`D_MODEL - 1];
    wire [15:0] y_array [0:`D_MODEL - 1];

    wire [15:0] y_debug = y_array[0];

    reg ping_pong_counter = 0;

    // Port B
    genvar i;
    generate
        for (i = 0; i < `D_MODEL; i = i + 1) begin : mac_instances
            localparam A_real_offset = `A_REAL_START + `WORDS_PER_CHANNEL * i;
            localparam A_imag_offset = `A_IMAG_START + `WORDS_PER_CHANNEL * i;
            localparam C_real_offset = `C_REAL_START + `WORDS_PER_CHANNEL * i;
            localparam C_imag_offset = `C_IMAG_START + `WORDS_PER_CHANNEL * i;
            localparam u_word_offset = `U_START + (i / 2);

            reg [127:0] h_real_a;
            reg [127:0] h_imag_a;
            reg [127:0] h_real_b;
            reg [127:0] h_imag_b;

            wire [127:0] h_real = ping_pong_counter == 0 ? h_real_a : h_real_b;
            wire [127:0] h_imag = ping_pong_counter == 0 ? h_imag_a : h_imag_b;

            always @(posedge clk or negedge resetn) begin
                if (!resetn) begin
                    h_real_a <= 128'b0;
                    h_imag_a <= 128'b0;
                    h_real_b <= 128'b0;
                    h_imag_b <= 128'b0;
                end else if (pcpi_ready && idx == 3'd7) begin
                    ping_pong_counter <= ~ping_pong_counter;
                    if (ping_pong_counter == 1'b0) begin
                        // Read A and latch new state into B
                        h_real_b <= h_real_out[i];
                        h_imag_b <= h_imag_out[i];
                    end else begin
                        // Read B and latch new state into A
                        h_real_a <= h_real_out[i];
                        h_imag_a <= h_imag_out[i];
                    end
                end
            end

            s4d_complex_mac mac (
                .clk(clk),
                .resetn(resetn),

                .u(local_memory[u_word_offset][(16 * (i % 2)) +: 16]),

                .A_real_packed({local_memory[A_real_offset + 3], 
                         local_memory[A_real_offset + 2],
                         local_memory[A_real_offset + 1],
                         local_memory[A_real_offset]}),

                .A_imag_packed({local_memory[A_imag_offset + 3], 
                         local_memory[A_imag_offset + 2],
                         local_memory[A_imag_offset + 1],
                         local_memory[A_imag_offset]}),

                .C_real_packed({local_memory[C_real_offset + 3], 
                         local_memory[C_real_offset + 2],
                         local_memory[C_real_offset + 1],
                         local_memory[C_real_offset]}),

                .C_imag_packed({local_memory[C_imag_offset + 3], 
                         local_memory[C_imag_offset + 2],
                         local_memory[C_imag_offset + 1],
                         local_memory[C_imag_offset]}),

                .h_real_packed(h_real),

                .h_imag_packed(h_imag),

                .h_real_out_packed(h_real_out[i]),

                .h_imag_out_packed(h_imag_out[i]),

                .y(y_array[i]),

                .idx(idx),
                .enable(enable)
            );
        end
    endgenerate

    wire [6:0] opcode = pcpi_insn[6:0];
    wire [2:0] funct3 = pcpi_insn[14:12];
    wire ssm_step = pcpi_valid && (opcode == 7'b0001011) && (funct3 == 3'b000);
    
    // Port A
    always @(posedge clk) begin
        accel_mem_ready <= 0; // Default to 0 every cycle

        // CPU is requesting access
        if (accel_mem_valid && accel_mem_addr >= `LOCAL_RAM_BASE_ADDR) begin
            accel_mem_ready <= 1; // Acknowledge the single transaction
            
            if (accel_mem_wstrb[0]) local_memory[accel_mem_addr[11:2]][7:0]   <= accel_mem_wdata[7:0];
            if (accel_mem_wstrb[1]) local_memory[accel_mem_addr[11:2]][15:8]  <= accel_mem_wdata[15:8];
            if (accel_mem_wstrb[2]) local_memory[accel_mem_addr[11:2]][23:16] <= accel_mem_wdata[23:16];
            if (accel_mem_wstrb[3]) local_memory[accel_mem_addr[11:2]][31:24] <= accel_mem_wdata[31:24];
            
            accel_mem_rdata <= local_memory[accel_mem_addr[11:2]];
        end 
        // Accelerator internal logic is writing to Y
        else if (pcpi_ready && idx == 3'd7) begin
            for (integer k = 0; k < `D_MODEL/2; k = k + 1) begin
                local_memory[`Y_START + k] <= {y_array[2*k + 1], y_array[2*k]};
            end
        end
    end

    assign enable = !pcpi_ready && ssm_step;

    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            pcpi_wr <= 1'b0;
            pcpi_ready <= 1'b0;
            pcpi_wait <= 1'b0;
            idx <= 3'b0;
            ping_pong_counter <= 1'b0;
            accel_mem_ready <= 1'b0;
        end else if (enable) begin
            if (idx == 3'd7) begin
                pcpi_wr <= 1'b1;
                pcpi_wait <= 1'b0;
                pcpi_rd <= 32'b0; // success code
                pcpi_ready <= 1'b1;
            end else begin
                pcpi_wait <= 1'b1;
                idx <= idx + 3'b1;
            end
        end else begin
            pcpi_ready <= 1'b0;
            pcpi_wr    <= 1'b0;
            idx        <= 1'b0;
        end
    end

endmodule