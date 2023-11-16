module top (
    input logic CLK100MHZ,
//    input logic CLK12MHZ,

    input logic reset_n,

    input logic sw_raw,
    output logic[5:2] led,

    output logic[7:0] ja,

    input logic uart_txd_in,
    output logic uart_rxd_out
);

logic clk;

logic clock_feedback, clocks_locked;
clk_converter clocks(
    .clk_in1(CLK100MHZ), .reset(1'b0),
    .clk(clk),
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

logic clk_cnt;
clock_divider #(.Width(14)) clk_div(
    .clk(clk), .rst(rst), .enable(sw), .clk_out(clk_cnt)
);

logic [5:0] addr;
counter #(.Width(6)) cnt(
    .clk(clk), .rst(rst),
    .up0_down1(1'b0), .enable(clk_cnt),
    .load(1'b0), .load_count(0),
    .carry_in(1'b0), .carry_out(), .overflow(),
    .count(addr)
);

logic [3:0] pattern_data;
sdpram #(
    .AddrBusWidth(6),
    .DataBusWidth(4),
    .MemoryInitFile("pattern.mem")
) patterns (
    .clk(clk), .rst(rst),
    .addr_a(), .we_a(1'b0), .w_data_a(),
    .addr_b(addr), .re_b(1'b1), .r_data_b(pattern_data)
);

logic uart_ready;
logic data_valid = 1'b1;

logic [7:0] data;
assign data = {4'h4, pattern_data};

uart_tx #(.ClockDivider(10)) tx (
    .clk(clk), .rst(rst),
    .data_in(data), .data_in_valid(data_valid),
    .out_bit(uart_rxd_out), .ready(uart_ready)
);

logic[7:0] received_data;
logic data_received, break_recv, error;

uart_rx#(.ClockDivider(10)) rx (
    .clk(clk), .rst(rst),
    .input_bit(uart_txd_in),
    .data_out(received_data), .data_valid(data_received),
    .break_received(break_recv), .error(error)
);

assign led = pattern_data;
assign ja = {data_received, error, uart_txd_in, uart_rxd_out, uart_ready, sw, clk_cnt, clk};

endmodule
