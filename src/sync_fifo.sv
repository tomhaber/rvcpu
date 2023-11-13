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

assign empty = wr_addr == rd_addr;
assign full = {~wr_addr[AddrBits], wr_addr[AddrBits-1:0]} == rd_addr;

logic passthrough;
T r_data_i;
assign r_data = passthrough ? w_data : r_data_i;

logic we_i, re_i;

sdpram #(.AddrBusWidth(AddrBits), .DataBusWidth($bits(T)), .MemSizeWords(Depth)) mem (
    .clk(clk), .rst(rst),
    .addr_a(wr_addr[AddrBits-1:0]), .we_a(we_i), .w_data_a(w_data),
    .addr_b(rd_addr[AddrBits-1:0]), .re_b(re_i), .r_data_b(r_data_i)
);

always_comb begin
    case({re, we})

    2'b00: begin
        we_i = 1'b0;
        re_i = 1'b0;
        passthrough = 1'b0;
    end

    2'b10: begin
        re_i = !empty;
        we_i = 1'b0;
        passthrough = 1'b0;
    end

    2'b01: begin
        re_i = 1'b0;
        we_i = !full;
        passthrough = 1'b0;
    end

    2'b11: begin
        if(empty || full) begin
            re_i = 1'b0;
            we_i = 1'b0;
            passthrough = 1'b1;
        end else begin
            re_i = 1'b1;
            we_i = 1'b1;
            passthrough = 1'b0;
        end
    end

    endcase
end

assign wr_addr_incr = we_i;
assign rd_addr_incr = re_i;
endmodule
