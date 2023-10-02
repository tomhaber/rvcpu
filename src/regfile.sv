module regfile #(
    parameter Width = 32
) (
    input logic clk,
    input logic reset,
    input rvcpu::reg_t rs1,
    input logic rs1_valid,
    input rvcpu::reg_t rs2,
    input logic rs2_valid,
    input rvcpu::reg_t rd,
    input logic rd_valid,
    input logic [Width-1:0] rd_data,
    output logic [Width-1:0] rs1_data,
    output logic [Width-1:0] rs2_data
);

reg [Width-1:0] regs[0:31];

always @(posedge clk) begin
    if(reset) begin
        for (integer i = 0; i < 31; i++) begin
            regs[i] = i;
        end
    end

    if(rd_valid && rd != 0) begin
        regs[rd - 1] <= rd_data;
    end
end

always @(*) begin
    rs1_data = (rs1_valid && rs1 != 0) ? regs[rs1 - 1] : 0;
end

always @(*) begin
    rs2_data = (rs2_valid && rs2 != 0) ? regs[rs2 - 1] : 0;
end

endmodule
