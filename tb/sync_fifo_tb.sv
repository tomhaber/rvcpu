`define CLK @(negedge clk)
module sync_fifo_tb;

typedef logic[7:0] data_t;
localparam LogDepth = 1;

logic clk;
logic reset;
logic push_i;
data_t push_data_i;
logic pop_i;
data_t pop_data_o;
logic full_o;
logic empty_o;

sync_fifo #(.T(data_t), .LogDepth(LogDepth)) fifo (
    .clk(clk), .rst(reset),
    .we(push_i), .w_data(push_data_i), .full(full_o),
    .re(pop_i), .r_data(pop_data_o), .empty(empty_o)
);

// Generate clock
initial begin
    clk = 1'b0;

    forever begin
        #5 clk = ~clk;
    end
end

// Drive our stimulus
initial begin
    reset = 1'b1;
    push_i = 1'b0;
    pop_i = 1'b0;
    repeat (2) @(posedge clk);
    reset = 1'b0;

    if(!empty_o) $error("fifo is not empty");

    `CLK;
    push_i = 1'b1;
    push_data_i = 8'hAB;
    `CLK;
    push_data_i = 8'hCC;
    `CLK;
    push_i = 1'b0;

    if(!full_o) $error("fifo is not full");
    push_i = 1'b1;
    push_data_i = 8'hx;
    `CLK;
    push_i = 1'b0;

    pop_data(8'hAB);
    repeat (2) `CLK;
    pop_data(8'hCC);

    if(!empty_o) $error("fifo is not empty");
    `CLK;
    pop_i = 1'b1;
    push_i = 1'b1;
    push_data_i = 8'hFF;
    `CLK;
    pop_i = 1'b0;
    push_i = 1'b0;

    repeat(2) `CLK;
    $finish();
end

task pop_data(input data_t expected);
    if(empty_o) $error("popping from empty fifo");
    pop_i = 1'b1;
    `CLK;
    pop_i = 1'b0;
    if(expected != pop_data_o) $error("popped unexpected data %h (%h)", pop_data_o, expected);
endtask

// Dump VCD waves
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(2, sync_fifo_tb);
end

endmodule
