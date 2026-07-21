`timescale 1ns / 1ps

module accelerator_tb;
    reg clk = 0;
    reg resetn = 0;
    always #5 clk = ~clk;

    initial begin
        resetn = 0;
        #20 resetn = 1; 
    end

    wire signed [15:0] u;
    wire signed [15:0] A_real [7:0];
    wire signed [15:0] A_imag [7:0];
    wire signed [15:0] C_real [7:0];
    wire signed [15:0] C_imag [7:0];
    wire signed [15:0] h_real [7:0];
    wire signed [15:0] h_imag [7:0];
    wire data_ready;
    wire signed [15:0] h_real_out [7:0];
    wire signed [15:0] h_imag_out [7:0];
    wire signed [15:0] result;

    // --- Timestep 0, Channel 0 Input ---
    assign u = 16'sd2048;

    // --- Weights for Channel 0 ---
    assign A_real[0] = 16'sd3900; assign A_real[1] = 16'sd3850;
    assign A_real[2] = 16'sd3800; assign A_real[3] = 16'sd3750;
    assign A_real[4] = 16'sd3700; assign A_real[5] = 16'sd3650;
    assign A_real[6] = 16'sd3600; assign A_real[7] = 16'sd3550;

    assign A_imag[0] = 16'sd300;  assign A_imag[1] = 16'sd400;
    assign A_imag[2] = 16'sd500;  assign A_imag[3] = 16'sd600;
    assign A_imag[4] = 16'sd700;  assign A_imag[5] = 16'sd800;
    assign A_imag[6] = 16'sd900;  assign A_imag[7] = 16'sd1000;

    assign C_real[0] = 16'sd820;  assign C_real[1] = -16'sd410;
    assign C_real[2] = 16'sd615;  assign C_real[3] = -16'sd205;
    assign C_real[4] = 16'sd1024; assign C_real[5] = -16'sd820;
    assign C_real[6] = 16'sd410;  assign C_real[7] = -16'sd615;

    assign C_imag[0] = -16'sd205; assign C_imag[1] = 16'sd615;
    assign C_imag[2] = -16'sd410; assign C_imag[3] = 16'sd820;
    assign C_imag[4] = -16'sd615; assign C_imag[5] = 16'sd1024;
    assign C_imag[6] = -16'sd205; assign C_imag[7] = 16'sd410;

    // --- Initial State (t=0) ---
    assign h_real[0] = 16'sd0; assign h_real[1] = 16'sd0;
    assign h_real[2] = 16'sd0; assign h_real[3] = 16'sd0;
    assign h_real[4] = 16'sd0; assign h_real[5] = 16'sd0;
    assign h_real[6] = 16'sd0; assign h_real[7] = 16'sd0;

    assign h_imag[0] = 16'sd0; assign h_imag[1] = 16'sd0;
    assign h_imag[2] = 16'sd0; assign h_imag[3] = 16'sd0;
    assign h_imag[4] = 16'sd0; assign h_imag[5] = 16'sd0;
    assign h_imag[6] = 16'sd0; assign h_imag[7] = 16'sd0;
    
    // Instantiate MAC
    mac_complex mac_inst (
        .clk(clk),
        .resetn(resetn),
        .u(u),
        .A_real(A_real),
        .A_imag(A_imag),
        .C_real(C_real),
        .C_imag(C_real),
        .h_real(h_real),
        .h_imag(h_imag),
        .data_ready(data_ready),
        .h_real_out(h_real_out),
        .h_imag_out(h_imag_out),
        .result(result)
    );

    always @(posedge clk) begin
        if (data_ready) begin
            $display("Result: %d", result); 
            // Should be 408
            $finish;
        end
    end

    initial begin
        #300 $finish;
    end

endmodule