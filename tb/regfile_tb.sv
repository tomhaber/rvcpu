module regfile_tb ( output logic ready, output logic error);

rvcpu::reg_t rs1;
rvcpu::reg_t rs2;
reg rs1_valid, rs2_valid;

rvcpu::reg_t rw;
reg we;
reg [31:0] wval;

wire [31:0] rd1;
wire [31:0] rd2;

reg clk;
reg reset;

reg [31:0] expected1;
reg [31:0] expected2;

initial begin
    clk = 1'b0;
    reset = 1'b0;

    error = 1'b0;
    ready = 1'b0;
end

always #10 clk = ~clk;

regfile #(.Width(32)) dut (
    .clk(clk), .reset(reset),
    .rs1(rs1), .rs1_valid(rs1_valid),
    .rs2(rs2), .rs2_valid(rs2_valid),
    .rw(rw), .rw_valid(we), .wval(wval),
    .rd1(rd1), .rd2(rd2)
);

initial begin
    reset = 1'b1;
#20
    reset = 1'b0;

    //write 123 to reg1
    we = 1'b1;
    rw = 'd1;
    wval = 'd123;
#20
    we = 1'b0;

    // read reg1
    rs1 = 'd1;
    rs1_valid = 1'b1;
#20
    expected1 = 'd123;
    if(rd1 != expected1) begin
        $display("TESTCASE 1 FAILED %b != %b", rd1, expected1);
        error = 1'b1;
    end

    // read reg0
    rs1 = 'd0;
    rs1_valid = 1'b1;
#20
    expected1 = 'd0;
    if(rd1 != expected1) begin
        $display("TESTCASE 2 FAILED %b != %b", rd1, expected1);
        error = 1'b1;
    end

    //write 456 to reg2
    we = 1'b1;
    rw = 'd2;
    wval = 'd456;
#20
    we = 1'b0;

    // read reg1 and reg2
    rs1 = 'd2;
    rs1_valid = 1'b1;
    rs2 = 'd1;
    rs2_valid = 1'b1;
#20
    expected1 = 'd456;
    expected2 = 'd123;
    if(rd1 != expected1 || rd2 != expected2) begin
        $display("TESTCASE 3 FAILED %b != %b || %b != %b", rd1, expected1, rd2, expected2);
        error = 1'b1;
    end

#20
    ready = 1'b1;
end

endmodule : regfile_tb
