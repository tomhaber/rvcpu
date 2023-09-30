module alu #(
    parameter Width = 32
) (
    input rvcpu::alu_op_t op,
    input logic [Width-1:0] a,
    input logic [Width-1:0] b,
    input logic invert_b,
    output logic [Width-1:0] res,
    output logic is_negative,
    output logic is_zero,
    output logic is_overflow
);

logic [Width-1:0] eff_b;

always_comb begin
    eff_b = (invert_b) ? ~b : b;

    case (op)
        rvcpu::alu_and:  res = a & b;
        rvcpu::alu_or:   res = a | b;
        rvcpu::alu_sll:  res = a << b[4:0];
        rvcpu::alu_srl:  res = a >> b[4:0];
        rvcpu::alu_sra:  res = $signed(a) >>> b[4:0];
        rvcpu::alu_add:  res = a + b;
        rvcpu::alu_xor:  res = a ^ b;
        rvcpu::alu_pass: res = a;
    endcase

    is_zero = res == '0;
    is_overflow = (a[7] == eff_b[7]) && (a[7] != res[7]);
    is_negative = res[7];
end

endmodule
