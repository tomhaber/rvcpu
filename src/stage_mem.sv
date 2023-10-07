module stage_mem (
    input wire rst,

    input rvcpu::pc_t pc,

    input rvcpu::reg_t rd,
    input logic rd_valid,

    input rvcpu::data_t addr,
    input rvcpu::data_t data,

    input logic is_mem,
    input rvcpu::operation_t op,

    output rvcpu::stage_mem_t out,

    // memory interface
    input rvcpu::data_t mem_data_i,

    output rvcpu::addr_t  mem_addr_o,
    output logic mem_re,
    output logic mem_we,
    output logic [3:0] mem_w_sel,
    output rvcpu::data_t mem_data_o
);

assign mem_we = is_mem & op[3];
assign mem_re = is_mem & ~op[3];

assign mem_addr_o = addr;
assign mem_data_o = data;

assign out.pc = pc;
assign out.rd = rd;
assign out.rd_valid = rd_valid;

assign mem_w_sel = 4'b1111;
// case (op[2:0])
//     :
//     default:
// endcase

mux2 #(.Width(rvcpu::Width)) data_mux(
    .a(mem_data_i), .b(data),
    .sel_a(mem_re),
    .out(out.rd_data)
);
endmodule
