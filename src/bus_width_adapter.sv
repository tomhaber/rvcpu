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

        logic idle;
        logic [FactorBits-1:0] segment;
        localparam MaxCount = (FactorBits)'(Factor - 1);

        always_comb begin
            addr_b = {addr_a[AddrBusWidth-1:SegmentBits], segment, {WordBits{1'b0}}};
            w_sel_b = w_sel_a[segment*BusWidthB/8 +: (BusWidthB/8)];
            w_data_b = w_data_a[segment*BusWidthB +: BusWidthB];

            re_b = re_a && !idle;
            we_b = we_a && !idle;

            ready_a = idle;
            r_data_valid_a = re_a && idle;
        end

        always_ff @(posedge clk or posedge rst) begin
            if(rst) begin
                segment <= 0;
                idle <= 1'b1;
            end else if(idle && (re_a || we_a)) begin
                segment <= 0;
                idle <= 1'b0;
            end else if(!idle && ((re_a && r_data_valid_b) || (we_a && ready_b))) begin
                idle <= (segment == MaxCount);
                segment <= segment + 1;

                if(re_a && r_data_valid_b) begin
                    $display("%t buffer %d %h", $realtime, segment, r_data_b);
                    buffer[segment] <= r_data_b;
                end
            end
        end
    end
endgenerate

endmodule

module test;
    logic clk;
    logic rst;

    logic [7:0] addr_a;
    logic [31:0] r_data_a;
    logic [31:0] w_data_a;
    logic [3:0] w_sel_a;
    logic re_a, we_a;
    logic ready_a, r_data_valid_a;

    logic [7:0] addr_b;
    logic [7:0] r_data_b;
    logic [7:0] w_data_b;
    logic [0:0] w_sel_b;
    logic re_b, we_b;
    logic ready_b, r_data_valid_b;

    bus_width_adapter #(.AddrBusWidth(8), .BusWidthA(32), .BusWidthB(8)) bwa(
        .clk, .rst,
        .addr_a, .r_data_a, .w_data_a, .w_sel_a, .re_a, .we_a, .ready_a, .r_data_valid_a,
        .addr_b, .r_data_b, .w_data_b, .w_sel_b, .re_b, .we_b, .ready_b, .r_data_valid_b
    );

    ram #(
        .AddrBusWidth(8),
        .DataBusWidth(8),
        .MemSizeBytes(256),
        .MemoryInitFile("instructions.mem")
    ) ram (
        .clk, .rst,
        .re(re_b), .r_addr(addr_b), .w_addr(addr_b),
        .we(we_b), .r_data(r_data_b), .w_data(w_data_b), .w_sel(w_sel_b)
    );

    assign r_data_valid_b = 1'b1;
    assign ready_b = 1'b1;

    initial begin
        // Dump waves
        $dumpfile("dump.vcd");
        $dumpvars(1, test);

        clk = 1'b0;

        rst = 1'b1;
        #20 rst = 1'b0;

        // r_data_b = 32'b1101_1101_0010_0010_0101_1010_1111_0000;
        // w_sel_a = 1'b1;

        #20;
        addr_a = 8'h08;
        re_a = 1'b1;

        @(posedge r_data_valid_a);
        addr_a = 8'h10;

        @(posedge r_data_valid_a);
        re_a = 1'b0;
        #20;
        we_a = 1'b1;
        addr_a = 8'h08;
        w_data_a = 32'hDEADBEEF;
        w_sel_a = 4'b1001;

        @(posedge ready_a);
        we_a = 1'b0;
        #20;
        re_a = 1'b1;
        addr_a = 8'h08;

        @(posedge r_data_valid_a);
        #20;
        $finish;
    end

    always #10 clk = ~clk;

    // initial $monitor("%t: a: %b = %b - b %b = %b", $time, addr_a, r_data_a, addr_b, r_data_b);
endmodule
