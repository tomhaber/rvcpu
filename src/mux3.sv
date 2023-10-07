module mux3
 #( parameter int unsigned Width = 8 )
  ( output logic [Width-1:0] out,
    input logic sel_a,
    input logic sel_b,
    input logic [Width-1:0] a,
    input logic [Width-1:0] b,
    input logic [Width-1:0] c);

wire logic [Width-1:0] b_c;

mux2 #(.Width(rvcpu::Width)) mux1(
    .a(b), .b(c),
    .sel_a(sel_b),
    .out(b_c)
);

mux2 #(.Width(rvcpu::Width)) mux2(
    .a(a), .b(b_c),
    .sel_a(sel_a),
    .out(out)
);
endmodule
