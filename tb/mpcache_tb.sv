localparam AddrWidth = 5;
localparam CacheBusWidth = 8;
localparam MemBusWidth = 8;

module top ();

reg clk;
reg rst;

reg [AddrWidth-1:0] address[2];
wire logic[CacheBusWidth-1:0] r_data[2];
reg [CacheBusWidth-1:0] w_data[2];
wire logic ready[2];
wire logic r_data_valid[2];
reg read_enable[2];
reg write_enable[2];

wire logic [AddrWidth-1:0] mem_addr;
reg [MemBusWidth-1:0] mem_r_data;
wire [MemBusWidth-1:0] mem_w_data;
reg mem_ready = 1'b0;
reg mem_r_data_valid = 1'b0;
wire logic mem_re;
wire logic mem_we;

mpcache #(
    .NumPorts(2),
    .AddrBusWidth(AddrWidth),
    .CacheBusWidth(CacheBusWidth),
    .MemBusWidth(MemBusWidth),
    .N(512)
) cache (
    .clk(clk), .rst(rst),
    .mem_addr(mem_addr),
    .mem_r_data(mem_r_data),
    .mem_w_data(mem_w_data),
    .mem_ready(mem_ready),
    .mem_r_data_valid(mem_r_data_valid),
    .mem_re(mem_re),
    .mem_we(mem_we),
    .port_addr(address),
    .port_r_data(r_data), .port_w_data(w_data),
    .port_re(read_enable), .port_we(write_enable),
    .port_r_data_valid(r_data_valid),
    .port_ready(ready)
);

integer misses = 0;
integer count = 0;
integer fp;
integer temp;

initial begin
    string fname;
    if(!$value$plusargs("trace=%s", fname))
        fname = "traces/gcc.txt";

    $dumpfile("dump.vcd");
    $dumpvars(1, test);

    fp = $fopen(fname, "r");
    clk = 0;
    read_enable = {0, 0};
    write_enable = {0, 0};
    misses = 0;
    count = 0;

    rst = 1;
    #10 rst = 0;

    write_enable[1] = 0;
    read_enable[1] = 1;
    address[1] = 5'h1B;

    $display("Read initial data.");
    toggle_clk;
    $display("data[%0h]: %0h", address, r_data);

    $display("Write new data.");
    write_enable[1] = 1;
    w_data[1] = 8'hC5;
    toggle_clk;
    write_enable[1] = 0;

    $display("Read new data.");
    toggle_clk;
    $display("data[%0h]: %0h", address, r_data);
end

task toggle_clk;
  begin
    #10 clk = ~clk;
    #10 clk = ~clk;
  end
endtask

endmodule
