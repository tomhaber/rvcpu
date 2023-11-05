module bus_width_adapter #(
    parameter AddrBusWidth = 32,
    parameter BusWidthA = 32,
    parameter BusWidthB = 64
) (
    input logic clk,
    input logic rst,

    input logic[AddrBusWidth-1:0] addr_a,
    output logic[BusWidthA-1:0] r_data_a,
    input logic[BusWidthA-1:0] w_data_a,
    input logic[(BusWidthA/8)-1:0] w_sel_a,
    input logic re_a,
    input logic we_a,
    output logic ready_a,
    output logic r_data_valid_a,

    output logic[AddrBusWidth-1:0] addr_b,
    input logic[BusWidthB-1:0] r_data_b,
    output logic[BusWidthB-1:0] w_data_b,
    output logic[(BusWidthB/8)-1:0] w_sel_b,
    output logic re_b,
    output logic we_b,
    input logic ready_b,
    input logic r_data_valid_b
);

initial begin
    if( (BusWidthB > BusWidthA) && (BusWidthB/BusWidthA)*BusWidthA != BusWidthB )
        $error("BusWidthB must be a multiple of BusWidthA");
    if( (BusWidthA > BusWidthB) && (BusWidthA/BusWidthB)*BusWidthB != BusWidthA )
        $error("BusWidthA must be a multiple of BusWidthB");
end

generate
    if(BusWidthB > BusWidthA) begin : gen
        localparam Factor = BusWidthB/BusWidthA;
        localparam FactorBits = $clog2(Factor);
        localparam SegmentMSB = $clog2(BusWidthB/8) - 1;
        localparam SegmentLSB = $clog2(BusWidthA/8);

        wire logic [SegmentMSB:SegmentLSB] segment = addr_a[SegmentMSB:SegmentLSB];
        assign r_data_a = r_data_b[(segment*BusWidthA) +: BusWidthA];

        for(genvar ix = 0; ix < Factor; ++ix) begin
            assign w_sel_b[(ix*BusWidthA/8) +: (BusWidthA/8)] = (ix == segment) ? w_sel_a : 0;
            assign w_data_b[(ix*BusWidthA) +: BusWidthA] = (ix == segment) ? w_data_a : 0;
        end

        assign re_b = re_a;
        assign we_b = we_a;
        assign ready_a = ready_b;
        assign r_data_valid_a = r_data_valid_b;
        assign addr_b = addr_a;
    end else if(BusWidthA == BusWidthB) begin : gen
        assign r_data_a = r_data_b;
        assign w_data_b = w_data_a;
        assign w_sel_b = w_sel_a;

        assign re_b = re_a;
        assign we_b = we_a;
        assign ready_a = ready_b;
        assign r_data_valid_a = r_data_valid_b;
        assign addr_b = addr_a;
    end else begin : gen
        localparam Factor = BusWidthA/BusWidthB;
        localparam FactorBits = $clog2(Factor);
        localparam SegmentBits = $clog2(BusWidthA/8);
        localparam WordBits = $clog2(BusWidthB/8);

        logic [Factor-1:0] [BusWidthB-1:0] buffer;
        assign r_data_a = buffer;

        logic idle, next_idle;
        logic [FactorBits-1:0] segment;
        localparam MaxCount = (FactorBits)'(Factor - 1);

        always_comb begin
            addr_b = {addr_a[AddrBusWidth-1:SegmentBits], segment, {WordBits{1'b0}}};
            w_sel_b = w_sel_a[segment*BusWidthB/8 +: (BusWidthB/8)];
            w_data_b = w_data_a[segment*BusWidthB +: BusWidthB];
        end

        always_ff @(posedge clk) begin
            if(idle)
                segment <= 0;
            else
                segment <= segment + 1;
        end

        wire logic r_done = (re_a && r_data_valid_b);
        wire logic w_done = (we_a && ready_b);

        always_comb begin
            if(r_done || w_done)
                next_idle = (segment == MaxCount);
            else if((re_a || we_a))
                next_idle = 1'b0;
            else
                next_idle = idle;
        end

        always_ff @(posedge clk or posedge rst) begin
            if(rst)
                idle <= 1'b1;
            else
                idle <= next_idle;

            if(r_done) begin
                buffer[segment] <= r_data_b;
            end
        end

        always_comb begin
            re_b = re_a && !next_idle;
            we_b = we_a && !next_idle;

            ready_a = (!idle && next_idle);
            r_data_valid_a = re_a && (!idle && next_idle);
        end
    end
endgenerate

endmodule
