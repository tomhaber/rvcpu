module alu #(
    parameter Width = 32
) (
    input rvcpu::alu_op_t op,
    input logic [Width-1:0] a,
    input logic [Width-1:0] b,
    output logic [Width-1:0] res,
    output rvcpu::alu_flags_t flags
);

logic [Width-1:0] eff_b;
logic [Width:0] sum;

logic [$clog2(Width)-1:0] shamt;

wire logic invert_b = op[3];

always_comb begin
    eff_b = (invert_b) ? ~b : b;
    sum = a + eff_b + {{Width{'0}},invert_b};
    shamt = b[$clog2(Width)-1:0];

    case (op)
        rvcpu::alu_and:  res = a & b;
        rvcpu::alu_or:   res = a | b;
        rvcpu::alu_sll:  res = a << shamt;
        rvcpu::alu_srl:  res = a >> shamt;
        rvcpu::alu_sra:  res = $signed(a) >>> shamt;
        rvcpu::alu_add, rvcpu::alu_sub:  res = sum[Width-1:0];
        rvcpu::alu_xor:  res = a ^ b;
        rvcpu::alu_slt:  res = 'bx;
        default: res = b;
    endcase

    flags.zero = res == '0;
    flags.overflow = (a[7] == eff_b[7]) && (a[7] != res[7]);
    flags.negative = res[7];
    flags.carry = sum[Width];
end

endmodule
