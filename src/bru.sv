module bru #(
    parameter Width = 32
) (
    input logic is_branch,
    input logic is_jal,
    input logic [Width-1:0] pc,
    output logic [Width-1:0] next_pc
);

next_pc = pc + 'b100;
endmodule
