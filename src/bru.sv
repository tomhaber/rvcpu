module bru (
    input logic [2:0] cmp_op,

    input logic is_branch,
    input logic is_jal,

    input rvcpu::cmp_t cmp,

    input rvcpu::pc_t pc,
    input rvcpu::pc_t jal_addr,
    input rvcpu::offset_t offset,

    output rvcpu::pc_t link_addr,
    output rvcpu::pc_t next_pc
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

wire rvcpu::pc_t pc_plus_4 = pc + 'b100;
wire rvcpu::pc_t pc_plus_offset = pc + {{(Width-14){1'b0}}, offset};

assign link_addr = pc_plus_4;

wire rvcpu::pc_t br_addr;
mux2 #(.Width(rvcpu::Width)) br_mux(
    .a(pc_plus_offset), .b(pc_plus_4),
    .sel_a(is_branch & do_branch),
    .out(br_addr)
);

mux2 #(.Width(rvcpu::Width)) next_pc_mux(
    .a(jal_addr), .b(br_addr),
    .sel_a(is_jal),
    .out(next_pc)
);
endmodule
