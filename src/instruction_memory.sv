module instruction_memory #(
    parameter MemSize = 512,
    parameter Width = 32
)(
    input logic clk,
    input logic [Width-1:0] address,
    input logic valid,
    output logic [Width-1:0] data
);

reg [Width-1:0] mem[MemSize - 1:0];

initial begin
    $readmemh("instructions.mem", mem);

    // for(integer index = 0; index < 60; index = index + 1) begin
    //     $display("value at %d = %h", index, mem[index]);
    // end
end

always_ff @( posedge clk ) begin
    if(valid) begin
        data = mem[address / 4];
    end
end

endmodule
