module uart_tx #(
    parameter BaudDivider = 8,
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

logic [$clog2(TotalBits)-1:0] bit_idx;

typedef enum logic [1:0] { READY, LOAD, SEND } state_t;
state_t state = READY, next_state;

function automatic logic[TotalBits-1:0] data_build(logic [DataBits-1:0] data);
    if(Parity > 0) begin
        logic parity = (Parity == 1) ? ^data : ~(^data);
        return {{StopBits{1'b1}},{ParityBits{parity}},data,{StartBits{1'b0}}};
    end else begin
        return {{StopBits{1'b1}},data,{StartBits{1'b0}}};
    end
endfunction

localparam BaudBits = $clog2(BaudDivider);

logic bit_done;
pulse_generator #(.Width(BaudBits), .InitialDivisor(BaudDivider-1)) baud_gen (
    .clk(clk), .rst(state == READY),
    .divisor(BaudBits'(BaudDivider-1)),
    .enable(1'b1), .pulse_out(bit_done)
);

shift_out_register #(.Width(TotalBits)) shift_out (
    .clk(clk), .rst(rst),
    .serial_in(1'b1), .serial_out(out_bit),
    .enable(state == LOAD),
    .parallel_input(
        data_build(data_in)
    ),
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

    default: next_state = READY;

    endcase
end

always_ff @(posedge clk or posedge rst) begin
    if(rst)
        state <= READY;
    else
        state <= next_state;
end

// bit counter
always_ff @(posedge clk or posedge rst) begin
    if(state == READY || rst) begin
        bit_idx <= 0;
    end else if(state == SEND && next_state == LOAD) begin
        bit_idx <= bit_idx + 1;
    end
end

assign ready = state == READY;

endmodule
