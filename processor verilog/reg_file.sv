module reg_file(
    input   clk, reset,
    input logic[7:0] val_in,        
    input logic      write_en,   //reite to register
    input logic[3:0] wr_addr, rd_addr1, rd_addr2,

    output logic[7:0] outputA, outputB, regMem
);

// INTERNAL
logic[7:0] core[16];

logic[7:0] R8, R9, RA, RB, R0, R1, R2, R3, R4, R5, R6, R7, RC, RD, RE, RF;

assign R0 = core[4'b0000];
assign R1 = core[4'b0001];
assign R2 = core[4'b0010];
assign R3 = core[4'b0011];
assign R4 = core[4'b0100];
assign R5 = core[4'b0101];
assign R6 = core[4'b0110];
assign R7 = core[4'b0111];
assign R8 = core[4'b1000];
assign R9 = core[4'b1001];
assign RA = core[4'b1010];
assign RB = core[4'b1011];
assign RC = core[4'b1100];
assign RD = core[4'b1101];
assign RE = core[4'b1110];
assign RF = core[4'b1111];

assign outputA = core[rd_addr1];
assign outputB = core[rd_addr2];
assign regMem = RF; //RF always memory register

always_ff @(posedge clk) begin
    if (reset) begin
        for (int i = 0; i < 16; i=i+1) core[i] <= 0;
    end
    else begin
        if (write_en) core[wr_addr] <= val_in;
    end
end

endmodule