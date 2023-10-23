module sdpram #(
    parameter MemoryInitFile = "none",
    parameter AddrBusWidth = 32,
    parameter DataBusWidth = 32,
    parameter MemSizeBytes = 2048
) (
    input  wire                    clk,
    input  wire                    rst,
    input  wire [AddrBusWidth-1:0] addr_a,
    input  wire                    we_a,
    input  wire [DataBusWidth-1:0] w_data_a,
    input  wire                    re_b,
    input  wire [AddrBusWidth-1:0] addr_b,
    output reg  [DataBusWidth-1:0] r_data_b
);

`ifndef VERILATOR
xpm_memory_sdpram #(
    .ECC_MODE("no_ecc"),
    .CLOCKING_MODE("common_clock"),
    .MEMORY_PRIMITIVE("auto"),
    .USE_MEM_INIT(MemoryInitFile != "none"),
    .MEMORY_INIT_FILE(MemoryInitFile),
    .SIM_ASSERT_CHK(1),

    .ADDR_WIDTH_A(AddrBusWidth),
    .WRITE_DATA_WIDTH_A(DataBusWidth),
    .BYTE_WRITE_WIDTH_A(DataBusWidth),

    .ADDR_WIDTH_B(AddrBusWidth),
    .READ_DATA_WIDTH_B(DataBusWidth),
    .READ_LATENCY_B(1),
    .READ_RESET_VALUE_B("0"),
    .WRITE_MODE_B("read_first"),

    .WRITE_PROTECT(1),
    .MEMORY_SIZE(MemSizeBytes*8)
) ram (
    .clka(clk),
    .ena(~rst),
    .wea(we_a),
    .addra(addr_a),
    .dina(w_data_a),

    .rstb(rst),
    .enb(re_b),
    .addrb(addr_b),
    .doutb(r_data_b)
);
`else
sdpram_generic #(
    .MemoryInitFile(MemoryInitFile),
    .AddrBusWidth(AddrBusWidth),
    .DataBusWidth(DataBusWidth),
    .MemSizeBytes(MemSizeBytes)
) ram (
    .clk(clk), .rst(rst),

    .addr_a(addr_a),
    .we_a(we_a), .w_data_a(w_data_a),

    .addr_b(addr_b),
    .re_b(re_b), .r_data_b(r_data_b)
);
`endif
endmodule
