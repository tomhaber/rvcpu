module comparator (
    input rvcpu::alu_flags_t flags,
    output rvcpu::cmp_t cmp
);

assign cmp.equal = flags.zero;
assign cmp.less_than = flags.negative ^ flags.overflow;
assign cmp.less_than_unsigned = ~flags.carry;

endmodule
