module stage_if (
    input logic rst,
    input rvcpu::pc_t pc_i,

    input logic mem_ready,
    input logic mem_done,
    input rvcpu::data_t mem_data,

    output logic mem_valid,
    output rvcpu::addr_t mem_addr,

    output logic stallreq,
    output rvcpu::stage_if_t out
);

assign stallreq = 1'b0;

always @ (*) begin
    if(rst) begin
        mem_valid = 'b0;
        mem_addr = 'b0;
        out.opcode = 'b0;
        out.pc = 'b0;
    end else begin
        out.pc = pc_i;
        out.opcode = mem_data;
        mem_addr = pc_i;
        mem_valid = 'b1;
    end
end
endmodule
