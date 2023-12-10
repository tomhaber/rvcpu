typedef enum logic[1:0] {
    NORMAL = 2'b00,
    QUAD_READ = 2'b10,
    QUAD_WRITE = 2'b11
} mode_t;

module flash_startup (
    input logic clk,
    input logic rst,

    output logic startup,
    output mode_t cmd_mode,
    output logic[7:0] cmd_byte,
    input logic byte_sent
);

// Startup
localparam StartupSize = 32;
localparam StartupIdxBits = $clog2(StartupSize);

typedef struct packed {
    logic sleep;
    union packed {
        struct packed {
            mode_t mode;
            logic [7:0] data;
        } cmd;

        logic [9:0] idle_count;
    } d;
} data_word_t;

data_word_t cmd_words[StartupSize];
logic [StartupIdxBits-1:0] cmd_index;

initial begin
    for(integer k = 0; k < StartupSize; k=k+1)
        cmd_words[k] = -1;

    // Exit any QSPI mode we might've been in
    cmd_words[5'h08] = { 1'b0, NORMAL, 8'hff };
    cmd_words[5'h09] = { 1'b0, NORMAL, 8'hff };
    cmd_words[5'h0a] = { 1'b0, NORMAL, 8'hff };
    // Idle
    cmd_words[5'h0b] = { 1'b1, 10'h3f };
    //
    // Write configuration register
    //
    // The write enable must come first: 06
    cmd_words[5'h0c] = { 1'b0, NORMAL, 8'h06 };
    //
    // Idle
    cmd_words[5'h0d] = { 1'b1, 10'h3ff };
    //
    // Write configuration register, follows a write-register
    cmd_words[5'h0e] = { 1'b0, NORMAL, 8'h01 };	// WRR
    cmd_words[5'h0f] = { 1'b0, NORMAL, 8'h00 };	// status register
    cmd_words[5'h10] = { 1'b0, NORMAL, 8'h02 };	// Config register
    //
    // Idle
    cmd_words[5'h11] = { 1'b1, 10'h3ff };
    cmd_words[5'h12] = { 1'b1, 10'h3ff };
    //
    //
    // WRDI: write disable: 04
    cmd_words[5'h13] = { 1'b0, NORMAL, 8'h04 };
    //
    // Idle
    cmd_words[5'h14] = { 1'b1, 10'h3ff };
    //
    // Enter into QSPI mode, 0xeb, 0,0,0
    // 0xeb
    cmd_words[5'h15] = { 1'b0, NORMAL, 8'heb };
    // Addr #1
    cmd_words[5'h16] = { 1'b0, QUAD_WRITE, 8'h00 };
    // Addr #2
    cmd_words[5'h17] = { 1'b0, QUAD_WRITE, 8'h00 };
    // Addr #3
    cmd_words[5'h18] = { 1'b0, QUAD_WRITE, 8'h00 };
    // Mode byte
    cmd_words[5'h19] = { 1'b0, QUAD_WRITE, 8'ha0 };
    // Dummy clocks, x6 for this flash
    cmd_words[5'h1a] = { 1'b0, QUAD_WRITE, 8'h00 };
    cmd_words[5'h1b] = { 1'b0, QUAD_WRITE, 8'h00 };
    cmd_words[5'h1c] = { 1'b0, QUAD_WRITE, 8'h00 };
    // Now read a byte for form
    cmd_words[5'h1d] = { 1'b0, QUAD_READ, 8'h00 };
    //
    // Idle -- These last two idles are *REQUIRED* and not optional
    // (although they might be able to be trimmed back a bit...)
    cmd_words[5'h1e] = -1;
    cmd_words[5'h1f] = -1;
    // Then we are in business!
end

initial startup = 1'b1;
data_word_t cmd_current;
logic cmd_final = &{cmd_index};

logic cmd_done;

always_ff @(posedge clk) begin
    if(rst) begin
        startup <= 1'b1;
        cmd_index <= 0;
    end else if(cmd_done)
        startup <= startup && !cmd_final;
end

always_ff @(posedge clk) begin
    if(cmd_done) begin
        cmd_current = cmd_words[cmd_index];
        if(!cmd_final)
            cmd_index <= cmd_index + 1;
    end
end

logic [9:0] idle_counter = -1;
always_ff @(posedge clk) begin
    if(rst) begin
        idle_counter <= -1;
    end else if(cmd_done) begin
        if(cmd_current.sleep)
            idle_counter <= cmd_current.d.idle_count;
    end else begin
        if(idle_counter > 0)
            idle_counter <= idle_counter - 1;
    end
end

assign cmd_done = (cmd_current.sleep && idle_counter > 0) || byte_sent;

endmodule

module qspi_flash #(
    parameter LgFlashSize = 24,
    parameter ClockDivider = 1,
    parameter AddrBusWidth = LgFlashSize - 2,
    parameter DataBusWidth = 32
) (
    input logic clk,
    input logic rst,

    input logic[AddrBusWidth-1:0] r_addr,
    input logic re,
    output logic ready,
    output logic[DataBusWidth-1:0] r_data,
    output logic r_data_valid,

    output logic qspi_sck,
    output logic qspi_cs_n,
    output mode_t qspi_mod,
    output logic[3:0] qspi_dat_o,
    input logic[3:0] qspi_dat_i
);

logic byte_sent;

logic startup;
mode_t cmd_mode;
logic [7:0] cmd_byte;

flash_startup flash_startup(
    .clk(clk), .rst(rst),
    .startup(startup),
    .cmd_mode(cmd_mode),
    .cmd_byte(cmd_byte),
    .byte_sent(byte_sent)
);

logic clk_pos, clk_neg;

clock_divider #(.Divisor(ClockDivider)) clk_div (
    .clk(clk), .rst(rst),
    .clk_pos(clk_pos), .clk_neg(clk_neg),
    .clk_out(qspi_sck)
);

mode_t mode;
always_comb begin
    if(!startup)
        mode = cmd_mode;
    else if(re)
        mode = QUAD_WRITE;
    else
        mode = QUAD_READ;
end

initial qspi_mod = NORMAL;
always_ff @(posedge clk) begin
    if(rst) qspi_mod <= NORMAL;
    else qspi_mod <= mode;
end

localparam DataBits = 8 + LgFlashSize;
logic [DataBits-1:0] data_shift = 0;
always_ff @(posedge clk) begin
    if(ready && re) begin
        data_shift <= 0;
        data_shift[DataBits-1:0] <= {r_addr, 2'b00, 4'ha, 4'h0};
    end else if(clk_neg) begin
        data_shift <= {data_shift[DataBits-4-1:0], 4'h0};
    end else if(startup) begin
        if(cmd_mode == NORMAL)
            for(integer i = 0; i < 8; ++i)
                data_shift[DataBits - i - 1] <= cmd_byte[7];
        else
            data_shift[DataBits-1 -: 8] <= cmd_byte;
    end
end

assign qspi_dat_o = data_shift[DataBits - 1 -: 4];
assign ready = !startup;

endmodule
