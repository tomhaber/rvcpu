module clock_divider #(
    parameter Divisor
) (
    input logic clk,
    input logic rst,
    output logic clk_pos,
    output logic clk_neg,
    output logic clk_out
);

generate if(Divisor == 1) begin
    always_comb begin
        clk_out = clk;
        clk_neg = 1'b1;
        clk_pos = 1'b1;
    end
end else begin
    localparam DivBits = $clog2(Divisor);
    logic [DivBits-1:0] counter;

    always_ff @(posedge clk) begin
        if(rst)
            counter <= DivBits'(Divisor - 1);
        else if(counter > 0)
            counter <= counter - 1;
        else
            counter <= DivBits'(Divisor - 1);
    end

    initial begin
        clk_pos = Divisor == 2;
        clk_neg = 1'b0;
    end

    always_ff @(posedge clk) begin
        if(rst) begin
            clk_pos <= Divisor == 2;
            clk_neg <= 1'b0;
            clk_out <= 1'b1;
        end else begin
            clk_neg <= (counter == 1);
            clk_pos <= (counter == DivBits'((Divisor+1)/2+1));
        end
    end

    initial clk_out = 1'b1;
    always_ff @(posedge clk) begin
        if(rst)
            clk_out <= 1'b1;
        else if(clk_pos)
            clk_out <= 1'b1;
        else if(clk_neg)
            clk_out <= 1'b0;
    end
end endgenerate

endmodule
