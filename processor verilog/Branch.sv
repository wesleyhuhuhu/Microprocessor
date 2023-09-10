//New branch module to set branch flags
module Branch (
    input clk,
    input reset,
    input logic equal, less, w_flag,
    input logic [2:0] flag,           //condition to update flags
    input logic branch_instr,             //condition to branch
    input logic [5:0] immediate,           //branch immediate
    output logic [9:0] address,        //branch addy
    output logic branch          //whether or not to branch
);

logic [2:0] flag_register;

// Check for every clk to update the flag_register
always_ff @(posedge clk) begin
    // Updates flag_register only if the w_flag is triggered
    if (w_flag)
        flag_register <= flag;
    if (reset)
        flag_register <= 3'b0;
end

always_comb begin
    // no branch instruction
    address = {1'b0, immediate, 3'b0};
    branch = 0;
    // if branch, check the flags
    if (branch_instr) begin
        branch = 1'b1;
        case (flag_register)
            3'b100: branch = 1'b1;
            3'b000: branch = !equal;
            3'b001: branch = equal;
            3'b010: branch = less;
            3'b011: branch = less | equal;
        endcase
    end
end

endmodule