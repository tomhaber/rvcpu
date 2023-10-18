module lfsr #(
    parameter Width = 31,
    parameter TapMask
) (
    input logic clk,
    input logic rst,
    input logic enable,

    input logic [Width-1:0] seed,

    output logic [Width-1:0] data
);

reg [Width-1:0] shift_reg;
reg feedback;

always @(posedge clk) begin
    if(rst)
        shift_reg <= seed;
    else if(enable)
        shift_reg <= {shift_reg[Width-2:0], feedback};
end

assign feedback = ^~{shift_reg & TapMask};
assign data = shift_reg[Width-1:0];
endmodule
