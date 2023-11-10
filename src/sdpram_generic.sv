module sdpram_generic #(
    parameter MemoryInitFile = "none",
    parameter MemoryPrimitive = "",
    parameter MemoryAddrCollision = "",
    parameter AddrBusWidth = 32,
    parameter DataBusWidth = 32,
    parameter MemSizeWords = 0
) (
    input  wire                    clk,
    input  wire                    rst,

    input  wire                    we_a,
    input  wire [AddrBusWidth-1:0] addr_a,
    input  wire [DataBusWidth-1:0] w_data_a,

    input  wire                    re_b,
    input  wire [AddrBusWidth-1:0] addr_b,
    output reg  [DataBusWidth-1:0] r_data_b
);

localparam MemSizeWords_i = (MemSizeWords > 0) ? MemSizeWords : (2**AddrBusWidth);
localparam AddrBits = $clog2(MemSizeWords_i);

initial $display("words %0d %d %d", MemSizeWords_i, AddrBusWidth, DataBusWidth);

if(AddrBits > AddrBusWidth)
    $error($sformatf("Illegal values for parameters AddrBusWidth (%0d) and MemSizeWords (%0d)", AddrBusWidth, MemSizeWords));

typedef logic[AddrBits-1:0] addr_t;

(* ram_style            = MemoryPrimitive *)
(* rw_addr_collision    = MemoryAddrCollision *)
reg [DataBusWidth-1:0] data[MemSizeWords -1:0];

function addr_t addr_to_index(logic [AddrBusWidth-1:0] addr);
    return addr[AddrBits-1:0];
endfunction

wire addr_t a = addr_to_index(addr_a);
wire addr_t b = addr_to_index(addr_b);

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

always @ (posedge clk) begin
    if (rst) begin
        r_data_b <= 0;
    end else begin
        r_data_b <= re_b ? data[b] : 0;
    end
end

endmodule : sdpram_generic
