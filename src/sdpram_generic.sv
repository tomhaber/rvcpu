module sdpram_generic #(
    parameter MemoryInitFile = "none",
    parameter MemoryPrimitive = "",
    parameter MemoryAddrCollision = "",
    parameter ReadLatency = 1,
    parameter AddrBusWidth = 32,
    parameter DataBusWidth = 32,
    parameter MemSizeWords = 0
) (
    input  logic                    clk,
    input  logic                    rst,

    input  logic                    we_a,
    input  logic [AddrBusWidth-1:0] addr_a,
    input  logic [DataBusWidth-1:0] w_data_a,

    input  logic                    re_b,
    input  logic [AddrBusWidth-1:0] addr_b,
    output logic [DataBusWidth-1:0] r_data_b
);

localparam MemSizeWords_i = (MemSizeWords > 0) ? MemSizeWords : (2**AddrBusWidth);
localparam AddrBits = $clog2(MemSizeWords_i);

if(AddrBits > AddrBusWidth)
    $error($sformatf("Illegal values for parameters AddrBusWidth (%0d) and MemSizeWords (%0d)", AddrBusWidth, MemSizeWords));

(* ram_style            = MemoryPrimitive *)
(* rw_addr_collision    = MemoryAddrCollision *)
reg [DataBusWidth-1:0] data[MemSizeWords_i -1:0];

typedef logic[AddrBits-1:0] addr_t;
function addr_t addr_to_index(logic [AddrBusWidth-1:0] addr);
    return addr[AddrBits-1:0];
endfunction

addr_t a, b;
assign a = addr_to_index(addr_a);
assign b = addr_to_index(addr_b);

initial begin
    if(MemoryInitFile != "none") begin
        $readmemh(MemoryInitFile, data);
    end
end

always @ (posedge clk) begin
    if (!rst && we_a) begin
        data[a] <= w_data_a;
    end
end

genvar i;
generate
    if(ReadLatency > 0) begin
        for(i = 0; i < ReadLatency; ++i) begin : reg_outs
            logic [DataBusWidth-1:0] data_i;
            logic [DataBusWidth-1:0] data_r;
            always_ff @(posedge clk) data_r <= data_i;
        end : reg_outs

        assign reg_outs[0].data_i = (re_b & !rst) ? data[b] : 0;
        for(i = 1; i < ReadLatency; ++i) begin
            assign reg_outs[i].data_i = reg_outs[i-1].data_r;
        end

        assign r_data_b = reg_outs[ReadLatency-1].data_r;
    end else begin
        assign r_data_b = (re_b & !rst) ? data[b] : 0;
    end
endgenerate
endmodule : sdpram_generic
