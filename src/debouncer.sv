module debouncer #(
    parameter Period = 2**16,
    parameter Count = 1
) (
    input logic clk,
    input logic [Count-1:0] sig_i,
    output logic [Count-1:0] sig_o
);

localparam PeriodBits = $clog2(Period);
localparam MaxPeriod = PeriodBits'(Period - 1);
typedef logic[PeriodBits-1:0] cntr_t;

generate
    for(genvar i = 0; i < Count; ++i) begin : cnts
        cntr_t cnt = 0;
        logic sig_out_reg = 1'b0;

        // counter
        always_ff @(posedge clk) begin
            if(sig_out_reg != sig_i[i]) begin
                if(cnt == MaxPeriod)
                    cnt <= 0;
                else
                    cnt <= cnt + 1;
            end else begin
                cnt <= 0;
            end
        end

        // debounce
        always_ff @(posedge clk) begin
            if(cnt == MaxPeriod)
                sig_out_reg <= ~sig_out_reg;
        end

        assign sig_o[i] = sig_out_reg;
    end
endgenerate

endmodule
