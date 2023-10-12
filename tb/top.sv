localparam Width = rvcpu::Width;

module top (
    input logic clk,
    input logic rst,

    output logic halt
);

wire logic rd_valid;

wire rvcpu::reg_t rs1;
wire rvcpu::reg_t rs2;
wire rvcpu::reg_t rd;
wire rvcpu::data_t rd_data;
wire rvcpu::alu_flags_t flags;

wire logic stall_pc, stall_if, stall_id, stall_ex, stall_mem, stall_wb;
wire logic stallreq_id;
control ctrl(
  .clk(clk), .rst(rst),
  .halt(halt),
  .stallreq_if('b0),
  .stallreq_id(stallreq_id),
  .stallreq_ex('b0),
  .stallreq_mem('b0),
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

wire logic [Width-1:0] imem_addr;
wire logic [Width-1:0] imem_data;
wire logic imem_valid;

instruction_memory #(.Width(Width)) imem(
  .clk(clk), .address(imem_addr), .valid(imem_valid), .data(imem_data));

wire rvcpu::stage_if_t stage_if_out;
stage_if stage_if(
  .rst(rst), .pc_i(pc_if), .mem_data(imem_data),
  .mem_valid(imem_valid), .mem_addr(imem_addr),
  .out(stage_if_out)
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
  .out(stage_id_out)
);

assign halt = |{stage_id_out.is_wfi, ~stage_id_out.vld_decode};

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

wire logic mem_we;
wire logic mem_re;
wire rvcpu::addr_t mem_addr;
wire rvcpu::data_t mem_r_data;
wire rvcpu::data_t mem_w_data;
wire logic [3:0] mem_w_sel;

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
  .mem_w_sel(mem_w_sel),
  .mem_data_o(mem_w_data),
  .mem_data_i(mem_r_data),

  .out(stage_mem_out)
);
ram #(.AddrBusWidth(rvcpu::Width), .DataBusWidth(rvcpu::Width)) ram(
  .clk(clk), .rst(rst),
  .re(mem_re),
  .r_addr(mem_addr),
  .r_data(mem_r_data),
  .we(mem_we),
  .w_addr(mem_addr),
  .w_sel(mem_w_sel),
  .w_data(mem_w_data)
);

wire rvcpu::stage_mem_t stage_wb_in;
flop #(.T(rvcpu::stage_mem_t)) reg_mem_wb(
  .clk(clk), .reset(rst), .stall(stall_mem),
  .rstval('b0),
  .d(stage_mem_out),
  .q({rd, rd_valid, rd_data})
);

initial begin
  halt = 'b0;
#200 $finish;
end

always_ff @( posedge clk ) begin
    if(!rst && halt) $finish;
end

/*
wire [2:0] ready;
wire [2:0] error;

sext_tb sext_tb(.ready(ready[0]), .error(error[0]));
gen_imm_tb gen_imm_tb(.ready(ready[1]), .error(error[1]));
regfile_tb regfile_tb(.ready(ready[2]), .error(error[2]));

always @(ready, error) begin
  if(ready == '1) begin
    $display("SUCCESS");
    $finish;
  end

  if(error != '0) begin
    $display("FAILURE %b", error);
    $finish;
  end
end
*/

endmodule
