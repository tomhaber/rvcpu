module top();

logic clk;
logic rst;

logic [7:0]data;
logic data_valid;

logic uart_out;
logic uart_ready;


uart_tx #(.ClockDivider(10)) tx (
    .clk(clk), .rst(rst),
    .data_in(data), .data_in_valid(data_valid),
    .out_bit(uart_out), .ready(uart_ready)
);

initial begin
    clk = 0;
    forever begin
        #20 clk = 1'b1;
        #20 clk = 1'b0;
    end
end

initial begin
    // Dump waves
    $dumpfile("dump.vcd");
    $dumpvars(1, test);

    rst = 1'b1;
    #100 rst = 1'b0;

    #100000 $finish;
end

int index = 0;
string str = "Hello world\n";

always_ff@(posedge clk)
begin
    if(rst) begin
        index = 0;
        data_valid = 0;
    end else begin
        data = str[index];

        if( uart_ready ) begin
            if( index<str.len() ) begin
                data_valid = 1;
                index++;
            end else begin
                data_valid = 0;
            end
        end
    end
end

logic[7:0] received_data;
logic data_received, break_recv, error;
uart_rx#(.ClockDivider(10)) rx (
    .clk(clk), .rst(rst),
    .input_bit(uart_out),
    .data_out(received_data), .data_valid(data_received),
    .break_received(break_recv), .error(error)
);
endmodule
