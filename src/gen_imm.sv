module gen_imm #(
    parameter Width = 32
) (
    input logic [Width-1:0] op,
    rvcpu::imm_type_t immtype,
    output logic [Width-1:0] imm
);

always @(*) begin
    case (immtype)
        rvcpu::alu_imm: imm = {{(Width - 12){op[31]}}, op[31:20]};
        rvcpu::load_offset: imm = {{(Width - 12){op[31]}}, op[31:20]};
        rvcpu::store_offset: imm = {{(Width - 12){op[31]}}, op[31:25], op[11:7]};
        rvcpu::uimm: imm = {{(Width - 5){1'b0}}, op[19:15]};
        rvcpu::jalr_offset: imm = {{(Width - 12){op[31]}}, op[31:20]};
        rvcpu::br_offset: imm = {{(Width - 13){op[31]}}, op[31], op[7], op[30:25], op[11:8], 1'b0};
        rvcpu::jal_offset: imm = {{(Width - 21){op[31]}}, op[31], op[19:12], op[20], op[30:21], 1'b0};
        rvcpu::ui_imm: imm = {op[31:12], 12'b0};
        default: imm = {Width{1'h0}};
    endcase
end

endmodule
