`timescale 1ns / 1ps

module sext_tb ();

reg [11:0] in;
wire [31:0] ext;

sign_extend #(.InWidth(12), .Width(32)) dut (
    .in(in), .ext(ext)
);

initial begin
    in = 12'b000000000000;
#10
    in = 12'b100000000000;
#10
    in = 12'b111111111111;
#10
    $finish;
end

endmodule : sext_tb
