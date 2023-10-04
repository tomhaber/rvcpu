localparam Width = rvcpu::Width;

module top
  (input logic clk,
   input logic rst);

rvcpu::pc_t address;
wire logic rs1_valid, rs2_valid, rd_valid;

wire rvcpu::reg_t rs1;
wire rvcpu::reg_t rs2;
wire rvcpu::reg_t rd;
wire rvcpu::data_t rd_data;
wire rvcpu::alu_flags_t flags;

wire logic stall_pc, stall_if, stall_id, stall_ex, stall_mem, stall_wb;
wire logic stallreq_id;
control ctrl(
  .clk(clk), .rst(rst),
  .stallreq_if('b0),
  .stallreq_id(stallreq_id),
  .stallreq_ex('b0),
  .stallreq_mem('b0),
  .stall({stall_wb, stall_mem, stall_ex, stall_id, stall_if, stall_pc})
);

wire rvcpu::pc_t pc_if;
flop #(.T(rvcpu::pc_t)) reg_pc (
  .clk(clk), .stall(stall_pc), .reset(rst),
  .rstval('b0),
  .d(address), .q(pc_if));

wire logic [Width-1:0] imem_addr;
wire logic [Width-1:0] imem_data;
wire logic imem_valid;

instruction_memory #(.Width(Width)) imem(
  .clk(clk), .address(imem_addr), .valid(imem_valid), .data(imem_data));

wire rvcpu::stage_if_t stage_if_out;
stage_if stage_if(
  .rst(rst), .pc_i(pc_if), .mem_data(imem_data),
  .mem_valid(imem_valid), .mem_addr(imem_addr),
  .out(stage_if_out)
);

wire rvcpu::stage_if_t stage_id_in;
flop #(.T(rvcpu::stage_if_t)) reg_if_id(
  .clk(clk), .stall(stall_if), .reset(rst),
  .rstval('b0),
  .d(stage_if_out), .q(stage_id_in)
);

wire rvcpu::stage_id_t stage_id_out;
wire rvcpu::data_t rs1_data;
wire rvcpu::data_t rs2_data;

stage_id stage_id(
  .rst(rst),
  .pc(stage_id_in.pc), .opcode(stage_id_in.opcode),
  .rs1_data(rs1_data), .rs2_data(rs2_data),
  .rs1(rs1), .rs2(rs2),
  .out(stage_id_out)
);

regfile #(.Width(Width)) regs (
  .clk(clk), .reset(rst),
  .rs1(rs1), .rs1_valid(rs1_valid),
  .rs2(rs2), .rs2_valid(rs2_valid),
  .rd(rd), .rd_valid(rd_valid), .rd_data(rd_data),
  .rs1_data(rs1_data), .rs2_data(rs2_data)
);

wire rvcpu::stage_id_t stage_ex_in;
flop #(.T(rvcpu::stage_id_t)) reg_id_ex(
  .clk(clk), .stall(stall_id), .reset(rst),
  .rstval('b0),
  .d(stage_id_out), .q(stage_ex_in)
);

wire rvcpu::data_t res;
alu #(.Width(Width)) alu(
  .op(stage_ex_in.aluop[2:0]), .invert_b(stage_ex_in.aluop[3]),
  .a(stage_ex_in.a), .b(stage_ex_in.b), .res(res),
  .flags(flags)
);

wire rvcpu::cmp_t cmp;
comparator compa(
  .flags(flags), .is_unsigned('b0), .cmp(cmp)
);

wire rvcpu::stage_ex_t stage_wb_in;
flop #(.T(rvcpu::stage_ex_t)) reg_ex_wb (
  .clk(clk), .reset(rst), .stall(stall_ex),
  .rstval('b0),
  .d({stage_ex_in.pc, res}),
  .q(stage_wb_in)
);

// bru #(.Width(Width)) bru(
//   .is_branch(stage_ex_in.is_branch),
//   .is_jal(stage_ex_in.is_jal),
//   .pc(stage_if_in.is_jal),
// );
wire rvcpu::pc_t next_pc = stage_wb_in.pc + 'b100;

flop #(.T(rvcpu::stage_wb_t)) reg_wb (
  .clk(clk), .reset(rst), .stall(stall_wb),
  .rstval('b0),
  .d({next_pc, stage_ex_in.rd, stage_wb_in.res, stage_ex_in.rd_valid}),
  .q({address, rd, rd_data, rd_valid})
);

initial begin
  address = 'h0;
#50
  $finish;
end

always_ff @( posedge clk ) begin
    // address <= address + 4;
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
