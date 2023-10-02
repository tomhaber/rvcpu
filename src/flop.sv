module flop #(
   type T = logic
) (
    input logic clk,
    input logic reset,
    input T rstval /*= 'b0*/,
    output T q,
    input T d,
    input logic stall /*= 'b0*/
);
   always_ff @(posedge clk) begin
      if(reset)
         q <= rstval;
      else if(!stall)
         q <= d;
   end
endmodule
