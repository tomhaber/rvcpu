localparam Width = 32;

module top
  (input logic clk,
   input logic reset);

reg [Width-1:0] address;
wire [Width-1:0] data;
wire logic rs1_valid, rs2_valid, rw_valid;
wire logic [3:0] aluop;

wire [Width-1:0] rd1;
wire [Width-1:0] rd2;

wire rvcpu::reg_t rs1;
wire rvcpu::reg_t rs2;
wire rvcpu::reg_t rw;
reg [Width-1:0] res;
wire logic is_zero, is_negative;

instruction_memory #(.Width(Width)) imem(
  .clk(clk), .address(address), .valid('b1), .data(data));

decoder dec(
  .opcode(data),
  .rs1_valid(rs1_valid), .rs2_valid(rs2_valid),
  .rw_valid(rw_valid),
  .aluop(aluop));

regfile #(.Width(Width)) regs (
    .clk(clk), .reset(reset),
    .rs1(rs1), .rs1_valid(rs1_valid),
    .rs2(rs2), .rs2_valid(rs2_valid),
    .rw(rw), .rw_valid(rw_valid), .wval(res),
    .rd1(rd1), .rd2(rd2)
);
alu #(.Width(Width)) alu(
  .op('0),
  .a(rd1), .b(rd2), .res(res),
  .is_negative(is_negative), .is_zero(is_zero)
);

initial begin
  address = 'h0;
#50
  $finish;
end

always_ff @( posedge clk ) begin
    address <= address + 4;
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
