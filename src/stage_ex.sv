module stage_ex (
    input wire rst,
    input rvcpu::pc_t pc,
    input rvcpu::reg_t rd,
    input logic rd_valid,
    input rvcpu::data_t rs1_data,
    input logic rs1_valid,
    input rvcpu::data_t rs2_data,
    input logic rs2_valid,
    input rvcpu::data_t imm,
    input rvcpu::unit_t unit,
    input rvcpu::operation_t op,

    output logic br_sel,
    output rvcpu::pc_t pc_br,
    output rvcpu::stage_ex_t out
);

wire logic is_alu = unit == rvcpu::unit_alu;
wire logic is_bru = unit == rvcpu::unit_bru;
wire logic is_mem = unit == rvcpu::unit_mem;

wire logic is_branch = op[3] & is_bru;
wire logic is_jal = ~op[3] & is_bru;

wire rvcpu::alu_op_t alu_op = is_alu ? rvcpu::alu_op_t'(op) :
                        (is_branch ? rvcpu::alu_sub : rvcpu::alu_add);

wire rvcpu::data_t res;
wire rvcpu::data_t a, b;

mux2 #(.Width(rvcpu::Width)) src_a_mux(
  .a(rs1_data), .b(pc), .sel_a(rs1_valid), .out(a)
);

mux2 #(.Width(rvcpu::Width)) src_b_mux(
  .a(rs2_data), .b(imm), .sel_a(rs2_valid & ~is_mem), .out(b)
);

wire rvcpu::alu_flags_t flags;
alu #(.Width(rvcpu::Width)) alu(
  .op(alu_op),
  .a(a), .b(b), .res(res),
  .flags(flags)
);

wire rvcpu::cmp_t cmp;
comparator compa(
  .flags(flags), .cmp(cmp)
);

wire rvcpu::pc_t link_addr;
bru bru(
  .cmp_op(op[2:0]),
  .is_branch(is_branch),
  .is_jal(is_jal),
  .cmp(cmp),
  .pc(pc),
  .jal_addr(res),
  .offset(rvcpu::data2offset(imm)),

  .link_addr(link_addr),
  .br_sel(br_sel),
  .pc_br(pc_br)
);

mux3 #(.Width(rvcpu::Width)) data_mux(
    .a(res), .b(rs2_data), .c(link_addr),
    .sel_a(is_alu), .sel_b(is_mem),
    .out(out.data)
);

assign out.rd_valid = rd_valid;
assign out.rd = rd;
assign out.is_mem = is_mem;
assign out.op = op;
assign out.addr = res;

endmodule
