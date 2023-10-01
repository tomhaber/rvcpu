module flop #(parameter Width = 32) (
    input logic clk,
    input logic reset,
    input logic [Width-1:0] rstval /*= 'b0*/,
    output logic [Width-1:0] q,
    input logic [Width-1:0] d,
    input logic stall /*= 'b0*/
);
   always_ff @(posedge clk) begin
      if(reset)
         q <= rstval;
      else if(!stall)
         q <= d;
   end
endmodule
