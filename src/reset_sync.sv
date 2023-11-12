module reset_sync #(
    parameter ResetActiveState = 1, // Active low (0) or active high (>0)
    parameter ExtraDepth = 0
) (
    input logic clk,
    input logic reset_in,
    output logic reset_out
);

localparam Depth = 2 + ExtraDepth;
localparam ActiveLow = ResetActiveState === 0;
localparam Active = (ActiveLow) ? 1'b0 : 1'b0;

(* IOB = "false" *)
(* ASYNC_REG = "TRUE" *)
logic [Depth-1:0] sync_reg;

initial begin
    integer i;
    for(i = 0; i < Depth; ++i)
        sync_reg[i] = ~Active;
end

generate
    integer i;
    if(ActiveLow) begin
        always_ff @(posedge clk or negedge reset_in) begin
            if(~reset_in) begin
                for(i = 0; i < Depth; ++i)
                    sync_reg[i] <= Active;
            end else begin
                sync_reg[0] <= ~Active;
                for(i = 1; i < Depth; ++i)
                    sync_reg[i] <= sync_reg[i-1];
            end
        end
    end else begin
        always_ff @(posedge clk or posedge reset_in) begin
            if(reset_in) begin
                for(i = 0; i < Depth; ++i)
                    sync_reg[i] <= ~Active;
            end else begin
                sync_reg[0] <= Active;
                for(i = 1; i < Depth; ++i)
                    sync_reg[i] <= sync_reg[i-1];
            end
        end
    end

endgenerate

assign reset_out = sync_reg[Depth-1];

endmodule
