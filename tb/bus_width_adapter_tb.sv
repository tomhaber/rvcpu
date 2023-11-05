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

    logic [31:0] expected_a;

    bus_width_adapter #(.AddrBusWidth(8), .BusWidthA(32), .BusWidthB(8)) bwa(
        .clk, .rst,
        .addr_a, .r_data_a, .w_data_a, .w_sel_a, .re_a, .we_a, .ready_a, .r_data_valid_a,
        .addr_b, .r_data_b, .w_data_b, .w_sel_b, .re_b, .we_b, .ready_b, .r_data_valid_b
    );

    ram #(
        .AddrBusWidth(8),
        .DataBusWidth(8),
        .MemSizeBytes(256),
        .MemoryInitFile("test.mem")
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
        #30 rst = 1'b0;

        // r_data_b = 32'b1101_1101_0010_0010_0101_1010_1111_0000;
        // w_sel_a = 1'b1;

        #20;
        addr_a = 8'h08;
        re_a = 1'b1;
        expected_a = 32'he2e8ae37;

        @(posedge r_data_valid_a);
        // if(r_data_a != expected_a)
            // $error("wrong data read %h != %h", r_data_a, expected_a);
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
