module bus_width_adapter #(
    parameter AddrBusWidth = 32,
    parameter BusWidthA = 32,
    parameter BusWidthB = 64
) (
//    input logic clk,
    input logic[AddrBusWidth-1:0] addr,

    output logic[BusWidthA-1:0] r_data_a,
    input logic[BusWidthA-1:0] w_data_a,
    input logic[(BusWidthA/8)-1:0] w_sel_a,

    input logic[BusWidthB-1:0] r_data_b,
    output logic[BusWidthB-1:0] w_data_b,
    output logic[(BusWidthB/8)-1:0] w_sel_b
);

initial begin
    if(BusWidthB < BusWidthA )
        $error("Tried to initialize a narrowing bus width adjuster");

    if( (BusWidthB/BusWidthA)*BusWidthA != BusWidthB )
        $error("BusWidthB must be a multiple of BusWidthA");
end

generate
    if(BusWidthB > BusWidthA) begin : gen
        localparam Factor = BusWidthB/BusWidthA;
        localparam FactorBits = $clog2(Factor);
        localparam SegmentMSB = $clog2(BusWidthB/8) - 1;
        localparam SegmentLSB = $clog2(BusWidthA/8);

        wire logic [SegmentMSB:SegmentLSB] segment = addr[SegmentMSB:SegmentLSB];
        assign r_data_a = r_data_b[(segment*BusWidthA) +: BusWidthA];

        for(genvar ix = 0; ix < Factor; ++ix) begin
            assign w_sel_b[(ix*BusWidthA/8) +: (BusWidthA/8)] = (ix == segment) ? w_sel_a : 0;
            assign w_data_b[(ix*BusWidthA) +: BusWidthA] = (ix == segment) ? w_data_a : 0;
         end
    end else begin
        assign r_data_a = r_data_b;
        assign w_data_b = w_data_a;
        assign w_sel_b = w_sel_a;
    end
endgenerate

endmodule

module test;
    logic [7:0] addr;

    logic [7:0] r_data_a;
    logic [7:0] w_data_a;
    logic [0:0] w_sel_a;

    logic [31:0] r_data_b;
    logic [31:0] w_data_b;
    logic [3:0] w_sel_b;

    bus_width_adapter #(.AddrBusWidth(8), .BusWidthA(8), .BusWidthB(32)) bwa(
        .addr,
        .r_data_a, .w_data_a, .w_sel_a,
        .r_data_b, .w_data_b, .w_sel_b
    );

    initial begin
        // Dump waves
        $dumpfile("dump.vcd");
        $dumpvars(1, test);

        r_data_b = 32'b1101_1101_0010_0010_0101_1010_1111_0000;
        w_sel_a = 1'b1;

        addr = 8'b10100001;

        #10; addr = 8'b10100000;

        #10; addr = 8'b10100010;

        #10; addr = 8'b10100011;

        #10 $finish;
    end

    initial $monitor("%t %b: a: %b - b %b - segment %d", $time, addr, r_data_a, r_data_b, bwa.gen.segment);
endmodule
