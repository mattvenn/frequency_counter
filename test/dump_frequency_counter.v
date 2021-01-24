module dump();
    initial begin
        $dumpfile ("frequency_counter.vcd");
        $dumpvars (0, frequency_counter);
        #1;
    end
endmodule
