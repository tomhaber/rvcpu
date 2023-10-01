package rvcpu;

typedef enum [3:0] {
    alu_imm = 'b0001,
    uimm = 'b0010,
    load_offset = 'b0011,
    store_offset = 'b0100,
    jal_offset = 'b0101,
    jalr_offset = 'b0110,
    br_offset = 'b0111,
    ui_imm = 'b1000,
    none = 'b0000
} imm_type_t;

typedef logic [4:0] reg_t;

typedef enum [2:0] {
    alu_and   = 'b111,
    alu_or    = 'b110,
    alu_xor   = 'b100,
    alu_add   = 'b000,
    alu_sll   = 'b001,
    alu_srl   = 'b101,
    alu_sra   = 'b011,
    alu_slt   = 'b010
    // alu_sltu  = 'b011
} alu_op_t;

typedef struct packed {
    logic negative;
    logic zero;
    logic overflow;
    logic carry;
} alu_flags_t;

typedef struct packed {
    logic equal;
    logic less_than;
} cmp_t;

endpackage : rvcpu
