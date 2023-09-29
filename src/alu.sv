module alu #(
    parameter Width = 32
) (
    input rvcpu::alu_op_t op,
    input logic [Width-1:0] a,
    input logic [Width-1:0] b,
    output logic [Width-1:0] res,
    output logic is_negative,
    output logic is_zero
);

always_comb begin
case (op)
    4'b0111: res = a & b;
    4'b0110: res = a | b;
    4'b0001: res = a << b[4:0];
    4'b0101: res = a >> b[4:0];
    4'b1101: res = $signed(a) >>> b[4:0];
    4'b0000: res = a + b;
    4'b1000: res = a - b;
    4'b0100: res = a ^ b;
    default: res = '0;
endcase
end

assign is_zero = res == '0;
endmodule
