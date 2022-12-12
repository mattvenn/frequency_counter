`default_nettype none
`timescale 1ns/1ps
module frequency_counter #(
    // If a module starts with #() then it is parametisable. It can be instantiated with different settings
    // for the localparams defined here. So the default is an UPDATE_PERIOD of 1200 and BITS = 12
    localparam UPDATE_PERIOD = 1200,
    localparam BITS = 12
)(
    input wire              clk,
    input wire              reset,
    input wire              signal,

    input wire [BITS-1:0]   period,
    input wire              period_load,

    output wire [6:0]       segments,
    output wire             digit
    );

    // states
    localparam STATE_COUNT  = 0;
    localparam STATE_TENS   = 1;
    localparam STATE_UNITS  = 2;

    reg [2:0] state = STATE_COUNT;

    always @(posedge clk) begin
        if(reset) begin
            
            // reset things here

        end else begin
            case(state)
                STATE_COUNT: begin
                    // count edges and clock cycles

                    // if clock cycles >= UPDATE_PERIOD then go to next state
                end

                STATE_TENS: begin
                    // count number of tens by subtracting 10 while edge counter >= 10

                    // then go to next state
                end

                STATE_UNITS: begin
                    // what is left in edge counter is units

                    // update the display

                    // go back to counting
                end

                default:
                    state           <= STATE_COUNT;

            endcase
        end
    end

endmodule
