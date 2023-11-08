module adder #(
    parameter Width = 8
) (
    input logic up0_down1,
    input logic [Width-1:0] a,
    input logic [Width-1:0] b,

    input logic carry_in,
    output logic carry_out,

    output logic overflow,
    output logic [Width-1:0] sum
);

logic [Width-1:0] carry_in_selected, eff_b, neg_off;

always_comb begin
    carry_in_selected = (up0_down1 == 1'b0) ? {{(Width-1){1'b0}}, carry_in} : {(Width){carry_in}};
    eff_b = (up0_down1 == 1'b0) ? b : ~b;
    neg_off = (up0_down1 == 1'b0) ? {Width{1'b0}} : {{(Width-1){1'b0}}, 1'b1};
    {carry_out, sum} = a + eff_b + neg_off + carry_in_selected;
end

always_comb begin
    overflow = (a[Width-1] == eff_b[Width-1]) && (a[Width-1] != sum[Width-1]);
end

endmodule
