module dump();
    initial begin
        $dumpfile ("edge_detect.vcd");
        $dumpvars (0, edge_detect);
        #1;
    end
endmodule
