`default_nettype none
`timescale 1ns/1ps
module frequency_counter(
    input wire          clk,
    input wire          reset,
    input wire          signal,

    output wire [6:0]   segments,
    output wire         digit
    );

    // see calculations.py
    localparam UPDATE_PERIOD = 1200; 
    localparam BITS = 11;

    reg q0, q1, q2;                 // metastability on input and a delay to detect edges
    reg [6:0] edge_counter;         // how many edges have arrived in the counting period
    reg [BITS-1:0] clk_counter;     // keep track of clocks in the counting period

    wire leading_edge_detect = q1 & (q2 != q1);
    reg [3:0] tens, units;
    reg update_digits;
    
    always @(posedge clk) begin
        q0 <= signal;
        q1 <= q0;
        q2 <= q1;
    end

    localparam STATE_COUNT  = 0;
    localparam STATE_TENS   = 1;
    localparam STATE_UNITS   = 2;

    reg [2:0] state = STATE_COUNT;

    always @(posedge clk) begin
        if(reset) begin
            clk_counter     <= 0;
            edge_counter    <= 0;
            state           <= STATE_COUNT;
            tens            <= 0;
            units           <= 0;
            update_digits   <= 0;
        end else begin
            case(state)
                STATE_COUNT: begin
                    update_digits   <= 1'b0;
                    clk_counter <= clk_counter + 1;
                    if(leading_edge_detect)
                        edge_counter <= edge_counter + 1;
                    if(clk_counter >= UPDATE_PERIOD) begin
                        clk_counter <= 0;
                        tens        <= 0;
                        units       <= 0;
                        state       <= STATE_TENS;
                        end
                    end

                STATE_TENS: begin
                    if(edge_counter >= 10) begin
                        edge_counter <= edge_counter - 10;
                        tens <= tens + 1;
                    end else
                        state <= STATE_UNITS;
                    end

                STATE_UNITS: begin
                    units           <= edge_counter;
                    update_digits   <= 1'b1;
                    edge_counter    <= 0;
                    state           <= STATE_COUNT;
                    end

                default:
                    state           <= STATE_COUNT;

            endcase

        end
    end

    seven_segment seven_segment0 (.clk(clk), .reset(reset), .load(update_digits), .tens(tens), .units(units), .segments(segments), .digit(digit));

endmodule


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
                decode  <= tens;
            else
                decode  <= units;
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
