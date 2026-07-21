// Multiply-accumulate unit (MAC)
// Multiplies matrix diagonal * vector element-wise and stores in result
// in 8 clock cycles (size of matrix/vector dimensions) 
// 
// Sanjay Ravishankar

module mac (
    input wire clk,
    input wire resetn,
    input wire signed [15:0] matrix [7:0],
    input wire signed [15:0] vector [7:0],
    output reg data_ready,
    output reg signed [15:0] result
);

    integer i;
    reg [3:0] idx;
    reg signed [31:0] accumulate;

    // MAC runs in 8 cycles
    always @(posedge clk) begin
        if (!resetn) begin
            data_ready <= 1'b0;
            idx <= 3'b0;
            result <= 16'd0;
            accumulate <= 32'b0;
        end else if (!data_ready) begin
            accumulate = accumulate + (matrix[idx] * vector[idx]);
            if (idx == 3'd7) begin
                result <= accumulate >>> 12;
                data_ready <= 1'b1;
            end else begin
                idx <= idx + 3'b1;
            end
        end
    end

endmodule