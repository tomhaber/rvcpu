package rvcpu;

typedef enum {
    alu_imm,
    uimm,
    load_offset,
    store_offset,
    jal_offset,
    jalr_offset,
    br_offset,
    ui_imm,
    none
} imm_type_t;
typedef logic [4:0] reg_t;
typedef logic [3:0] alu_op_t;

endpackage : rvcpu
