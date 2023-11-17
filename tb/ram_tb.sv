`define CLK @(negedge clk)

// Testbench
module test;

reg        clk;
reg        rst;
reg  [7:0] data_write;
reg        write_enable;
reg        read_enable;
reg  [4:0] address;
wire [7:0] data_read;

sdpram #(
    .MemSizeWords(32),
    .AddrBusWidth(5),
    .DataBusWidth(8),
    .MemoryPrimitive("block"),
    .MemoryAddrCollision("no"),
    .ReadLatency(1)
) RAM (
    .clk(clk), .rst(rst),
    .addr_a(address),
    .we_a(write_enable),
    .w_data_a(data_write),
    .addr_b(address),
    .re_b(read_enable),
    .r_data_b(data_read)
);

initial begin
  clk = 0;
  forever #10 clk = ~clk;
end

initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, test);

    rst = 0;
    write_enable = 0;
    read_enable = 0;
    data_write = 8'hFF;
    address = 5'h1B;
    `CLK;

    $display("Read initial data.");
    read_enable = 1;
    `CLK;
    $display("data[%0h]: %0h", address, data_read);

    $display("Write new data.");
    read_enable = 1;
    write_enable = 1;
    data_write = 8'hC5;
    repeat(2) `CLK;
    write_enable = 0;
    data_write = 8'hXX;
    address = 5'hXX;
    $display("data[%0h]: %0h", address, data_read);
    repeat(5) `CLK;

    $display("Read new data.");
    read_enable = 1;
    address = 5'h1B;
    `CLK;
    $display("data[%0h]: %0h", address, data_read);

    #100 $finish;
end
endmodule
