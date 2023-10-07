module instruction_memory #(
    parameter MemSize = 512,
    parameter Width = 32
)(
    input logic clk,
    input logic [Width-1:0] address,
    input logic valid,
    output logic [Width-1:0] data
);

localparam WordSizeBits = $clog2(Width) - 3;
reg [Width-1:0] mem[MemSize - 1:0];

initial begin
    //$readmemh("instructions.mem", mem);
    $readmemh("ldst.mem", mem);

    // for(integer index = 0; index < 60; index = index + 1) begin
    //     $display("value at %d = %h", index, mem[index]);
    // end
end

always @(*) begin
    if(valid) begin
        data = mem[address[($clog2(MemSize)+WordSizeBits-1):WordSizeBits]];
    end else begin
        data = 0;
    end
end

endmodule
