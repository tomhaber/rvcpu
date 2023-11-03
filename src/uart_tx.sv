module uart_tx #(
    parameter ClockDivider = 8,
    parameter DataBits = 8,
    parameter StopBits = 1,
    parameter ParityBits = 0
) (
    input logic clk,
    input logic rst,

    input logic [DataBits-1:0] data_in,
    input logic data_in_valid,

    output logic out_bit,
    output logic ready
);

initial begin
    if(DataBits < 5 || DataBits > 9)
        $error("DataBits needs to be in [5,9]");
    if(StopBits < 1 || StopBits > 2)
        $error("StopBits needs to be either 1 or 2");
    if(ParityBits < 0 || ParityBits > 1)
        $error("ParityBits needs to be either 0 or 1");
end

localparam StartBits = 1;
localparam TotalBits = StartBits + DataBits + ParityBits + StopBits;
localparam MaxBitIdx = TotalBits-1;

localparam ClockDivBits = $clog2(ClockDivider);

logic [TotalBits-1:0] tx_data;
logic [$clog2(TotalBits)-1:0] bit_idx;

typedef enum { READY, LOAD, SEND } state_t;
state_t state, next_state;

localparam MaxCount = ClockDivBits'(ClockDivider-1);
logic [ClockDivBits-1:0] counter;

wire logic bit_done = counter == MaxCount;

function static parity(input logic [DataBits-1:0] data);
    return ^data;
endfunction

always_comb begin
    unique case(state)

    READY: next_state = (data_in_valid) ? LOAD : READY;
    LOAD: next_state = SEND;
    SEND: begin
        if(bit_done)
            next_state = (bit_idx == MaxBitIdx) ? READY : LOAD;
        else
            next_state = SEND;
    end

    endcase
end

always_ff @(posedge clk or posedge rst) begin
    if(rst)
        state <= READY;
    else
        state <= next_state;
end

// clock divider
always_ff @(posedge clk) begin
    if(state == READY || counter == MaxCount)
        counter <= 0;
    else
        counter <= counter + 1;
end

// bit counter
always_ff @(posedge clk or posedge rst) begin
    if(state == READY || rst) begin
        out_bit <= 1'b1;
        bit_idx <= 0;
    end else if(state == LOAD) begin
        bit_idx <= bit_idx + 1;
        out_bit <= tx_data[bit_idx];
    end
end

assign ready = state == READY;

// Latch input
always_ff @(posedge clk) begin
    if(state == READY && data_in_valid)
        tx_data <= {1'b0, data_in, {ParityBits{parity(data_in)}}, {StopBits{1'b0}}};
end

endmodule
