module sync_fifo #(
    type T = logic,
    parameter LogDepth = 4
) (
    input logic clk,
    input logic rst,

    input logic we,
    input T w_data,
    output logic full,

    input logic re,
    output T r_data,
    output logic empty
);

localparam Depth = 2**LogDepth;
localparam AddrBits = LogDepth;
localparam AddrZero = (AddrBits + 1)'(0);
logic [AddrBits:0] wr_addr, rd_addr; // extra wrap bit
logic wr_addr_incr, rd_addr_incr;

counter #(.Width(AddrBits+1)) write_address (
    .clk(clk), .rst(rst),
    .up0_down1(1'b0), .enable(wr_addr_incr),
    .load(rst), .load_count(AddrZero),
    .carry_in(), .carry_out(), .overflow(),
    .count(wr_addr)
);

counter #(.Width(AddrBits+1)) read_address (
    .clk(clk), .rst(rst),
    .up0_down1(1'b0), .enable(rd_addr_incr),
    .load(rst), .load_count(AddrZero),
    .carry_in(), .carry_out(), .overflow(),
    .count(rd_addr)
);

wire logic same_addr = (wr_addr[AddrBits-1:0] == rd_addr[AddrBits-1:0]);
assign empty = same_addr && (wr_addr[AddrBits] == rd_addr[AddrBits]);
assign full = same_addr && (wr_addr[AddrBits] != rd_addr[AddrBits]);

wire logic we_i = we && !full;
wire logic re_i = re && !empty;

sdpram #(.AddrBusWidth(AddrBits), .DataBusWidth($bits(T)), .MemSizeWords(Depth)) mem (
    .clk(clk), .rst(rst),
    .addr_a(wr_addr[AddrBits-1:0]), .we_a(we_i), .w_data_a(w_data),
    .addr_b(rd_addr[AddrBits-1:0]), .re_b(re_i), .r_data_b(r_data)
);

assign wr_addr_incr = we_i;
assign rd_addr_incr = re_i;

endmodule
