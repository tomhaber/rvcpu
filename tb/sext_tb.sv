module sext_tb (output logic ready, output logic error);

reg [11:0] in;
wire [31:0] ext;

sign_extend #(.InWidth(12), .Width(32)) dut (
    .in(in), .ext(ext)
);

initial begin
    error = 1'b0;
    ready = 1'b0;

    in = 12'b000000000000;
#10
    in = 12'b100000000000;
#10
    in = 12'b111111111111;
#10
    ready = 1'b1;
end

endmodule : sext_tb
