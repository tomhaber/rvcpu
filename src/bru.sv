module bru (
    input logic [2:0] cmp_op,

    input logic is_branch,
    input logic is_jal,

    input rvcpu::cmp_t cmp,

    input rvcpu::pc_t pc,
    input rvcpu::pc_t jal_addr,
    input rvcpu::offset_t offset,

    output rvcpu::pc_t link_addr,
    output logic br_sel,
    output rvcpu::pc_t pc_br
);

logic do_branch;

always_comb begin
    case (cmp_op)
        rvcpu::bru_eq:  do_branch = cmp.equal;
        rvcpu::bru_ne:  do_branch = ~cmp.equal;
        rvcpu::bru_lt:  do_branch = cmp.less_than;
        rvcpu::bru_ge:  do_branch = ~cmp.less_than;
        rvcpu::bru_ltu: do_branch = cmp.less_than_unsigned;
        rvcpu::bru_geu: do_branch = ~cmp.less_than_unsigned;
        default:        do_branch = 'b0;
    endcase
end

wire rvcpu::pc_t pc_plus_offset = pc + {{(Width-14){1'b0}}, offset};

wire rvcpu::pc_t pc_plus_4 = pc + 'b100;
assign link_addr = pc_plus_4;

assign br_sel = (is_branch & do_branch) | is_jal;

mux2 #(.Width(rvcpu::Width)) next_pc_mux(
    .a(jal_addr), .b(pc_plus_offset),
    .sel_a(is_jal),
    .out(pc_br)
);
endmodule
