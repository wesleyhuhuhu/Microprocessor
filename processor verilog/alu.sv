module alu (
    input logic [7:0] inputA, inputB,
    input logic [4:0] operation,

    output logic [7:0] result,
    output logic equal, less
);

always_comb begin
    case(operation)
        //LSL
        5'b10000:
            result = inputA << inputB;
        //LSR 
        5'b10001:
            result = inputA >> inputB;
        //AND
        5'b00000:
            result = inputA & inputB;
        //OR
        5'b00001:
            result = inputA | inputB;
        //NOT
        5'b00010:
            result = (!inputA);
        //XOR
        5'b00011:
            result = inputA ^ inputB;
        //ADD
        5'b00100:
            result = inputA + inputB;
        //SUB
        5'b00101:
            result = inputA - inputB;
        //EOR
        5'b00110:
            result = ^inputA;
        default:
            result = 8'b11111111;
    endcase
    equal = (inputA == inputB);
    less  = (inputA < inputB);
end
endmodule