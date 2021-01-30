`default_nettype none
`timescale 1ns/1ps
module seven_segment (
    input wire          load,
    input wire [3:0]    tens,
    input wire [3:0]    units,
    input wire          reset,
    input wire          clk,
    output reg [6:0]   segments,
    output reg          digit
);

    reg [3:0] tens_reg;
    reg [3:0] units_reg;
    reg [3:0] decode;

	always @(posedge clk) begin
        
        if(reset) begin

            digit <= 0;

        end else begin
        
            if(load) begin
                tens_reg    <= tens;
                units_reg   <= units;
            end

            digit <= ! digit;
            if(digit)
                decode  <= tens_reg;
            else
                decode  <= units_reg;
        end
    end

    always @(*) begin
        case(decode)
            //                7654321
            0:  segments = 7'b0111111;
            1:  segments = 7'b0000110;
            2:  segments = 7'b1011011;
            3:  segments = 7'b1001111;
            4:  segments = 7'b1100110;
            5:  segments = 7'b1101101;
            6:  segments = 7'b1111100;
            7:  segments = 7'b0000111;
            8:  segments = 7'b1111111;
            9:  segments = 7'b1100111;
            default:    
                segments = 7'b0000000;
        endcase
    end

endmodule

