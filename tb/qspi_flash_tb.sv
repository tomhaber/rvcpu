`define CLK @(negedge clk)

// Testbench
module qspi_flash_tb;

logic      clk;
logic      rst;
logic      read_enable;
logic      ready;
logic[4:0] address;
logic[31:0] data_read;
logic      data_valid;

logic qspi_sck;
logic qspi_cs_n;
logic[1:0] qspi_mod;
logic[3:0] qspi_dat_o;
logic[3:0] qspi_dat_i;

qspi_flash #(
    .ClockDivider(2),
    .AddrBusWidth(5),
    .DataBusWidth(32),
    .StartupFile("src/spansion.hex")
) FLASH (
    .clk(clk), .rst(rst),
    .r_addr(address),
    .re(read_enable),
    .r_data(data_read),
    .r_data_valid(data_valid),
    .ready(ready),

    .qspi_cs_n(qspi_cs_n),
    .qspi_sck(qspi_sck),
    .qspi_mod(qspi_mod),
    .qspi_dat_i(qspi_dat_i),
    .qspi_dat_o(qspi_dat_o)
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
    read_enable = 0;
    address = 5'h1B;
    `CLK;

    $display("Read data.");
    read_enable = 1;
    `CLK;
    $display("data[%0h]: %0h", address, data_read);

    $display("Read data.");
    read_enable = 1;
    address = 5'h1B;
    `CLK;
    $display("data[%0h]: %0h", address, data_read);

    #100 $finish;
end
endmodule
