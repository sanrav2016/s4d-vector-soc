`timescale 1ns / 1ps

module accelerator_tb;
    reg clk = 0;
    reg resetn = 0;
    always #5 clk = ~clk;

    initial begin
        resetn = 0;
        #20 resetn = 1; 
    end

    wire signed [15:0] matrix [7:0];
    wire signed [15:0] vector [7:0];
    wire signed [15:0] result;
    wire data_ready;

    // Multiply by 4096 to convert to Q4.12 quantization
    assign matrix[0] = 16'sd2130;  // 0.52 * 4096
    assign matrix[1] = -16'sd1680; // -0.41 * 4096
    assign matrix[2] = 16'sd1843;  // 0.45 * 4096
    assign matrix[3] = -16'sd1106; // -0.27 * 4096
    assign matrix[4] = 16'sd4014;  // 0.98 * 4096
    assign matrix[5] = -16'sd1393; // -0.34 * 4096
    assign matrix[6] = 16'sd1720;  // 0.42 * 4096
    assign matrix[7] = 16'sd3482;  // 0.85 * 4096

    assign vector[0] = 16'sd2130;  // 0.52 * 4096
    assign vector[1] = -16'sd1680; // -0.41 * 4096
    assign vector[2] = 16'sd1843;  // 0.45 * 4096
    assign vector[3] = -16'sd1106; // -0.27 * 4096
    assign vector[4] = 16'sd4014;  // 0.98 * 4096
    assign vector[5] = -16'sd1393; // -0.34 * 4096
    assign vector[6] = 16'sd1720;  // 0.42 * 4096
    assign vector[7] = 16'sd3482;  // 0.85 * 4096
    
    // Instantiate MAC
    mac mac_inst (
        .clk(clk),
        .resetn(resetn),
        .matrix(matrix),
        .vector(vector),
        .result(result),
        .data_ready(data_ready)
    );

    always @(posedge clk) begin
        if (data_ready) begin
            $display("Result: %d", result); 
            // Should be 11014
            // 11014 / 4096 ~= 2.88
            $finish;
        end
    end

    initial begin
        #300 $finish;
    end

endmodule