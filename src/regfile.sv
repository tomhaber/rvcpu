module regfile #(
    parameter Width = 32
) (
    input logic clk,
    input logic reset,
    input rvcpu::reg_t rs1,
    input logic rs1_valid,
    input rvcpu::reg_t rs2,
    input logic rs2_valid,
    input rvcpu::reg_t rw,
    input logic rw_valid,
    input logic [Width-1:0] wval,
    output logic [Width-1:0] rd1,
    output logic [Width-1:0] rd2
);

reg [Width-1:0] regs[31];

always @(posedge clk) begin

if(reset) begin
    for (integer i = 0; i < 31; i++) begin
        regs[i] = 0;
    end
end

if(rw_valid) begin
    regs[rw - 1] <= wval;
end

if(rs1_valid) begin
    rd1 <= (rs1 != 0) ? regs[rs1 - 1] : 0;
end

if(rs2_valid) begin
    rd2 <= (rs2 != 0) ? regs[rs2 - 1] : 0;
end

end

endmodule
