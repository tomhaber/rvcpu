module shift_out_register #(
    parameter Width = 8
) (
    input logic clk,
    input logic rst,

    input logic serial_in,
    output logic serial_out,

    input logic parallel_load,
    input logic enable,
    input logic [Width-1:0] parallel_input
);

logic [Width:0] sreg;

always_ff @(posedge clk or posedge rst) begin
    if(rst)
        sreg <= {(Width+1){serial_in}};
    else if(parallel_load)
        sreg <= {parallel_input, serial_in};
    else if(enable)
        sreg <= {serial_in, sreg[Width:1]};
end

assign serial_out = sreg[0];
endmodule
