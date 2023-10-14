module dependency_unit (
    input rvcpu::reg_t rs1,
    input logic rs1_valid,
    input rvcpu::reg_t rs2,
    input logic rs2_valid,
    input rvcpu::reg_t rd_ex,
    input logic rd_ex_vld,
    input rvcpu::reg_t rd_mem,
    input logic rd_mem_vld,
    input rvcpu::reg_t rd_wb,
    input logic rd_wb_vld,
    output logic dep_found
);

wire logic rs1_dep = rs1_valid & (rs1 != '0) & (
            ((rs1 == rd_ex) & rd_ex_vld) |
            ((rs1 == rd_mem) & rd_mem_vld) |
            ((rs1 == rd_wb) & rd_wb_vld)
        );
wire logic rs2_dep = rs2_valid & (rs2 != '0) & (
            ((rs2 == rd_ex) & rd_ex_vld) |
            ((rs2 == rd_mem) & rd_mem_vld) |
            ((rs2 == rd_wb) & rd_wb_vld)
        );
assign dep_found = rs1_dep | rs2_dep;
endmodule
