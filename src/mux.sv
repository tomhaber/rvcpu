module mux
 #( parameter int unsigned Inputs = 4,
    parameter int unsigned Width = 8 )
  ( output logic [Width-1:0] out,
    input logic sel[Inputs],
    input logic [Width-1:0] in[Inputs] );

    always_comb
    begin
        out = {Width{1'b0}};
        for (int unsigned index = 0; index < Inputs; index++)
        begin
            out |= {Width{sel[index]}} & in[index];
        end
    end
endmodule
