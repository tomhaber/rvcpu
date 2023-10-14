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

always @ (*) begin
    if(rst) begin
        stall = 6'b000000;
    end else if (halt) begin
        stall = 6'b111111;
    end else if (stallreq_mem) begin
        stall = 6'b011111;
    end else if (stallreq_ex) begin
        stall = 6'b001111;
    end else if (stallreq_id) begin
        stall = 6'b000111;
    end else if (stallreq_if) begin
        stall = 6'b000011;
    end else begin
        stall = 6'b000000;
    end
end
endmodule
