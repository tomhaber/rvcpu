module shift_in_register #(
    parameter Width = 8,
    parameter ResetValue = 1'b0
) (
    input logic clk,
    input logic rst,

    input logic serial_in,
    output logic serial_out,

    output logic [Width-1:0] parallel_output
);

logic [Width:0] sreg;

always_ff @(posedge clk or posedge rst) begin
    if(rst)
        sreg <= {(Width+1){ResetValue}};
    else
        sreg <= {serial_in, sreg[Width:1]};
end

assign parallel_output = sreg[Width:1];
assign serial_out = sreg[0];
endmodule
