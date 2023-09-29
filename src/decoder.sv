module decoder (
    input logic [31:0] opcode,
    output logic rs1_valid,
    output logic rs2_valid,
    output logic rw_valid,
    output rvcpu::alu_op_t aluop
);

reg [6:0] control;
assign {rs1_valid,rs2_valid,rw_valid,aluop} = control;

always @(*) begin
    case (opcode[6:0])
        7'b0110011 : control = 7'b1110000; // R-type
        // 7'b0000011 : control <= 7'b1110000; // lw-type
        // 7'b0100011 : control <= 7'b0010000; // s-type
        // 7'b1100011 : control <= 7'b0001001; // sb-type
        // 7'b0010011 : control <= 7'b1000011; // I-type
        // 7'b1100111 : control <= 7'b1xx0100; // jalr-type
        // 7'b1101111 : control <= 7'b1xx0100; // jal-type
        default : control = 7'bxxxxxxx;
    endcase
end

endmodule
