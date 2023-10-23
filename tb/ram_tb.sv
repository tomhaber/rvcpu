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
    .MemSizeBytes(32),
    .AddrBusWidth(5),
    .DataBusWidth(8)
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
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, test);

    clk = 0;
    rst = 0;
    write_enable = 0;
    read_enable = 0;
    address = 5'h1B;

    $display("Read initial data.");
    read_enable = 1;
    toggle_clk;
    $display("data[%0h]: %0h", address, data_read);

    $display("Write new data.");
    read_enable = 1;
    write_enable = 1;
    data_write = 8'hC5;
    toggle_clk;
    write_enable = 0;
    $display("data[%0h]: %0h", address, data_read);

    $display("Read new data.");
    read_enable = 1;
    toggle_clk;
    $display("data[%0h]: %0h", address, data_read);
  end

  task toggle_clk;
    begin
      #10 clk = ~clk;
      #10 clk = ~clk;
    end
  endtask
endmodule
