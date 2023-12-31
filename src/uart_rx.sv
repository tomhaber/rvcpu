module uart_rx #(
    parameter BaudDivider = 8,
    parameter DataBits = 8,
    parameter StopBits = 1,
    parameter Parity = 0 /* 0 = none, 1 = even, 2 = odd */
) (
    input logic clk,
    input logic rst,

    input logic input_bit,

    output logic [DataBits-1:0] data_out,
    output logic data_valid,
    output logic break_received,
    output logic error
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

localparam DataLSB = StartBits;
localparam DataMSB = StartBits + DataBits - 1;
localparam PartityLSB = StartBits + DataBits;
localparam StopLSB = PartityLSB + ParityBits;
localparam StopMSB = StopLSB + StopBits - 1;

logic [TotalBits-1:0] rx_data;
logic [$clog2(TotalBits)-1:0] bit_idx;

typedef enum logic[1:0] { IDLE, RECV, DONE } state_t;
state_t state = IDLE, next_state;

localparam BaudBits = $clog2(BaudDivider);

logic bit_done;
pulse_generator #(.Width(BaudBits), .InitialDivisor(BaudDivider-1)) baud_gen (
    .clk(clk), .rst(state == IDLE),
    .divisor(BaudBits'((state == IDLE) ? (BaudDivider/2) : (BaudDivider-1))),
    .enable(state == RECV), .pulse_out(bit_done)
);

logic input_latched;

shift_in_register #(.Width(TotalBits), .ResetValue(1'b1)) shift_in (
    .clk(clk), .rst(rst), .enable(bit_done),
    .serial_in(input_latched), .serial_out(),
    .parallel_output(rx_data)
);

function automatic data_check(logic [TotalBits-1:0] data);
    logic parity = (Parity == 1) ? ^data[DataBits-1:0] : ~(^data[DataBits-1:0]);
    return (rx_data[StopMSB:StopLSB] == 1'b1) &&
        (ParityBits == 0) ? 1'b1 : (parity == data[PartityLSB]);
endfunction

always_comb begin
    break_received = 1'b0;
    error = 1'b0;
    data_valid = 1'b0;

    unique case(state)

    IDLE: begin
        if(input_latched == 1'b0)
            next_state = RECV;
        else
            next_state = IDLE;
    end

    DONE: begin
        if(data_check(rx_data))
            data_valid = 1'b1;
        else if(rx_data == 0)
            break_received = 1'b1;
        else
            error = 1'b1;

        next_state = IDLE;
    end

    RECV: begin
        if(bit_done)
            next_state = (bit_idx == MaxBitIdx) ? DONE : RECV;
        else
            next_state = RECV;
    end

    default: next_state = IDLE;

    endcase
end

always_ff @(posedge clk) begin
    input_latched <= input_bit;
end

always_ff @(posedge clk or posedge rst) begin
    if(rst)
        state <= IDLE;
    else
        state <= next_state;
end

// bit counter
always_ff @(posedge clk) begin
    if(state == IDLE)
        bit_idx <= 0;
    else if(bit_done) begin
        bit_idx <= bit_idx + 1;
    end
end

assign data_out = rx_data[DataMSB:DataLSB];

endmodule
