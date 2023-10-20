localparam AddrWidth = 32;
localparam CacheBusWidth = 32;
localparam MemBusWidth = 64;

module top ();

reg clk;
reg rst;

reg [AddrWidth-1:0] addr;
wire logic[CacheBusWidth-1:0] r_data;
reg [CacheBusWidth-1:0] w_data;
wire logic busy;
wire logic done;
reg re;
reg we;

wire logic [AddrWidth-1:0] mem_addr;
reg [MemBusWidth-1:0] mem_r_data;
wire [MemBusWidth-1:0] mem_w_data;
reg mem_busy = 1'b0;
reg mem_done = 1'b0;
wire logic mem_re;
wire logic mem_we;

cache #(
    .AddrBusWidth(AddrWidth),
    .CacheBusWidth(CacheBusWidth),
    .MemBusWidth(MemBusWidth),
    .N(512)
) cache(
    .clk(clk), .rst(rst),
    .mem_addr(mem_addr),
    .mem_r_data(mem_r_data),
    .mem_w_data(mem_w_data),
    .mem_busy(mem_busy),
    .mem_done(mem_done),
    .mem_re(mem_re),
    .mem_we(mem_we),
    .addr(addr),
    .r_data(r_data), .w_data(w_data),
    .re(re), .we(we),
    .busy(busy), .done(done)
);

integer misses = 0;
integer count = 0;
integer fp;
integer temp;

initial begin
    string fname;
    if(!$value$plusargs("trace=%s", fname))
        fname = "traces/gcc.txt";

    fp = $fopen(fname, "r");
    clk = 0;
    re = 0;
    we = 0;
    misses = 0;
    count = 0;

    rst = 1;
    #10 rst = 0;

// #200 $finish;
end

always @(posedge clk) begin
    if(!busy) begin
        if(!$feof(fp)) begin
            temp = $fscanf(fp,"%h\n",addr);
            re = 1'b1;
            count = count + 1;
            $display("%d %d %h %d", $time, count, addr, misses);
        end else begin
            $fclose(fp);
            $finish;
        end
    end
end

always @(mem_re) begin
    if(mem_re) begin
        mem_r_data = {(MemBusWidth/32){$random}};
        mem_done = 1'b1;
        misses = misses + 1;
    end else begin
        mem_done = 1'b0;
    end
end

always begin
    #2 clk = ~clk;
end

endmodule
