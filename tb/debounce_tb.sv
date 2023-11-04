module top();

logic clk;
logic sig_a, sig_b;
logic [1:0] sig_clean;

debouncer #(.Count(2), .Period(10)) dbnc (
    .clk(clk),
    .sig_i({sig_b, sig_a}),
    .sig_o(sig_clean)
);

initial begin
    clk = 0;
    forever begin
        #5 clk = 1'b1;
        #5 clk = 1'b0;
    end
end

initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, test);

    sig_a = 1'b0;
    sig_b = 1'b0;

    #10 sig_a = 1'b1;
    #20 sig_b = 1'b1;
    #30 sig_b = 1'b0;
    #40 sig_a = 1'b0;
    #50 sig_b = 1'b1;
    #50 sig_a = 1'b1;
    #200 $finish;
end

endmodule
