module pulse_generator #(
    parameter Width = 0,
    parameter InitialDivisor = 0
) (
    input logic clk,
    input logic rst,

    input logic [Width_i-1:0] divisor,

    input logic enable,
    output logic pulse_out
);

localparam Width_i = (Width > 0) ? Width : $clog2(InitialDivisor);

logic [Width_i-1:0] count;
logic enable_i;
logic load;

counter
#(
    .Width(Width_i),
    .Increment(1),
    .Initial(Width_i'(InitialDivisor))
) cntr (
    .clk(clk),
    .rst(1'b0),
    .up0_down1(1'b1),
    .enable(enable_i),
    .load(load),
    .load_count(divisor),
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
    pulse_out = done && !rst;
end

endmodule
