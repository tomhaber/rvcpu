localparam Width = rvcpu::Width;

// `define WITH_RAM

module top (
    input logic clk,
    input logic rst,
    input logic irq,

`ifndef WITH_RAM
    output logic [Width-1:0] mem_addr,
    input logic [Width-1:0] mem_r_data,
    output logic [Width-1:0] mem_w_data,
    output logic [3:0] mem_w_mask,
`endif

    output logic exception,
    output logic wfi
);

wire logic [Width-1:0] imem_addr;
wire logic [Width-1:0] imem_data;
wire logic imem_valid, imem_ready, imem_done;

instruction_memory #(.Width(Width)) imem(
  .clk(clk), .address(imem_addr),
  .valid(imem_valid), .data(imem_data),
  .ready(imem_ready), .done(imem_done)
);

wire logic mem_we;
wire logic mem_re;
`ifdef WITH_RAM
wire rvcpu::addr_t mem_addr;
wire rvcpu::data_t mem_r_data;
wire rvcpu::data_t mem_w_data;
wire logic [3:0] mem_w_mask;

ram #(.AddrBusWidth(Width), .DataBusWidth(Width)) ram(
  .clk(clk), .rst(rst),
  .re(mem_re),
  .r_addr(mem_addr),
  .r_data(mem_r_data),
  .we(mem_we),
  .w_addr(mem_addr),
  .w_sel(mem_w_mask),
  .w_data(mem_w_data)
);
`endif

riscv_core core(
  .clk(clk), .rst(rst),
  .imem_addr(imem_addr),
  .imem_data(imem_data),
  .imem_valid(imem_valid),
  .mem_addr(mem_addr),
  .mem_w_data(mem_w_data),
  .mem_r_data(mem_r_data),
  .mem_w_mask(mem_w_mask),
  .mem_re(mem_re), .mem_we(mem_we),
  .exception(exception),
  .irq(irq), .wfi(wfi)
);

initial begin
#200 $finish;
end

always_ff @( posedge clk ) begin
    if(!rst & wfi)  $finish;
    if(!rst & exception)  $stop;
end

/*
wire [2:0] ready;
wire [2:0] error;

sext_tb sext_tb(.ready(ready[0]), .error(error[0]));
gen_imm_tb gen_imm_tb(.ready(ready[1]), .error(error[1]));
regfile_tb regfile_tb(.ready(ready[2]), .error(error[2]));

always @(ready, error) begin
  if(ready == '1) begin
    $display("SUCCESS");
    $finish;
  end

  if(error != '0) begin
    $display("FAILURE %b", error);
    $finish;
  end
end
*/

endmodule
