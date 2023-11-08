module clock_divider_tb;

logic Clock, Reset, Enable;
logic clk_out;

clock_divider #(.Width(4), .Divisor(4)) cnt (
    .clk(Clock),
    .rst(Reset),
    .enable(Enable),
    .clk_out(clk_out)
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
    #200   Enable    = 0;
    #220   Enable    = 1;
    #55   Reset     = 1;
    #20   Reset     = 0;
    #10000 $finish;
end

endmodule
