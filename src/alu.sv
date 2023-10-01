module alu #(
    parameter Width = 32
) (
    input rvcpu::alu_op_t op,
    input logic [Width-1:0] a,
    input logic [Width-1:0] b,
    input logic invert_b,
    output logic [Width-1:0] res,
    output rvcpu::alu_flags_t flags
);

logic [Width-1:0] eff_b;
logic [Width:0] sum;

logic [$clog2(Width)-1:0] shamt;

always_comb begin
    eff_b = (invert_b) ? ~b : b;
    sum = a + eff_b + {Width{invert_b}};
    shamt = eff_b[$clog2(Width)-1:0];

    case (op)
        rvcpu::alu_and:  res = a & eff_b;
        rvcpu::alu_or:   res = a | eff_b;
        rvcpu::alu_sll:  res = a << shamt;
        rvcpu::alu_srl:  res = a >> shamt;
        rvcpu::alu_sra:  res = $signed(a) >>> shamt;
        rvcpu::alu_add:  res = sum[Width-1:0];
        rvcpu::alu_xor:  res = a ^ eff_b;
        rvcpu::alu_slt:  res = 'bx;
        // rvcpu::alu_pass: res = a;
    endcase

    flags.zero = res == '0;
    flags.overflow = (a[7] == eff_b[7]) && (a[7] != res[7]);
    flags.negative = res[7];
    flags.carry = sum[Width];
end

endmodule
