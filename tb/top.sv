
module top
  (input logic clk,
   input logic reset);

wire [2:0] ready;
wire [2:0] error;

sext_tb sext_tb(.ready(ready[0]), .error(error[0]));
gen_imm_tb gen_imm_tb(.ready(ready[1]), .error(error[1]));
regfile_tb regfile_tb(.ready(ready[2]), .error(error[2]));

always @(ready, error) begin
  if(ready == '1) begin
    $display("SUCCESS");
    $finish;
  end

  if(error != '0) begin
    $display("FAILURE %b", error);
    $finish;
  end
end

endmodule
