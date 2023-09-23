module gen_imm_tb (output logic ready, output logic error);

reg [31:0] op;
rvcpu::imm_type_t immt;
wire [31:0] imm;
reg [31:0] expected;

gen_imm #(.Width(32)) dut (
    .op(op), .imm(imm), .immtype(immt)
);

initial begin
    error = 1'b0;
    ready = 1'b0;

    op = 32'hd5050513;
    immt = rvcpu::alu_imm;
    expected = -32'd688;
#10
    op = 32'hc4e7b783;
    immt = rvcpu::load_offset;
    expected = -32'd946;
#10
    op = 32'h748000ef;
    immt = rvcpu::jal_offset;
    expected = 32'h748;
#10
    op = 32'h00f10e23;
    immt = rvcpu::store_offset;
    expected = 32'd28;
#10
    op = 32'h02c80e63;
    immt = rvcpu::br_offset;
    expected = 32'h3C;
#10
    op = 32'h30047773;
    immt = rvcpu::uimm;
    expected = 32'd8;
#10
    ready = 1'b1;
end

always @(imm) begin
   if(imm != expected) begin
      $display("TESTCASE FAILED (op %h - %b) %b != %b", op, op, imm, expected);
      error <= 1'b1;
   end
end

endmodule : gen_imm_tb
