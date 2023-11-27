module sck_test(
    input logic CLK100MHZ,
    input logic reset_n,
    input logic sw,
    output logic spi_cs_n
);

logic locked;
logic clock_feedback;
logic CLK50MHZ;

MMCME2_BASE#(
    .DIVCLK_DIVIDE(2),
    .CLKFBOUT_MULT_F(1),
    .CLKIN1_PERIOD(10.000)
    .CLKOUT1_DIVIDE(2)
) mmcm(
    .CLKIN1(CLK100MHZ),

    .CLKFBIN(clock_feedback),
    .CLKFBOUT(clock_feedback),

    .CLKOUT1(CLK50MHZ),

    .PWRDWN(1'b0),
    .RST(1'b0),
    .LOCKED(locked)
);

logic spi_clk;
assign spi_clk = sw ? CLK100MHZ : CLK50MHZ;

STARTUPE2 startup_cfg(
    .GSR(1'b0),
    .GTS(1'b0),
    .KEYCLEARB(1'b0),
    .PACK(1'b0),
    .PREQ(),
    .USRCCLKO(spi_clk),
    .USRCCLKTS(spi_cs_n),
    .USRDONEO(1'b1),
    .USRDONETS(1'b1)
);

endmodule
