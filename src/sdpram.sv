module sdpram #(
    parameter MemoryInitFile = "none",
    parameter MemoryPrimitive = "auto",
    parameter MemoryAddrCollision = "",
    parameter ReadLatency = 1,  // combinatorial (0) or registers (1+)
    parameter AddrBusWidth = 32,
    parameter DataBusWidth = 32,
    parameter MemSizeWords = 0
) (
    input  logic                    clk,
    input  logic                    rst,
    input  logic [AddrBusWidth-1:0] addr_a,
    input  logic                    we_a,
    input  logic [DataBusWidth-1:0] w_data_a,
    input  logic                    re_b,
    input  logic [AddrBusWidth-1:0] addr_b,
    output logic [DataBusWidth-1:0] r_data_b
);

localparam MemSizeWords_i = (MemSizeWords > 0) ? MemSizeWords : (2**AddrBusWidth);
localparam MemSizeBits = (MemSizeWords_i*DataBusWidth);

`ifndef VERILATOR
xpm_memory_sdpram #(
    .ECC_MODE("no_ecc"),
    .CLOCKING_MODE("common_clock"),
    .MEMORY_PRIMITIVE(MemoryPrimitive),
    .USE_MEM_INIT(MemoryInitFile != "none"),
    .MEMORY_INIT_FILE(MemoryInitFile),
    .SIM_ASSERT_CHK(1),

    .ADDR_WIDTH_A(AddrBusWidth),
    .WRITE_DATA_WIDTH_A(DataBusWidth),
    .BYTE_WRITE_WIDTH_A(DataBusWidth),

    .ADDR_WIDTH_B(AddrBusWidth),
    .READ_DATA_WIDTH_B(DataBusWidth),
    .READ_LATENCY_B(ReadLatency),
    .READ_RESET_VALUE_B("0"),
    .WRITE_MODE_B(MemoryAddrCollision == "yes" ? "write_first" : ((MemoryAddrCollision == "no") : "no_change" : "read_first")),

    .WRITE_PROTECT(1),
    .MEMORY_SIZE(MemSizeBits)
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
    .ReadLatency(ReadLatency),
    .AddrBusWidth(AddrBusWidth),
    .DataBusWidth(DataBusWidth),
    .MemSizeWords(MemSizeWords)
) ram (
    .clk(clk), .rst(rst),

    .addr_a(addr_a),
    .we_a(we_a), .w_data_a(w_data_a),

    .addr_b(addr_b),
    .re_b(re_b), .r_data_b(r_data_b)
);
`endif
endmodule
