module top (
    input logic CLK100MHZ,
    input logic CLK12MHZ,

    input logic reset_n,

    input logic sw_raw,
    output logic[5:2] led,

    output logic[7:0] ja,

    input logic uart_txd_in,
    output logic uart_rxd_out
);

logic clk, clk_ddr, clock_feedback, clocks_locked;
clk_converter clocks(
    .clk_in1(CLK100MHZ), .reset(1'b0),
    .clk_main(clk),
    .clk_ddr(clk_ddr), .clk_ddr_180deg(),
    .clkfb_in(clock_feedback),
    .clkfb_out(clock_feedback),
    .locked(clocks_locked)
);

logic rst;
reset_sync rst_sync(
    .clk(clk), .reset_in(~reset_n), .reset_out(rst)
);

logic sw;
logic sw_changed;

debouncer #(.Period(100)) debounce(
    .clk(clk), .sig_i(sw_raw), .sig_o(sw)
);

edge_detect ed(
    .clk(clk), .rst(rst), .data_in(sw), .data_changed(sw_changed)
);
endmodule
