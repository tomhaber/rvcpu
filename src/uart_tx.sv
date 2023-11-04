module uart_tx #(
    parameter ClockDivider = 8,
    parameter DataBits = 8,
    parameter StopBits = 1,
    parameter Parity = 0 /* 0 = none, 1 = even, 2 = odd */
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
    if(Parity < 0 || Parity > 2)
        $error("ParityBits needs to be either 0, 1 or 2");
end

localparam StartBits = 1;
localparam ParityBits = (Parity == 0) ? 0 : 1;
localparam TotalBits = StartBits + DataBits + ParityBits + StopBits;
localparam MaxBitIdx = TotalBits-1;

localparam ClockDivBits = $clog2(ClockDivider);

logic [$clog2(TotalBits)-1:0] bit_idx;

typedef enum logic [1:0] { READY, LOAD, SEND } state_t;
state_t state, next_state;

localparam MaxCount = ClockDivBits'(ClockDivider-1);
logic [ClockDivBits-1:0] counter;

wire logic bit_done = counter == MaxCount;

function automatic parity(input logic [DataBits-1:0] data);
    return (Parity == 1) ? ^data : ~(^data);
endfunction

shift_out_register #(.Width(TotalBits)) shift_out (
    .clk(clk), .rst(rst),
    .serial_in(1'b1), .serial_out(out_bit),
    .enable(state == LOAD),
    .parallel_input({
        {StopBits{1'b1}},
        {ParityBits{parity(data_in)}},
        data_in,
        {StartBits{1'b0}}
    }),
    .parallel_load(state == READY && data_in_valid)
);

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
        bit_idx <= 0;
    end else if(state == SEND && next_state == LOAD) begin
        bit_idx <= bit_idx + 1;
    end
end

assign ready = next_state == READY;

endmodule
