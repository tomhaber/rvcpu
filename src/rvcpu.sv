package rvcpu;

typedef enum {auipc_imm, alu_imm, uimm, load_offset, store_offset, jal_offset, jalr_offset, br_offset, none} imm_type_t;
typedef logic [4:0] reg_t;

endpackage : rvcpu
