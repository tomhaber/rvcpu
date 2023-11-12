module top (
    input logic CLK100MHZ,
    input logic CLK12MHZ,

    input logic reset_n,

    input logic[3:0] sw,
    output logic[5:0] rgb_led,
    input logic[3:0] btn,
    output logic[5:2] led,

    // PMOD headers
    // Can be both inputs and outputs
    input logic[7:0] ja,
    input logic[7:0] jb,
    input logic[7:0] jc,
    input logic[7:0] jd,

    input logic uart_txd_in,
    output logic uart_rxd_out,

//    input logic[41:0] ck_io[41:0],

    // SPI
    output logic ck_ss,
    output logic ck_mosi,
    input logic ck_miso,
    output logic ck_sck,
    output logic ck_scl,
    output logic ck_sda,

    // I2C
    output logic ck_ioa,
    output logic ck_rst,

    // Quad SPI
    output logic qspi_cs,
    inout logic qspi_dq[3:0]
);

endmodule
