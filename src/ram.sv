module ram #(
    parameter AddrBusWidth = 32,
    parameter DataBusWidth = 32
) (
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    re,
    input  wire [AddrBusWidth-1:0] r_addr,
    input  wire                    we,
    input  wire [DataBusWidth-1:0] w_data,
    input  wire [AddrBusWidth-1:0] w_addr,
    input  wire [DataBusWidth-1:0] w_size,
    output reg  [DataBusWidth-1:0] r_data
);

reg [DataBusWidth-1:0] data[(1<<AddrBusWidth)-1:0];

always @ (posedge clk) begin
    if (!rst && we) begin
        if(w_size[0]) data[w_addr][7:0] <= w_data[7:0];
        if(w_size[1]) data[w_addr][15:8] <= w_data[15:8];
        if(w_size[2]) data[w_addr][23:16] <= w_data[23:16];
        if(w_size[3]) data[w_addr][31:24] <= w_data[31:24];
    end
end

always @ (posedge clk) begin
    if (rst) begin
        r_data <= 0;
    end else if (re) begin
        r_data <= data[r_addr];
    end else begin
        r_data <= 0;
    end
end

endmodule : ram
