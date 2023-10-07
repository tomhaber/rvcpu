module decoder (
      input   logic[31:0]   opcode,

      output  logic vld_decode,
      output  logic rd_valid,
      output  logic rs1_valid,
      output  logic rs2_valid,
      output  logic is_wfi,
      output  logic[3:0]   imm,
      output  logic[1:0]   unit,
      output  logic[3:0]   op
   );

   logic [29:0]   row_term;

//   0: 00010000010100000000000001110011 100010000000000
//   1: 0000000-----------1------0110-11 000000000000010
//   2: 0000000------------1-----0110-11 000000000000001
//   3: 0000000----------1-------0-10011 000000000000100
//   4: 0100000----------000-----0110011 111100000011000
//   5: 0-0000-----------1-------0010011 000000000000100
//   6: 0100000----------101-----0110011 111100000011101
//   7: 010000-----------101-----0010011 111000001011001
//   8: 0000000------------------0110011 111100000010000
//   9: 000000------------01-----00-0011 111000001010001
//  10: -----------------110-----1100011 000000000000110
//  11: -----------------111-----0010011 000000000000001
//  12: -----------------0-0-----0000011 010000011000000
//  13: -----------------101-----0000011 000000000000101
//  14: ------------------01-----1100011 000000000000001
//  15: -----------------000-----1100111 111000001100000
//  16: -----------------10------1100011 000000000000100
//  17: -----------------100-----00-0011 000000000000100
//  18: -----------------001-----0-00011 000000000010001
//  19: -------------------------1101111 110000101100000
//  20: ------------------0------1100011 000000011000000
//  21: -----------------0-0-----0100011 000100100011000
//  22: -----------------010-----0-00011 101000000110010
//  23: -------------------------0110111 000000000001111
//  24: -----------------00-------100011 101100100101000
//  25: -----------------11------0010011 111000001010110
//  26: -------------------------0-10111 110001000010000
//  27: -----------------1-------1100011 101100111101000
//  28: ------------------00-----00-0011 111000001010000
//  29: ------------------0------0000011 111000011110000

   assign row_term[0] = (~opcode[31] & ~opcode[30] & ~opcode[29] &  opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] & ~opcode[24] & ~opcode[23] &  opcode[22] & ~opcode[21] &  opcode[20] & ~opcode[19] & ~opcode[18] & ~opcode[17] & ~opcode[16] & ~opcode[15] & ~opcode[14] & ~opcode[13] & ~opcode[12] & ~opcode[11] & ~opcode[10] & ~opcode[9] & ~opcode[8] & ~opcode[7] &  opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[1] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[13] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &  opcode[1] &  opcode[0]);
   assign row_term[2] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[12] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &  opcode[1] &  opcode[0]);
   assign row_term[3] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[14] & ~opcode[6] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[4] = (~opcode[31] &  opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] & ~opcode[14] & ~opcode[13] & ~opcode[12] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[5] = (~opcode[31] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] &  opcode[14] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[6] = (~opcode[31] &  opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] &  opcode[14] & ~opcode[13] &  opcode[12] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[7] = (~opcode[31] &  opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] &  opcode[14] & ~opcode[13] &  opcode[12] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[8] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[25] & ~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[9] = (~opcode[31] & ~opcode[30] & ~opcode[29] & ~opcode[28] & ~opcode[27] & ~opcode[26] & ~opcode[13] &  opcode[12] & ~opcode[6] & ~opcode[5] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[10] = ( opcode[14] &  opcode[13] & ~opcode[12] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[11] = ( opcode[14] &  opcode[13] &  opcode[12] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[12] = (~opcode[14] & ~opcode[12] & ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[13] = ( opcode[14] & ~opcode[13] &  opcode[12] & ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[14] = (~opcode[13] &  opcode[12] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[15] = (~opcode[14] & ~opcode[13] & ~opcode[12] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[16] = ( opcode[14] & ~opcode[13] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[17] = ( opcode[14] & ~opcode[13] & ~opcode[12] & ~opcode[6] & ~opcode[5] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[18] = (~opcode[14] & ~opcode[13] &  opcode[12] & ~opcode[6] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[19] = ( opcode[6] &  opcode[5] & ~opcode[4] &  opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[20] = (~opcode[13] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[21] = (~opcode[14] & ~opcode[12] & ~opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[22] = (~opcode[14] &  opcode[13] & ~opcode[12] & ~opcode[6] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[23] = (~opcode[6] &  opcode[5] &  opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[24] = (~opcode[14] & ~opcode[13] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[25] = ( opcode[14] &  opcode[13] & ~opcode[6] & ~opcode[5] &  opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[26] = (~opcode[6] &  opcode[4] & ~opcode[3] &  opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[27] = ( opcode[14] &  opcode[6] &  opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[28] = (~opcode[13] & ~opcode[12] & ~opcode[6] & ~opcode[5] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);
   assign row_term[29] = (~opcode[13] & ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2] &  opcode[1] &  opcode[0]);

   assign vld_decode = row_term[0] | row_term[4] | row_term[6] | row_term[7] | row_term[8] | row_term[9] | row_term[15] | row_term[19] | row_term[22] | row_term[24] | row_term[25] | row_term[26] | row_term[27] | row_term[28] | row_term[29];
   assign rd_valid = row_term[4] | row_term[6] | row_term[7] | row_term[8] | row_term[9] | row_term[12] | row_term[15] | row_term[19] | row_term[25] | row_term[26] | row_term[28] | row_term[29];
   assign rs1_valid = row_term[4] | row_term[6] | row_term[7] | row_term[8] | row_term[9] | row_term[15] | row_term[22] | row_term[24] | row_term[25] | row_term[27] | row_term[28] | row_term[29];
   assign rs2_valid = row_term[4] | row_term[6] | row_term[8] | row_term[21] | row_term[24] | row_term[27];
   assign is_wfi = row_term[0];
   assign imm[3] = row_term[26];
   assign imm[2] = row_term[19] | row_term[21] | row_term[24] | row_term[27];
   assign imm[1] = row_term[12] | row_term[20] | row_term[27] | row_term[29];
   assign imm[0] = row_term[7] | row_term[9] | row_term[12] | row_term[15] | row_term[19] | row_term[20] | row_term[25] | row_term[27] | row_term[28] | row_term[29];
   assign unit[1] = row_term[15] | row_term[19] | row_term[22] | row_term[24] | row_term[27] | row_term[29];
   assign unit[0] = row_term[4] | row_term[6] | row_term[7] | row_term[8] | row_term[9] | row_term[18] | row_term[21] | row_term[22] | row_term[25] | row_term[26] | row_term[28] | row_term[29];
   assign op[3] = row_term[4] | row_term[6] | row_term[7] | row_term[21] | row_term[23] | row_term[24] | row_term[27];
   assign op[2] = row_term[3] | row_term[5] | row_term[6] | row_term[10] | row_term[13] | row_term[16] | row_term[17] | row_term[23] | row_term[25];
   assign op[1] = row_term[1] | row_term[10] | row_term[22] | row_term[23] | row_term[25];
   assign op[0] = row_term[2] | row_term[6] | row_term[7] | row_term[9] | row_term[11] | row_term[13] | row_term[14] | row_term[18] | row_term[23];

endmodule
