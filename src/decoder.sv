module decoder (
      input   logic[31:0]   opcode,

      output  logic vld_decode,
      output  logic rd_valid,
      output  logic rs1_valid,
      output  logic rs2_valid,
      output  logic is_branch,
      output  logic is_jal,
      output  logic is_wfi,
      output  logic[3:0]   imm,
      output  logic[3:0]   aluop
   );

   logic [12:0]   row_term;

//   0: 0000000-----------1------0110011 000000000000010
//   1: 0000000------------1-----0110011 000000000000001
//   2: 0000000----------1-------0110011 000000000000100
//   3: 0100000----------000-----0110011 111100000001000
//   4: 0100000----------101-----0110011 111100000001101
//   5: -----------------000-----1100111 111001000010000
//   6: -----------------111-----0010011 000000000000101
//   7: 0000000------------------0110011 111100000000000
//   8: -----------------1-0-----0010011 000000000000100
//   9: ------------------00-----0010011 111000000010000
//  10: -----------------11------0010011 111000000010010
//  11: ------------------0------1100011 101110001111000
//  12: -----------------1-------1100011 101110001111000

   assign row_term[0] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[13] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[1] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[12] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[2] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[14] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[3] = (~opcode[31] &  opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] & ~opcode[14] & ~opcode[13] & ~opcode[12] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[4] = (~opcode[31] &  opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[14] & ~opcode[13] &  opcode[12] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[5] = (~opcode[14] & ~opcode[13] & ~opcode[12] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[6] = ( opcode[14] &  opcode[13] &  opcode[12] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[7] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[8] = ( opcode[14] & ~opcode[12] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[9] = (~opcode[13] & ~opcode[12] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[10] = ( opcode[14] &  opcode[13] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[11] = (~opcode[13] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[12] = ( opcode[14] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);

   assign vld_decode = row_term[3] | row_term[4] | row_term[5] | row_term[7] | row_term[9] | row_term[10] | row_term[11] | row_term[12];
   assign rd_valid = row_term[3] | row_term[4] | row_term[5] | row_term[7] | row_term[9] | row_term[10];
   assign rs1_valid = row_term[3] | row_term[4] | row_term[5] | row_term[7] | row_term[9] | row_term[10] | row_term[11] | row_term[12];
   assign rs2_valid = row_term[3] | row_term[4] | row_term[7] | row_term[11] | row_term[12];
   assign is_branch = row_term[11] | row_term[12];
   assign is_jal = row_term[5];
   assign is_wfi = 1'b0;
   assign imm[3] = 1'b0;
   assign imm[2] = row_term[11] | row_term[12];
   assign imm[1] = row_term[11] | row_term[12];
   assign imm[0] = row_term[5] | row_term[9] | row_term[10] | row_term[11] | row_term[12];
   assign aluop[3] = row_term[3] | row_term[4] | row_term[11] | row_term[12];
   assign aluop[2] = row_term[2] | row_term[4] | row_term[6] | row_term[8];
   assign aluop[1] = row_term[0] | row_term[10];
   assign aluop[0] = row_term[1] | row_term[4] | row_term[6];

endmodule
