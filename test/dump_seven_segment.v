module dump();
    initial begin
        $dumpfile ("seven_segment.vcd");
        $dumpvars (0, seven_segment);
        #1;
    end
endmodule
