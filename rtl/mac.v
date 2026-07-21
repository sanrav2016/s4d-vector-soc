// Multiply-accumulate unit (MAC)
// Multiplies matrix diagonal * vector element-wise and stores in result
// in 8 clock cycles (size of matrix/vector dimensions) 
// 
// Sanjay Ravishankar

module mac_complex (
    input wire clk,
    input wire resetn,
    input wire signed [15:0] u,
    input wire signed [15:0] A_real [7:0],
    input wire signed [15:0] A_imag [7:0],
    input wire signed [15:0] C_real [7:0],
    input wire signed [15:0] C_imag [7:0],
    input wire signed [15:0] h_real [7:0],
    input wire signed [15:0] h_imag [7:0],
    output reg data_ready,
    output reg signed [15:0] h_real_out [7:0],
    output reg signed [15:0] h_imag_out [7:0],
    output reg signed [15:0] result
);

    integer i;
    reg [3:0] idx;
    reg signed [31:0] accumulate;
    reg signed [31:0] prod_real;
    reg signed [31:0] prod_imag;
    reg signed [31:0] c_prod;

    // MAC runs in 8 cycles
    always @(posedge clk) begin
        if (!resetn) begin
            data_ready <= 1'b0;
            idx <= 3'b0;
            result <= 16'd0;
            accumulate <= 32'b0;
        end else if (!data_ready) begin
            prod_real = (A_real[idx] * h_real[idx]) - (A_imag[idx] * h_imag[idx]);
            prod_imag = (A_real[idx] * h_imag[idx]) + (A_imag[idx] * h_real[idx]);
            h_real_out[idx] = (prod_real >>> 12) + u;
            h_imag_out[idx] = prod_imag >>> 12;
            c_prod = (C_real[idx] * h_real_out[idx]) - (C_imag[idx] * h_imag_out[idx]);
            accumulate <= accumulate + (c_prod >>> 12);
            if (idx == 3'd7) begin
                result <= accumulate[15:0] + (c_prod >>> 12);
                data_ready <= 1'b1;
            end else begin
                idx <= idx + 3'b1;
            end
        end
    end

endmodule