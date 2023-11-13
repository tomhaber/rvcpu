module spram_generic #(
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
    input  logic                    re,
    input  logic [AddrBusWidth-1:0] addr,
    input  logic                    we,
    input  logic [DataBusWidth-1:0] w_data,
    output logic [DataBusWidth-1:0] r_data
);

localparam MemSizeWords_i = (MemSizeWords > 0) ? MemSizeWords : (2**AddrBusWidth);
localparam AddrBits = $clog2(MemSizeWords);

if(AddrBits > AddrBusWidth)
    $error($sformatf("Illegal values for parameters AddrBusWidth (%0d) and MemSizeWords (%0d)", AddrBusWidth, MemSizeWords));

(* ram_style            = MemoryPrimitive *)
(* rw_addr_collision    = MemoryAddrCollision *)
reg [DataBusWidth-1:0] data[MemSizeWords_i -1:0];

typedef logic[AddrBits-1:0] addr_t;
function addr_t addr_to_index(logic [AddrBusWidth-1:0] addr);
    return addr[AddrBits-1:0];
endfunction

logic addr_t a;
assign a = addr_to_index(addr);

initial begin
    if(MemoryInitFile != "none") begin
        $readmemh(MemoryInitFile, data);
    end
end

always_ff @(posedge clk) begin
    if (!rst && we) begin
        data[a] <= w_data;
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

        assign reg_outs[0].data_i = data[b];
        for(i = 1; i < ReadLatency; ++i) begin
            assign reg_outs[i].data_i = reg_outs[i-1].data_r;
        end

        assign r_data_b = reg_outs[ReadLatency-1].data_r;
    end else begin
        assign r_data_b = data[b];
    end
endgenerate
endmodule : spram_generic
