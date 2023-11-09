module skidbuffer #(
    type T = logic
) (
    input logic clk,
    input logic rst,

    input logic valid_i,
    input T data_i,
    output logic ready_o,

    output logic valid_o,
    output T data_o,
    input logic ready_i
);

T data_b = ($bits(data_i))'(0);
logic valid_b = 1'b0;

always_ff @(posedge clk) begin : buffer_valid
    if(rst) begin
        valid_b <= 1'b0;
    end else if((valid_i && ready_o) && (valid_o && !ready_i)) begin
        // incoming data, but the output is not ready
        valid_b <= 1'b1;
    end else if(ready_i) begin
        valid_b <= 1'b0;
    end
end

always_ff @(posedge clk) begin : buffer_data
    if(rst) begin
        data_b <= 0;
    end else if(valid_i && !ready_o) begin
        data_b <= data_i;
    end
end

assign ready_o = !valid_b;

assign valid_o = (!rst) && (valid_i || valid_b);
assign data_o = valid_b ? data_b : data_i;
endmodule
