module stage_id (
    input logic rst,
    input rvcpu::pc_t pc,
    input rvcpu::opcode_t opcode,
    input rvcpu::data_t rs1_data,
    input rvcpu::data_t rs2_data,

    output rvcpu::reg_t rs1,
    output rvcpu::reg_t rs2,

    output rvcpu::stage_id_t out
);

assign out.rd  = opcode[11:7];
assign rs1 = opcode[19:15];
assign rs2 = opcode[24:20];

wire logic rs1_valid;
wire logic rs2_valid;

wire logic [3:0] immtype;

decoder dec(
    .opcode(opcode),
    .rs1_valid(rs1_valid), .rs2_valid(rs2_valid),
    .rd_valid(out.rd_valid),
    .aluop(out.aluop), .imm(immtype),
    .vld_decode(out.vld_decode),
    .is_branch(out.is_branch),
    .is_jal(out.is_jal),
    .is_wfi(out.is_wfi)
);

wire [Width-1:0] imm;
gen_imm #(.Width(Width)) genimm (
    .op(opcode), .imm(imm), .immtype(immtype)
);

mux #(.Inputs(2), .Width(Width)) src_a_mux(
  .in({rs1_data, pc}), .sel({rs1_valid, ~rs1_valid}), .out(out.a)
);

mux #(.Inputs(2), .Width(Width)) src_b_mux(
  .in({rs2_data, imm}), .sel({rs2_valid, ~rs2_valid}), .out(out.b)
);
endmodule
