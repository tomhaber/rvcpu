module sim_clock #(
    parameter CLOCK_PERIOD = 10
) (
    output reg clock
);

localparam HALF_PERIOD = CLOCK_PERIOD / 2;

always begin
    #HALF_PERIOD clock = (clock === 1'b0);
end

endmodule
