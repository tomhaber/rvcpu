module riscv_core(
   output rvcpu::addr_t imem_addr,
   output logic imem_valid,
   output rvcpu::addr_t mem_addr,
   output rvcpu::data_t mem_w_data,
   output logic [3:0] mem_w_mask,
   output logic mem_we,
   output logic mem_re,
   output logic halted,

   input logic clk,
   input logic rst,
   input rvcpu::opcode_t imem_data,
   input rvcpu::data_t mem_r_data
);

wire logic rd_valid;

wire rvcpu::reg_t rs1;
wire rvcpu::reg_t rs2;
wire rvcpu::reg_t rd;
wire rvcpu::data_t rd_data;
wire rvcpu::alu_flags_t flags;

wire logic stall_pc, stall_if, stall_id, stall_ex, stall_mem, stall_wb;
wire logic stallreq_if, stallreq_id, stallreq_ex, stallreq_mem;
control ctrl(
  .clk(clk), .rst(rst),
  .halt(halted),
  .stallreq_if(stallreq_if),
  .stallreq_id(stallreq_id),
  .stallreq_ex(stallreq_ex),
  .stallreq_mem(stallreq_mem),
  .stall({stall_wb, stall_mem, stall_ex, stall_id, stall_if, stall_pc})
);

wire rvcpu::pc_t pc_if;
wire rvcpu::pc_t pc_br;
wire logic br_sel;
wire rvcpu::pc_t pc_plus_4 = pc_if + 'b100;
wire rvcpu::pc_t pc_next;

mux2 #(.Width(rvcpu::Width)) pc_mux(
    .a(pc_br), .b(pc_plus_4),
    .sel_a(br_sel),
    .out(pc_next)
);

flop #(.T(rvcpu::pc_t)) reg_pc (
  .clk(clk), .stall(stall_pc), .reset(rst),
  .rstval('b0),
  .d(pc_next), .q(pc_if));

wire logic imem_ready;
wire logic imem_done;

wire rvcpu::stage_if_t stage_if_out;
stage_if stage_if(
  .rst(rst), .pc_i(pc_if), .mem_data(imem_data),
  .mem_valid(imem_valid), .mem_addr(imem_addr),
  .mem_ready(imem_ready), .mem_done(imem_done),
  .stallreq(stallreq_if), .out(stage_if_out)
);

wire rvcpu::stage_if_t stage_id_in;
flop #(.T(rvcpu::stage_if_t)) reg_if_id(
  .clk(clk), .stall(stall_if), .reset(rst),
  .rstval({rvcpu::RESET_PC, rvcpu::NOP}),
  .d(stage_if_out), .q(stage_id_in)
);

wire rvcpu::stage_id_t stage_id_out;
wire rvcpu::data_t rs1_data;
wire rvcpu::data_t rs2_data;

stage_id stage_id(
  .rst(rst),
  .pc(stage_id_in.pc), .opcode(stage_id_in.opcode),
  .rs1_data(rs1_data), .rs2_data(rs2_data),
  .rs1(rs1), .rs2(rs2),
  .stallreq(stallreq_id), .out(stage_id_out)
);

assign halted = |{stage_id_out.is_wfi, ~stage_id_out.vld_decode};

regfile #(.Width(Width)) regs (
  .clk(clk), .reset(rst),
  .rs1(rs1), .rs1_valid('b1),
  .rs2(rs2), .rs2_valid('b1),
  .rd(rd), .rd_valid(rd_valid), .rd_data(rd_data),
  .rs1_data(rs1_data), .rs2_data(rs2_data)
);

wire rvcpu::stage_id_t stage_ex_in;
flop #(.T(rvcpu::stage_id_t)) reg_id_ex(
  .clk(clk), .stall(stall_id), .reset(rst),
  .rstval('b0),
  .d(stage_id_out), .q(stage_ex_in)
);

wire rvcpu::stage_ex_t stage_ex_out;
stage_ex stage_ex(
  .rst(rst),
  .pc(stage_ex_in.pc),
  .rd(stage_ex_in.rd),
  .rd_valid(stage_ex_in.rd_valid),
  .rs1_data(stage_ex_in.rs1_data),
  .rs1_valid(stage_ex_in.rs1_valid),
  .rs2_data(stage_ex_in.rs2_data),
  .rs2_valid(stage_ex_in.rs2_valid),
  .imm(stage_ex_in.imm),
  .unit(stage_ex_in.unit),
  .op(stage_ex_in.op),

  .br_sel(br_sel),
  .pc_br(pc_br),

  .stallreq(stallreq_ex),
  .out(stage_ex_out)
);

wire rvcpu::data_t res;
wire rvcpu::stage_ex_t stage_mem_in;
flop #(.T(rvcpu::stage_ex_t)) reg_ex_mem (
  .clk(clk), .reset(rst), .stall(stall_ex),
  .rstval('b0),
  .d(stage_ex_out),
  .q({stage_mem_in})
);

wire rvcpu::stage_mem_t stage_mem_out;
stage_mem stage_mem(
  .rst(rst),
  .rd(stage_mem_in.rd),
  .rd_valid(stage_mem_in.rd_valid),

  .data(stage_mem_in.data),
  .addr(stage_mem_in.addr),

  .is_mem(stage_mem_in.is_mem),
  .op(stage_mem_in.op),

  // ram wiring
  .mem_addr_o(mem_addr),
  .mem_re(mem_re),
  .mem_we(mem_we),
  .mem_w_sel(mem_w_mask),
  .mem_data_o(mem_w_data),
  .mem_data_i(mem_r_data),

  .stallreq(stallreq_mem),
  .out(stage_mem_out)
);

wire rvcpu::stage_mem_t stage_wb_in;
flop #(.T(rvcpu::stage_mem_t)) reg_mem_wb(
  .clk(clk), .reset(rst), .stall(stall_mem),
  .rstval('b0),
  .d(stage_mem_out),
  .q({rd, rd_valid, rd_data})
);

endmodule
