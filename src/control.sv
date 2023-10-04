module control (
    input logic clk,
    input logic rst,
    input logic stallreq_if,
    input logic stallreq_id,
    input logic stallreq_ex,
    input logic stallreq_mem,
    output logic [5:0] stall // {WB, MEM, EX, ID, IF, PC}
);

reg [5:0] stallreq;

always @ (*) begin
    if (stallreq_mem) begin
        stallreq = 6'b011111;
    end else if (stallreq_ex) begin
        stallreq = 6'b001111;
    end else if (stallreq_id) begin
        stallreq = 6'b000111;
    end else if (stallreq_if) begin
        stallreq = 6'b000011;
    end else begin
        stallreq = 6'b000000;
    end
end

reg [5:0] ctrl;
always_ff @(posedge clk) begin
    if(rst) begin
        stall <= 6'b000000;
        ctrl <= 6'b111101;
    end else begin
        stall <= stallreq | ctrl;
        ctrl <= (ctrl << 1) | (ctrl >> ($bits(ctrl) - 1));
    end
end

endmodule
