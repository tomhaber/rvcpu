module prisel #(
    parameter NumPorts,
    type T,
    type O
) (
    input logic clk,
    input logic rst,
    input logic enable,

    input logic[NumPorts-1:0] inb,
    input T ins[NumPorts],
    output O outs[NumPorts],

    output logic valid,
    output T sel_i,
    input O sel_o
);

logic [$clog2(NumPorts)-1:0] idx;
assign valid = |inb && enable;

always_comb begin
    idx = 0;
    for(integer k = 0; k < NumPorts; ++k) begin
        if(inb[k]) begin
            idx = k[$clog2(NumPorts)-1:0];
        end
    end
end

always_ff @(clk) begin
    if(valid) begin
        sel_i <= ins[idx];
        outs[idx] <= sel_o;
    end
end

// localparam PortBits = $clog2(NumPorts);
// logic[PortBits-1:0] token, next_token;
// logic update_token =  |inb & enable;

// assign next_token = update_token ? {token[PortBits-2:0], token[PortBits-1]} : token;
// always_ff @( posedge clk ) begin
//     token <= next_token;
// end
endmodule
