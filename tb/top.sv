localparam Width = rvcpu::Width;

module top (
    input logic clk,
    input logic rst,

    output logic halt
);

rvcpu::pc_t address;
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
flop #(.T(rvcpu::pc_t)) reg_pc (
  .clk(clk), .stall(stall_pc), .reset(rst),
  .rstval('b0),
  .d(address), .q(pc_if));

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
  .a(stage_ex_in.a),
  .b(stage_ex_in.b),
  .offset(stage_ex_in.offset),
  .unit(stage_ex_in.unit),
  .op(stage_ex_in.op),
  .out(stage_ex_out)
);

wire rvcpu::data_t res;
wire rvcpu::stage_ex_t stage_mem_in;
flop #(.T(rvcpu::stage_ex_t)) reg_ex_mem (
  .clk(clk), .reset(rst), .stall(stall_ex),
  .rstval('b0),
  .d(stage_ex_out),
  .q(stage_mem_in)
);

wire rvcpu::stage_mem_t stage_mem_out = {
  stage_mem_in.pc,
  stage_mem_in.rd,
  stage_mem_in.rd_valid,
  stage_mem_in.res
};
// ram #(.AddrBusWidth(Width), .DataBusWidth(Width)) ram(
//   .clk(clk), .rst(rst),
//   .r_addr(stage_mem_in.res),
//   .w_addr(stage_mem_in.res),
//   .re('b0), .we('b0),
//   .w_data(rd_data)
// );

wire rvcpu::stage_mem_t stage_wb_in;
flop #(.T(rvcpu::stage_mem_t)) reg_mem_wb(
  .clk(clk), .reset(rst), .stall(stall_mem),
  .rstval('b0),
  .d(stage_mem_out),
  .q(stage_wb_in)
);

flop #(.T(rvcpu::stage_wb_t)) reg_wb (
  .clk(clk), .reset(rst), .stall(stall_wb),
  .rstval('b0),
  .d({stage_wb_in.pc, stage_ex_in.rd, stage_wb_in.rd_data, stage_ex_in.rd_valid}),
  .q({address, rd, rd_data, rd_valid})
);

initial begin
  address = 'h0;
  halt = 'b0;
// #100
//   $finish;
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
