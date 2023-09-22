// imm[31:12] = 31:12
// imm[11:0] = 31:20
// offset[4:0;11:5] = 11-7;31:25

`timescale 1ns / 1ps

module sign_extend #(parameter InWidth = 12, parameter Width = 32)(
    input logic [InWidth-1:0] in,
    output logic [Width-1:0] ext
);

assign ext = {{(Width - InWidth){in[InWidth-1]}},in};

endmodule
