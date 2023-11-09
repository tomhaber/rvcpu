module spram_generic #(
    parameter MemoryInitFile = "none",
    parameter MemoryPrimitive = "",
    parameter MemoryAddrCollision = "",
    parameter AddrBusWidth = 32,
    parameter DataBusWidth = 32,
    parameter MemSizeWords = 1024
) (
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    re,
    input  wire [AddrBusWidth-1:0] addr,
    input  wire                    we,
    input  wire [DataBusWidth-1:0] w_data,
    output reg  [DataBusWidth-1:0] r_data
);

localparam AddrBits = $clog2(MemSizeWords);

if(AddrBits > AddrBusWidth)
    $error($sformatf("Illegal values for parameters AddrBusWidth (%0d) and MemSizeWords (%0d)", AddrBusWidth, MemSizeWords));

typedef logic[AddrBits-1:0] addr_t;

(* ram_style            = MemoryPrimitive *)
(* rw_addr_collision    = MemoryAddrCollision *)
reg [DataBusWidth-1:0] data[MemSizeWords -1:0];

function addr_t addr_to_index(logic [AddrBusWidth-1:0] addr);
    return addr[AddrBits-1:0];
endfunction

wire addr_t a = addr_to_index(addr);

initial begin
    if(MemoryInitFile != "none") begin
        $readmemh(MemoryInitFile, data);
    end
end

always @ (posedge clk) begin
    if (!rst && we) begin
        data[a] <= w_data;
    end
end

always @ (posedge clk) begin
    if (rst) begin
        r_data <= 0;
    end else if (re) begin
        r_data <= data[a];
    end else begin
        r_data <= 0;
    end
end

endmodule : spram_generic
