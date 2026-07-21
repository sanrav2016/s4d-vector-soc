`timescale 1ns/1ps

module soc_tb;
    reg clk = 0;
    reg resetn = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile(`SIMULATION_VCD);
        $dumpvars(0, soc_tb);
        resetn = 0;
        #20 resetn = 1;
        //#600000 $finish;
    end

    // Instantiate SoC
    soc_top soc (
        .clk(clk),
        .resetn(resetn)
    );
    
endmodule