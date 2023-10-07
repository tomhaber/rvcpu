module stage_ex (
    input wire rst,
    input rvcpu::pc_t pc,
    input rvcpu::reg_t rd,
    input logic rd_valid,
    input rvcpu::data_t a,
    input rvcpu::data_t b,
    input rvcpu::offset_t offset,
    input rvcpu::unit_t unit,
    input rvcpu::operation_t op,

    output rvcpu::stage_ex_t out
);

wire logic is_alu = unit == rvcpu::unit_alu;
wire logic is_branch = op[3] & ~is_alu;
wire logic is_jal = ~op[3] & ~is_alu;

wire logic invert_b = op[3];
wire rvcpu::alu_op_t alu_op = is_alu ? rvcpu::alu_op_t'(op[2:0]) : rvcpu::alu_add;

wire rvcpu::data_t res;

wire rvcpu::alu_flags_t flags;
alu #(.Width(rvcpu::Width)) alu(
  .op(alu_op), .invert_b(invert_b),
  .a(stage_ex_in.a), .b(stage_ex_in.b), .res(res),
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
  .offset(offset),

  .link_addr(link_addr),
  .next_pc(out.pc)
);

mux2 #(.Width(rvcpu::Width)) next_pc_mux(
    .a(res), .b(link_addr),
    .sel_a(is_alu),
    .out(out.res)
);
endmodule
