`default_nettype none
module multiplier (
    input wire clk,
    input [7:0] a,
    input [7:0] b,
    output reg [7:0] c
);
    always @(posedge clk)
        c <= a * b;
endmodule
