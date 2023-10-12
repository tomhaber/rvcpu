module stage_id (
    input logic rst,
    input rvcpu::pc_t pc,
    input rvcpu::opcode_t opcode,
    input rvcpu::data_t rs1_data,
    input rvcpu::data_t rs2_data,

    output rvcpu::reg_t rs1,
    output rvcpu::reg_t rs2,

    output logic stallreq,
    output rvcpu::stage_id_t out
);

assign out.rd  = opcode[11:7];
assign rs1 = opcode[19:15];
assign rs2 = opcode[24:20];

wire logic [3:0] immtype;

decoder dec(
    .opcode(opcode),
    .rs1_valid(out.rs1_valid), .rs2_valid(out.rs2_valid),
    .rd_valid(out.rd_valid),
    .imm(immtype),
    .vld_decode(out.vld_decode),
    .unit(out.unit),
    .op(out.op),
    .is_wfi(out.is_wfi)
);

wire [Width-1:0] imm;
gen_imm #(.Width(rvcpu::Width)) genimm (
    .op(opcode), .imm(imm), .immtype(immtype)
);

assign stallreq = 1'b0;
assign out.pc = pc;
assign out.imm = imm;
assign out.rs1_data = rs1_data;
assign out.rs2_data = rs2_data;
endmodule
