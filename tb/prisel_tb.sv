module test;

logic clk;
logic rst;
logic enable;
logic[3:0] inb;
logic valid;

typedef struct packed {
    logic a;
    logic[1:0] b;
} input_t;

typedef struct packed {
    logic[1:0] x;
} output_t;

input_t ins[4];
output_t outs[4];

input_t sel_i;
output_t sel_o;

prisel #(
    .NumPorts(4),
    .T(input_t),
    .O(output_t)
) pri_sel (
    .clk(clk), .rst(rst), .enable(enable),
    .inb(inb), .valid(valid),
    .ins(ins), .sel_i(sel_i),
    .outs(outs), .sel_o(sel_o)
);

initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1, test);

    ins = {
        '{a: 1'b0, b:2'b00},
        '{a: 1'b1, b:2'b01},
        '{a: 1'b0, b:2'b10},
        '{a: 1'b1, b:2'b11}
    };

    clk = 0;
    enable = 0;
    rst = 1;
    #10 rst = 0;

    inb = 4'b1001;
    #5 enable = 1;
    #10 sel_o = 2'b10;

    # 5 inb = 4'b0010;
    #10 sel_o = 2'b01;

    #10 $finish;
end

always #5 clk = ~clk;
endmodule
