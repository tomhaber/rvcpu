module spram #(
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
    input  logic                    re,
    input  logic [AddrBusWidth-1:0] addr,
    input  logic                    we,
    input  logic [DataBusWidth-1:0] w_data,
    output logic [DataBusWidth-1:0] r_data
);

localparam MemSizeWords_i = (MemSizeWords > 0) ? MemSizeWords : (2**AddrBusWidth);
localparam MemSizeBits = (MemSizeWords_i*DataBusWidth);

`ifdef VIVADO
xpm_memory_spram #(
    .ECC_MODE("no_ecc"),
    .MEMORY_PRIMITIVE(MemoryPrimitive),
    .USE_MEM_INIT(MemoryInitFile != "none"),
    .MEMORY_INIT_FILE(MemoryInitFile),
    .SIM_ASSERT_CHK(1),
    .ADDR_WIDTH_A(AddrBusWidth),
    .WRITE_DATA_WIDTH_A(DataBusWidth),
    .READ_DATA_WIDTH_A(DataBusWidth),
    .BYTE_WRITE_WIDTH_A(DataBusWidth),
    .READ_LATENCY_A(ReadLatency),
    .WRITE_MODE_A(MemoryAddrCollision == "yes" ? "write_first" : ((MemoryAddrCollision == "no") : "no_change" : "read_first")),
    .WRITE_PROTECT(1),
    .MEMORY_SIZE(MemSizeBits)
) ram (
    .clka(clk),
    .rsta(rst),
    .ena(re | we),
    .wea(we),
    .addra(addr),
    .dina(w_data),
    .douta(r_data)
);
`else
spram_generic #(
    .MemoryInitFile(MemoryInitFile),
    .ReadLatency(ReadLatency),
    .AddrBusWidth(AddrBusWidth),
    .DataBusWidth(DataBusWidth),
    .MemSizeWords(MemSizeWords)
) ram (
    .clk(clk), .rst(rst),
    .re(re), .addr(addr),
    .we(we), .w_data(w_data),
    .r_data(r_data)
);
`endif
endmodule
