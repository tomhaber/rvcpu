module counter_tb;

logic Clock, Reset, Enable;
logic [3:0] Count;
logic overflow;

counter #(.High(9), .Initial(1), .Low(1)) cnt (
    .clk(Clock),
    .rst(Reset),
    .enable(Enable),
    .count(Count),
    .up0_down1(1'b0),
    .carry_in(1'b0),
    .carry_out(),
    .overflow(overflow),
    .load(1'b0),
    .data(0)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    Clock = 1'b0;
end

always begin
    #5 Clock = ~Clock;
end

initial begin
           Reset     = 0;
           Enable    = 0;
    #11    Reset     = 1;
    #14    Reset     = 0;
    #20    Enable    = 1;
    #10000 $finish;
end

endmodule
