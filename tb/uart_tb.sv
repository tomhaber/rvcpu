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
    $dumpvars(1, top);

    rst = 1'b1;
    #100 rst = 1'b0;

    #100000 $finish;
end

logic[7:0] received_data;
logic data_received, break_recv, error;

uart_rx#(.ClockDivider(10)) rx (
    .clk(clk), .rst(rst),
    .input_bit(uart_out),
    .data_out(received_data), .data_valid(data_received),
    .break_received(break_recv), .error(error)
);

int tx_ind = 0;
int rx_ind = 0;
string str = "Hello world\n";

always_ff@(posedge clk) begin
    if(rst) begin
        tx_ind <= 0;
        rx_ind <= 0;
        data_valid <= 0;
    end else begin
        data = str[tx_ind];
        data_valid <= ( tx_ind < str.len() );

        if( data_valid && uart_ready ) begin
            if( tx_ind < str.len() ) begin
                tx_ind <= tx_ind + 1;
            end
        end
    end
end

always_ff@(posedge clk) begin
    if(data_received) begin
        if(str[rx_ind] != received_data)
            $error("wrong data received");
        rx_ind++;
    end

    if(error || break_recv)
        $error("error or break received");
end

endmodule
