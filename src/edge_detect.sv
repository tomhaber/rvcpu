module edge_detect(
    input clk,
    input rst,
    input data_in,
    output data_changed
);

logic data_in_q;

always_ff @(posedge clk) begin
    if(rst) begin
        data_in_q <= 0;
    end
    else begin
        data_in_q <= data_in;
    end
end

assign data_changed = (data_in != data_in_q);
endmodule
