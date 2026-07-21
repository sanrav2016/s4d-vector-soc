module mac (
    input wire clk,
    input wire [15:0] matrix [7:0],
    input wire [15:0] vector [7:0],
    output reg data_ready = 0,
    output reg [15:0] result = 16'd0
);

    localparam IDLE  = 2'b00;
    localparam COMPUTE  = 2'b01;
    localparam DONE  = 2'b10;

    reg [1:0] state = IDLE;

    integer i;

    always @(posedge clk) begin
        if (!data_ready) begin
            integer sum;
            sum = result;
            for (i = 0; i < 8; i = i + 1) begin
                sum = sum + ((matrix[i] * vector[i]) >>> 12);
            end
            result <= sum;
            data_ready <= 1'b1;
        end
    end

endmodule