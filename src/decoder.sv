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

   logic [22:0]   row_term;

//   0: 00010000010100000000000001110011 100000100000000
//   1: 010000-----------101-----00-0011 000000000001000
//   2: 0000000-----------1------0110-11 000000000000010
//   3: 0000000------------1-----0110-11 000000000000001
//   4: 0100000----------000-----0110011 111100000001000
//   5: 0000000----------1-------0-10-11 000000000000100
//   6: 0100000----------101-----0110011 111100000001101
//   7: 0000000------------------0110011 111100000000000
//   8: 000000------------01-----00-0011 111000000010001
//   9: -----------------111-----0010-11 000000000000001
//  10: 0-0000-----------1-1-----0010011 111000000010101
//  11: -----------------000-----1100111 111001000010000
//  12: -----------------1-0-----0010-11 000000000000100
//  13: ------------------0------1100011 000010000111000
//  14: -------------------------1101111 110001001010000
//  15: -----------------0-0-----0100011 101100001000000
//  16: -----------------00-------100011 101100001000000
//  17: -----------------0-0-----0000011 111000000110000
//  18: -----------------11------0010011 111000000010110
//  19: -------------------------0-10111 110000010000000
//  20: -----------------1-------1100011 101110001111000
//  21: ------------------00-----00-0011 111000000010000
//  22: ------------------0------0000011 111000000110000

   assign row_term[0] = (~opcode[31] & ~opcode[30] & ~opcode[29] &  opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] & ~opcode[24] & ~opcode[23] &  opcode[22] & ~opcode[21] &  opcode[20] & ~opcode[19] & ~opcode[18] & ~opcode[17] & ~opcode[16] & ~opcode[15] & ~opcode[14] & ~opcode[13] & ~opcode[12] & ~opcode[11] & ~opcode[10] & ~opcode[9] & ~opcode[8] & ~opcode[7] &  opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[1] = (~opcode[31] &  opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] &  opcode[14] & ~opcode[13] &  opcode[12] & ~opcode[6] & ~opcode[5] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[2] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[13] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &  opcode[1] &  opcode[0]);
   assign row_term[3] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[12] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &  opcode[1] &  opcode[0]);
   assign row_term[4] = (~opcode[31] &  opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] & ~opcode[14] & ~opcode[13] & ~opcode[12] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[5] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[14] & ~opcode[6] &  opcode[4] & ~opcode[3] &  opcode[1] &  opcode[0]);
   assign row_term[6] = (~opcode[31] &  opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[14] & ~opcode[13] &  opcode[12] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[7] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[8] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[13] &  opcode[12] & ~opcode[6] & ~opcode[5] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[9] = ( opcode[14] &  opcode[13] &  opcode[12] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] &  opcode[1] &  opcode[0]);
   assign row_term[10] = (~opcode[31] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] &  opcode[14] &  opcode[12] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[11] = (~opcode[14] & ~opcode[13] & ~opcode[12] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[12] = ( opcode[14] & ~opcode[12] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] &  opcode[1] &  opcode[0]);
   assign row_term[13] = (~opcode[13] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[14] = ( opcode[6] &  opcode[5] & ~opcode[4] &  opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[15] = (~opcode[14] & ~opcode[12] & ~opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[16] = (~opcode[14] & ~opcode[13] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[17] = (~opcode[14] & ~opcode[12] & ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[18] = ( opcode[14] &  opcode[13] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[19] = (~opcode[6] &  opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[20] = ( opcode[14] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[21] = (~opcode[13] & ~opcode[12] & ~opcode[6] & ~opcode[5] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[22] = (~opcode[13] & ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);

   assign vld_decode = row_term[0] | row_term[4] | row_term[6] | row_term[7] | row_term[8] | row_term[10] | row_term[11] | row_term[14] | row_term[15] | row_term[16] | row_term[17] | row_term[18] | row_term[19] | row_term[20] | row_term[21] | row_term[22];
   assign rd_valid = row_term[4] | row_term[6] | row_term[7] | row_term[8] | row_term[10] | row_term[11] | row_term[14] | row_term[17] | row_term[18] | row_term[19] | row_term[21] | row_term[22];
   assign rs1_valid = row_term[4] | row_term[6] | row_term[7] | row_term[8] | row_term[10] | row_term[11] | row_term[15] | row_term[16] | row_term[17] | row_term[18] | row_term[20] | row_term[21] | row_term[22];
   assign rs2_valid = row_term[4] | row_term[6] | row_term[7] | row_term[15] | row_term[16] | row_term[20];
   assign is_branch = row_term[13] | row_term[20];
   assign is_jal = row_term[11] | row_term[14];
   assign is_wfi = row_term[0];
   assign imm[3] = row_term[19];
   assign imm[2] = row_term[14] | row_term[15] | row_term[16] | row_term[20];
   assign imm[1] = row_term[13] | row_term[17] | row_term[20] | row_term[22];
   assign imm[0] = row_term[8] | row_term[10] | row_term[11] | row_term[13] | row_term[14] | row_term[17] | row_term[18] | row_term[20] | row_term[21] | row_term[22];
   assign aluop[3] = row_term[1] | row_term[4] | row_term[6] | row_term[13] | row_term[20];
   assign aluop[2] = row_term[5] | row_term[6] | row_term[10] | row_term[12] | row_term[18];
   assign aluop[1] = row_term[2] | row_term[18];
   assign aluop[0] = row_term[3] | row_term[6] | row_term[8] | row_term[9] | row_term[10];

endmodule
