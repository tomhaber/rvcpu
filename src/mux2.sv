module mux2
 #( parameter int unsigned Width = 8 )
  ( output logic [Width-1:0] out,
    input logic sel,
    input logic [Width-1:0] a,
    input logic [Width-1:0] b);

    assign out = sel ? a : b;
endmodule
