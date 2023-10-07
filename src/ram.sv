module ram #(
    parameter AddrBusWidth = 32,
    parameter DataBusWidth = 32,
    parameter MemSizeBytes = 1024
) (
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    re,
    input  wire [AddrBusWidth-1:0] r_addr,
    input  wire                    we,
    input  wire [DataBusWidth-1:0] w_data,
    input  wire [AddrBusWidth-1:0] w_addr,
    input  wire [(DataBusWidth/8)-1:0] w_sel,
    output reg  [DataBusWidth-1:0] r_data
);

localparam WordSizeBits = $clog2(DataBusWidth) - 3;
localparam MemSizeWords = (MemSizeBytes / (DataBusWidth/8));
localparam AddrBits = $clog2(MemSizeWords);
typedef logic[AddrBits-1:0] addr_t;
reg [DataBusWidth-1:0] data[MemSizeWords -1:0];

function addr_t addr_to_index(logic [AddrBusWidth-1:0] addr);
    return addr[($clog2(MemSizeWords)+WordSizeBits-1):WordSizeBits];
endfunction

wire addr_t r_a = addr_to_index(r_addr);
wire addr_t w_a = addr_to_index(w_addr);

initial begin
    for(integer index = 0; index < MemSizeWords; index = index + 1) begin
        data[index] = $random;
    end
end

always @ (posedge clk) begin
    if (!rst && we) begin
        if(w_sel[0]) data[w_a][7:0] <= w_data[7:0];
        if(w_sel[1]) data[w_a][15:8] <= w_data[15:8];
        if(w_sel[2]) data[w_a][23:16] <= w_data[23:16];
        if(w_sel[3]) data[w_a][31:24] <= w_data[31:24];
    end
end

always @ (posedge clk) begin
    if (rst) begin
        r_data <= 0;
    end else if (re) begin
        r_data <= data[r_a];
    end else begin
        r_data <= 0;
    end
end

endmodule : ram
