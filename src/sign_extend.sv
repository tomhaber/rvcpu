module sign_extend #(parameter InWidth = 12, parameter Width = 32)(
    input logic [InWidth-1:0] in,
    output logic [Width-1:0] ext
);

assign ext = {{(Width - InWidth){in[InWidth-1]}},in};

endmodule
