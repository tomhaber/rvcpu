module uart_rx #(
    parameter ClockDivider = 8,
    parameter DataBits = 8,
    parameter StopBits = 1,
    parameter ParityBits = 0
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
    if(ParityBits < 0 || ParityBits > 1)
        $error("ParityBits needs to be either 0 or 1");
end

localparam StartBits = 1;
localparam TotalBits = StartBits + DataBits + ParityBits + StopBits;
localparam MaxBitIdx = TotalBits-1;

localparam DataLSB = StartBits;
localparam DataMSB = StartBits + DataBits - 1;
localparam PartityLSB = StartBits + DataBits;
localparam StopLSB = PartityLSB + ParityBits;
localparam StopMSB = StopLSB + StopBits - 1;

localparam ClockDivBits = $clog2(ClockDivider);

logic [TotalBits-1:0] rx_data;
logic [$clog2(TotalBits)-1:0] bit_idx;

typedef enum { IDLE, RECV, DONE } state_t;
state_t state, next_state;

localparam MaxCount = ClockDivBits'(ClockDivider-1);
logic [ClockDivBits-1:0] counter;

logic input_latched;
wire logic bit_done = counter == MaxCount;

function static data_check(logic [TotalBits-1:0] data);
$display("stop %b", rx_data[StopMSB:StopLSB]);
    return (rx_data[StopMSB:StopLSB] == 1'b0) &&
        (ParityBits == 0) ? 1'b1 : (^data[DataBits-1:0] == data[PartityLSB]);
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

// clock divider
always_ff @(posedge clk) begin
    if(state == IDLE)
        counter <= ClockDivider/2;
    else if(state == RECV) begin
        if(counter == MaxCount)
            counter <= 0;
        else
            counter <= counter + 1;
    end
end

// bit counter
always_ff @(posedge clk) begin
    if(state == IDLE)
        bit_idx <= 0;
    else if(state == RECV && bit_done) begin
        $display("latch data %d %b", bit_idx, input_latched);
        rx_data[bit_idx] <= input_latched;
        bit_idx <= bit_idx + 1;
    end
end

assign data_out = rx_data[DataMSB:DataLSB];

endmodule
