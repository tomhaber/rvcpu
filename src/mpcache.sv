module mpcache #(
    parameter NumPorts = 2,
    parameter AddrBusWidth = 32,
    parameter CacheBusWidth = 32,
    parameter MemBusWidth = 64,
    parameter N = 256 // number of cache blocks
) (
    input logic clk,
    input logic rst,

    input logic[AddrBusWidth-1:0] port_addr[NumPorts],
    output logic[CacheBusWidth-1:0] port_r_data[NumPorts],
    input logic[CacheBusWidth-1:0] port_w_data[NumPorts],
    // input logic[(CacheBusWidth/8)-1:0] w_sel[NumPorts],
    input logic port_re[NumPorts],
    input logic port_we[NumPorts],
    output reg port_ready[NumPorts],
    output reg port_r_data_valid[NumPorts],

    // memory interface
    output reg [AddrBusWidth-1:0] mem_addr,
    input logic [MemBusWidth-1:0] mem_r_data,
    output logic [MemBusWidth-1:0] mem_w_data,
    // output logic [(MemBusWidth/8)-1:0] mem_w_sel,
    output logic mem_re,
    output logic mem_we,
    input logic mem_ready,
    input logic mem_r_data_valid
);

localparam PortBits = $clog2(NumPorts);
logic [PortBits-1:0] active_port;
logic [CacheBusWidth-1:0] port_rsp_data;
logic rsp_valid;

genvar i;
generate
    for(i = 0; i < NumPorts; ++i) begin : port_state
        wire prev_pending;

        wire pending = port_re[i] | port_we[i];
        assign port_r_data[i] = port_rsp_data;
        assign port_r_data_valid[i] = rsp_valid & active_port == i;

        wire [PortBits-1:0] next_active;
        wire [PortBits-1:0] active_port = (pending & ~prev_pending) ? i : next_active;
    end : port_state

    assign port_state[0].prev_pending = 1'b0;
    for(i = 1; i < NumPorts; ++i) begin
        assign port_state[i].prev_pending = port_state[i-1].prev_pending | port_state[i-1].pending;
    end

    assign port_state[NumPorts-1].next_active = 0;
    for(i = 0; i < NumPorts-1; ++i) begin
        assign port_state[i].next_active = port_state[i+1].active_port;
    end
endgenerate

assign active_port = port_state[0].active_port;
endmodule
