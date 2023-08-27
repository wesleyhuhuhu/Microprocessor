// Module Name:    ALU
// Project Name:   CSE141L
//
// Additional Comments:
//   combinational (unclocked) ALU

// includes package "Definitions"
// be sure to adjust "Definitions" to match your final set of ALU opcodes
import Definitions::*;

module ALU #(parameter W=8)(
  input        [W-1:0]   InputA,       // data inputs
                         InputB,
  input        [2:0]    OP,           // ALU opcode, part of microcode
  input                  SC_in,        // shift or carry in
                         MOV_Dest_acc, // 0: output = InputB, 1: output = InputA
  output logic [W-1:0]   Out,          // data output
  output logic           Zero,         // output = zero flag    !(Out)
                         Parity,       // outparity flag        ^(Out)
                         Odd,          // output odd flag        (Out[0])
						 SC_out        // shift or carry out
  // you may provide additional status flags, if desired
  // comment out or delete any you don't need
);

op_mne op_mnemonic;	

always_comb begin
// No Op = default
// add desired ALU ops, delete or comment out any you don't need
  Out = InputA;				                        // don't need NOOP? Out = 8'bx
  SC_out = 1'b0;		 							          // 	 will flag any illegal opcodes
  case(op_mnemonic)
    //ADD : {SC_out,Out} = InputA + InputB;   // unsigned add with carry-in and carry-out
    //LSL : {SC_out,Out} = {InputA[7:0],SC_in};       // shift left, fill in with SC_in, fill SC_out with InputA[7]
    // for logical left shift, tie SC_in = 0
    //RSH : {Out,SC_out} = {SC_in, InputA[7:0]};      // shift right
	 //SUB : {SC_out,Out} = InputB + (~InputA) + 1;	// InputB - InputA (Accumulator);
	 AND : Out = InputA & InputB;                    // bitwise AND
    XOR : Out = InputA ^ InputB;                    // bitwise exclusive OR
	 ROL : Out = {InputA[6:0],InputA[7]};						// shift left, fill in with SC_in, fill SC_out with InputA[7:0]
    //MOV : Out = MOV_Dest_acc ? InputA : InputB;  // 
	 MOV : Out = InputB;  //MOV will always set output to InputB
  endcase
end

always_comb
    op_mnemonic = op_mne'(OP);

assign Zero   = ~|Out;                  // reduction NOR	 Zero = !Out; 
assign Parity = ^Out;                   // reduction XOR
assign Odd    = Out[0];                 // odd/even -- just the value of the LSB

endmodule
