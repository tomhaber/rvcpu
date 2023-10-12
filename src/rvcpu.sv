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
    none_imm = 'b0000
} imm_type_t;

typedef logic [4:0] reg_t;

typedef enum [1:0] {
    unit_none = 'b00,
    unit_alu  = 'b01,
    unit_bru  = 'b10,
    unit_mem  = 'b11
} unit_t;

typedef enum [3:0] {
    alu_and   = 'b0111,
    alu_or    = 'b0110,
    alu_xor   = 'b0100,
    alu_add   = 'b0000,
    alu_sub   = 'b1000,
    alu_sll   = 'b0001,
    alu_srl   = 'b0101,
    alu_sra   = 'b1011,
    alu_slt   = 'b0010,
    alu_sltu  = 'b0011,
    alu_pass  = 'b1111
} alu_op_t;

typedef enum [2:0] {
    bru_eq   = 'b000,
    bru_ne   = 'b001,
    bru_lt   = 'b100,
    bru_ge   = 'b101,
    bru_ltu  = 'b110,
    bru_geu  = 'b111
} bru_op_t;

typedef enum [2:0] {
    mem_b  = 'b000,
    mem_h  = 'b001,
    mem_w  = 'b011,
    mem_bu = 'b100,
    mem_hu = 'b101
} mem_op_t;

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
typedef logic [13:0] offset_t;
typedef logic [31:0] opcode_t;
typedef logic [3:0] operation_t;

const opcode_t RESET_PC = 'h00000000;
const opcode_t NOP = 'h00000013;

function offset_t data2offset(data_t d);
    return d[13:0];
endfunction

typedef struct packed {
    pc_t pc;
    opcode_t opcode;
} stage_if_t;

typedef struct packed {
    pc_t pc;
    logic vld_decode;
    logic is_wfi;
    unit_t unit;
    operation_t op;
    data_t rs1_data;
    logic rs1_valid;
    data_t rs2_data;
    logic rs2_valid;
    data_t imm;
    reg_t rd;
    logic rd_valid;
} stage_id_t;

typedef struct packed {
    logic is_mem;
    operation_t op;
    reg_t rd;
    logic rd_valid;
    addr_t addr;
    data_t data;
} stage_ex_t;

typedef struct packed {
    reg_t rd;
    logic rd_valid;
    data_t rd_data;
} stage_mem_t;

endpackage : rvcpu
