`default_nettype none
`timescale 1ns/1ps
module frequency_counter #(
    // see calculations.py
    localparam UPDATE_PERIOD = 1200,
    localparam BITS = 12
)(
    input wire          clk,
    input wire          reset_n,
    input wire          signal,

    /* input clock is 12MHz, can't change it on the FPGA
    input wire [BITS-1:0]   period,
    input wire          period_load,
    */

    output wire [6:0]   segments,
    output wire         digit
    );

    wire reset = !reset_n;

    reg [BITS-1:0] update_period;

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

    always @(posedge clk) begin
        if(reset)
            update_period   <= UPDATE_PERIOD;
    /* not needed on FPGA
        else if(period_load)
            update_period   <= period;
    */
    end

    localparam STATE_COUNT  = 0;
    localparam STATE_TENS   = 1;
    localparam STATE_UNITS  = 2;

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
                    if(clk_counter >= update_period) begin
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
