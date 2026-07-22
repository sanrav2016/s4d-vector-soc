// Multiply-accumulate unit (MAC)
// Multiplies matrix diagonal * vector element-wise and stores in y
// in 8 clock cycles (size of matrix/vector dimensions) 
// 
// Sanjay Ravishankar

module s4d_complex_mac (
    input wire clk,
    input wire resetn,

    input wire enable,
    input wire [2:0] idx,

    input wire signed [15:0] u,
    input wire signed [127:0] A_real_packed,
    input wire signed [127:0] A_imag_packed,
    input wire signed [127:0] C_real_packed,
    input wire signed [127:0] C_imag_packed,
    input wire signed [127:0] h_real_packed,
    input wire signed [127:0] h_imag_packed,
    output reg signed [127:0] h_real_out_packed,
    output reg signed [127:0] h_imag_out_packed,
    output reg signed [15:0] y
);

    wire signed [15:0] A_real [0:7];
    wire signed [15:0] A_imag [0:7];
    wire signed [15:0] C_real [0:7];
    wire signed [15:0] C_imag [0:7];
    wire signed [15:0] h_real [0:7];
    wire signed [15:0] h_imag [0:7];
    reg signed [15:0] h_real_out [0:7];
    reg signed [15:0] h_imag_out [0:7];

    genvar g_i;
    generate
        for (g_i = 0; g_i < 8; g_i = g_i + 1) begin : matrices
            assign A_real[g_i] = A_real_packed[g_i * 16 +: 16];
            assign A_imag[g_i] = A_imag_packed[g_i * 16 +: 16];
            assign C_real[g_i] = C_real_packed[g_i * 16 +: 16];
            assign C_imag[g_i] = C_imag_packed[g_i * 16 +: 16];
            assign h_real[g_i] = h_real_packed[g_i * 16 +: 16];
            assign h_imag[g_i] = h_imag_packed[g_i * 16 +: 16];
            assign h_real_out_packed[g_i * 16 +: 16] = h_real_out[g_i];
            assign h_imag_out_packed[g_i * 16 +: 16] = h_imag_out[g_i];
        end
    endgenerate

    integer i;
    reg signed [31:0] accumulate;
    reg signed [31:0] prod_real;
    reg signed [31:0] prod_imag;
    reg signed [31:0] c_prod;

    // MAC runs in 8 cycles
    always @(posedge clk) begin
        if (!resetn || !enable) begin
            y <= 16'd0;
            accumulate <= 32'b0;
        end else if (enable) begin
            prod_real = (A_real[idx] * h_real[idx]) - (A_imag[idx] * h_imag[idx]);
            prod_imag = (A_real[idx] * h_imag[idx]) + (A_imag[idx] * h_real[idx]);
            h_real_out[idx] = (prod_real >>> 12) + u;
            h_imag_out[idx] = prod_imag >>> 12;
            c_prod = (C_real[idx] * h_real_out[idx]) - (C_imag[idx] * h_imag_out[idx]);
            accumulate <= accumulate + (c_prod >>> 12);
            if (idx == 3'd7) begin
                y <= accumulate[15:0] + (c_prod >>> 12);
            end
        end
    end

endmodule