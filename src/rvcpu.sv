package rvcpu;

parameter Width = 32;

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
    logic less_than_unsigned;
} cmp_t;

typedef logic [Width-1:0] pc_t;
typedef logic [Width-1:0] addr_t;
typedef logic [Width-1:0] data_t;
typedef logic [31:0] opcode_t;

typedef struct packed {
    pc_t pc;
    opcode_t opcode;
} stage_if_t;

typedef struct packed {
    pc_t pc;
    logic vld_decode;
    logic is_branch;
    logic is_jal;
    logic is_wfi;
    logic[3:0] aluop;
    data_t a;
    data_t b;
    reg_t rd;
    logic rd_valid;
} stage_id_t;

typedef struct packed {
    pc_t pc;
    data_t res;
} stage_ex_t;

typedef struct packed {
    pc_t pc;
    reg_t rd;
    data_t rd_data;
    logic rd_valid;
} stage_wb_t;

endpackage : rvcpu
