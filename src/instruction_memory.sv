module instruction_memory #(
    parameter MemSize = 512,
    parameter Width = 32
)(
    input logic clk,
    input logic [Width-1:0] address,
    input logic valid,
    output logic [Width-1:0] data,
    output logic ready,
    output logic done
);

localparam WordSizeBits = $clog2(Width) - 3;
reg [Width-1:0] mem[MemSize - 1:0];

initial begin
    $readmemh("instructions.mem", mem);
    // $readmemh("ldst.mem", mem);

    // for(integer index = 0; index < 60; index = index + 1) begin
    //     $display("value at %d = %h", index, mem[index]);
    // end
end

always @(*) begin
    ready = 0'b1;

    if(valid) begin
        data = mem[address[($clog2(MemSize)+WordSizeBits-1):WordSizeBits]];
        done = 1'b1;
    end else begin
        data = 0;
        done = 1'b0;
    end
end

endmodule
