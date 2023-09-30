localparam Width = 32;

module top
  (input logic clk,
   input logic reset);

reg [Width-1:0] address;
wire [Width-1:0] opcode;
wire logic rs1_valid, rs2_valid, rd_valid;
wire logic [3:0] aluop;

wire [Width-1:0] rs1_data;
wire [Width-1:0] rs2_data;

wire rvcpu::reg_t rs1;
wire rvcpu::reg_t rs2;
wire rvcpu::reg_t rd;
reg [Width-1:0] res;
wire logic is_zero, is_negative, is_overflow;
wire logic vld_decode, is_jal, is_branch, is_wfi;
wire rvcpu::imm_type_t immtype;

instruction_memory #(.Width(Width)) imem(
  .clk(clk), .address(address), .valid('b1), .data(opcode));

decoder dec(
  .opcode(opcode),
  .rs1_valid(rs1_valid), .rs2_valid(rs2_valid),
  .rd_valid(rd_valid),
  .aluop(aluop), .imm(immtype),
  .vld_decode(vld_decode),
  .is_branch(is_branch),
  .is_jal(is_jal),
  .is_wfi(is_wfi)
);

assign rd  = opcode[11:7];
assign rs1 = opcode[19:15];
assign rs2 = opcode[24:20];

regfile #(.Width(Width)) regs (
    .clk(clk), .reset(reset),
    .rs1(rs1), .rs1_valid(rs1_valid),
    .rs2(rs2), .rs2_valid(rs2_valid),
    .rd(rd), .rd_valid(rd_valid), .rd_data(res),
    .rs1_data(rs1_data), .rs2_data(rs2_data)
);
alu #(.Width(Width)) alu(
  .op(aluop[2:0]), .invert_b(aluop[3]),
  .a(rs1_data), .b(rs2_data), .res(res),
  .is_negative(is_negative), .is_zero(is_zero), .is_overflow(is_overflow)
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
