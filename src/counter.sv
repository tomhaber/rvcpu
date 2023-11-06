module counter #(
    parameter Width = 8,
    parameter [Width-1:0] Low = 0,
    parameter [Width-1:0] High = 2**Width,
    parameter [Width-1:0] Increment = 1,
    parameter [Width-1:0] Initial = Low
) (
    input logic clk,
    input logic rst,

    input logic up0_down1,
    input logic enable,

    input logic load,
    input logic [Width-1:0] data,

    input logic carry_in,
    output logic carry_out,

    output logic overflow,
    output logic [Width-1:0] count
);

logic [Width-1:0] carry_in_selected, eff_b;
logic [Width-1:0] sum;

always_comb begin
    carry_in_selected = (up0_down1 == 1'b0) ? {{(Width-1){1'b0}}, carry_in} : {(Width){carry_in}};
    eff_b = (up0_down1 == 1'b0) ? Increment : (~Increment + 1);
    {carry_out, sum} = {1'b0, count} + {1'b0, eff_b} + {1'b0, carry_in_selected};
end

logic [Width-1:0] next_count;
logic next_overflow;

always_comb begin
    if(load) begin
        next_count = data;
        next_overflow = 1'b0;
    end else if(enable) begin
        if(count == Low && (up0_down1 == 1'b1)) begin
            next_count = High;
            next_overflow = 1'b1;
        end else if(count == High && (up0_down1 == 1'b0)) begin
            next_count = Low;
            next_overflow = 1'b1;
        end else begin
            next_count = sum;
            next_overflow = 1'b0;
        end
    end else begin
        next_count = count;
        next_overflow = overflow;
    end
end

always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        count <= Initial;
        overflow <= 1'b0;
    end else begin
        count <= next_count;
        overflow <= next_overflow;
    end
end

endmodule
