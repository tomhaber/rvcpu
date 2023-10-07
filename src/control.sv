module control (
    input logic clk,
    input logic rst,
    input logic halt,
    input logic stallreq_if,
    input logic stallreq_id,
    input logic stallreq_ex,
    input logic stallreq_mem,
    output logic [5:0] stall // {WB, MEM, EX, ID, IF, PC}
);

wire any_stallreq = |{stallreq_if,stallreq_id,stallreq_ex,stallreq_mem};

reg [5:0] ctrl;
always_ff @(posedge clk) begin
    if(rst) begin
        stall <= 6'b000000;
        ctrl <= 6'b111101;
    end else if(!any_stallreq) begin
        stall <= ctrl;
        ctrl <= (ctrl << 1) | (ctrl >> ($bits(ctrl) - 1));
    end
end

endmodule
