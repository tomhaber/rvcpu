module clock_divider_tb;

logic Clock, Reset;
logic clk_out, clk_pos, clk_neg;

clock_divider #(.Divisor(2)) cnt (
    .clk(Clock),
    .rst(Reset),
    .clk_neg(clk_neg),
    .clk_pos(clk_pos),
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
    #55   Reset     = 1;
    #20   Reset     = 0;
    #10000 $finish;
end

endmodule
