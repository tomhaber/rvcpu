module spram #(
    parameter MemoryInitFile = "none",
    parameter AddrBusWidth = 32,
    parameter DataBusWidth = 32,
    parameter MemSizeBytes = 2048
) (
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    re,
    input  wire [AddrBusWidth-1:0] addr,
    input  wire                    we,
    input  wire [DataBusWidth-1:0] w_data,
    output reg  [DataBusWidth-1:0] r_data
);

`ifdef VIVADO
xpm_memory_spram #(
    .ECC_MODE("no_ecc"),
    .MEMORY_PRIMITIVE("auto"),
    .MEMORY_SIZE(),
    .USE_MEM_INIT(MemoryInitFile != "none"),
    .MEMORY_INIT_FILE(MemoryInitFile),
    .SIM_ASSERT_CHK(1),
    .ADDR_WIDTH_A(AddrBusWidth),
    .WRITE_DATA_WIDTH_A(DataBusWidth),
    .READ_DATA_WIDTH_A(DataBusWidth),
    .BYTE_WRITE_WIDTH_A(DataBusWidth),
    .READ_LATENCY_A(1),
    .WRITE_MODE_A("read_first"),
    .WRITE_PROTECT(1),
    .MEMORY_SIZE(MemSizeBytes*8)
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
    .AddrBusWidth(AddrBusWidth),
    .DataBusWidth(DataBusWidth),
    .MemSizeBytes(MemSizeBytes)
) ram (
    .clk(clk), .rst(rst),
    .re(re), .addr(addr),
    .we(we), .w_data(w_data),
    .r_data(r_data)
);
`endif
endmodule
