module comparator (
    input rvcpu::alu_flags_t flags,
    input logic is_unsigned,
    output rvcpu::cmp_t cmp
);

assign cmp.equal = flags.zero;
assign cmp.less_than = (is_unsigned) ? (~flags.carry) : (flags.negative ^ flags.overflow);

endmodule
