module clk_converter(
    input clk_in1,
    input reset,

    output clk,

    output clkfb_out,
    input clkfb_in,

    output locked
);

MMCME2_BASE #(
    .DIVCLK_DIVIDE(1),
    .CLKFBOUT_MULT_F(10),
    .CLKIN1_PERIOD(10.000),
    .CLKOUT1_DIVIDE(125)
) mmcm (
    .CLKIN1(clk_in1),

    .CLKFBIN(clkfb_in),
    .CLKFBOUT(clkfb_out),

    .CLKOUT1(clk),

    .PWRDWN(1'b0),
    .RST(reset),
    .LOCKED(locked)
);

endmodule
