`timescale 1ns / 1ps

module accelerator_tb;
    reg clk = 0;
    always #5 clk = ~clk;

    wire [15:0] matrix [7:0];
    wire [15:0] vector [7:0];
    wire [15:0] result;
    wire data_ready;

    assign matrix[0] = 16'd1;
    assign matrix[1] = 16'd2;
    assign matrix[2] = 16'd3;
    assign matrix[3] = 16'd4;
    assign matrix[4] = 16'd5;
    assign matrix[5] = 16'd6;
    assign matrix[6] = 16'd7;
    assign matrix[7] = 16'd8;

    assign vector[0] = 16'd1;
    assign vector[1] = 16'd2;
    assign vector[2] = 16'd3;
    assign vector[3] = 16'd4;
    assign vector[4] = 16'd5;
    assign vector[5] = 16'd6;
    assign vector[6] = 16'd7;
    assign vector[7] = 16'd8;

    // Instantiate MAC
    mac mac_inst (
        .clk(clk),
        .matrix(matrix),
        .vector(vector),
        .result(result),
        .data_ready(data_ready)
    );

    always @(posedge clk) begin
        if (data_ready) begin
            $display("Result: %d", result);
            $finish;
        end
    end

    initial begin
        #100 $finish;
    end

endmodule