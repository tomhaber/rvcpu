module counter #(
    parameter Width = 8,
    parameter [Width-1:0] Increment = 1,
    parameter [Width-1:0] Initial = 0
) (
    input logic clk,
    input logic rst,

    input logic up0_down1,
    input logic enable,

    input logic load,
    input logic [Width-1:0] load_count,

    input logic carry_in,
    output logic carry_out,

    output logic overflow,
    output logic [Width-1:0] count
);

logic [Width-1:0] count_i = Initial;
assign count = count_i;

logic next_overflow_i;
logic next_carry_out_i;

logic [Width-1:0] sum;
adder #(.Width(Width)) add_sub(
    .up0_down1(up0_down1),
    .a(count_i), .b(Increment), .sum(sum),
    .carry_in(carry_in), .carry_out(next_carry_out_i),
    .overflow(next_overflow_i)
);

logic [Width-1:0] next_count;
logic next_overflow;
logic next_carry_out;

always_comb begin
    if(load) begin
        next_count = load_count;
        next_overflow = 1'b0;
        next_carry_out = 1'b0;
    end else if(enable) begin
        next_count = sum;
        next_overflow = next_overflow_i;
        next_carry_out = next_carry_out_i;
    end else begin
        next_count = count_i;
        next_overflow = overflow;
        next_carry_out = carry_out;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        count_i <= Initial;
        overflow <= 1'b0;
        carry_out <= 1'b0;
    end else begin
        count_i <= next_count;
        overflow <= next_overflow;
        carry_out <= next_carry_out;
    end
end

endmodule
