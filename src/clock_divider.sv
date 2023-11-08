module clock_divider #(
    parameter Width = 8,
    parameter [Width-1:0] Divisor = (2**Width)-1
) (
    input logic clk,
    input logic rst,

    input logic enable,
    output logic clk_out
);

localparam Count = Divisor - Width'(1);

wire logic [Width-1:0] count;
logic enable_i;
logic load;

counter
#(
    .Width(Width),
    .Increment(1),
    .Initial(Count)
) cntr (
    .clk(clk),
    .rst(1'b0),
    .up0_down1(1'b1),
    .enable(enable),
    .load(load),
    .load_count(Count),
    .carry_in(1'b0),
    .carry_out(),
    .overflow(),
    .count(count)
);

logic done;

always_comb begin
    done = enable && (count == 0);
    load = done || rst;
    enable_i = enable && (count != 0);
    clk_out = done && !rst;
end

endmodule
