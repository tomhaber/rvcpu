/*
 Fibonacci linear-feedback shift register

 Example TapMasks:
    2:   2'b10
    3:   3'b110
    4:   4'b1100
    5:   5'b10100
    6:   6'b110000
    7:   7'b1100000
    8:   8'b10111000
    9:   9'b100010000
    10: 10'b1001000000
    11: 11'b10100000000
    12: 12'b100000101001
    13: 13'b1000000001101
    14: 14'b10000000010101
    15: 15'b110000000000000
    16: 16'b1101000000001000
    17: 17'b10010000000000000
    18: 18'b100000010000000000
    19: 19'b1000000000000100011
    20: 20'b10010000000000000000
    21: 21'b101000000000000000000
    22: 22'b1100000000000000000000
    23: 23'b10000100000000000000000
    24: 24'b111000010000000000000000
    25: 25'b1001000000000000000000000
    26: 26'b10000000000000000000100011
    27: 27'b100000000000000000000010011
    28: 28'b1001000000000000000000000000
    29: 29'b10100000000000000000000000000
    30: 30'b100000000000000000000000101001
    31: 31'b1001000000000000000000000000000
    32: 32'b10000000001000000000000000000011
*/

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
