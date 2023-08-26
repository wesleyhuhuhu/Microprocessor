/* CSE141L
   possible lookup table for PC target
   leverage a few-bit pointer to a wider number
   Lookup table acts like a function: here Target = f(Addr);
 in general, Output = f(Input); lots of potential applications 
*/
module Immediate_LUT #(PC_width = 10)(
  input               [ 5:0] Addr,
  output logic[PC_width-1:0] Target
  );

always_comb begin
  Target = 'h001;	          // default to 1 (or PC+1 for relative)
  case(Addr)		   
	6'b000001:  Target = 28;   // 16, i.e., move back 16 lines of machine code
	6'b000010:	 Target = 51;
	6'b000011:	 Target = 75;
	6'b000100:	 Target = 28;
	6'b000101:	 Target = 8;
	6'b000110:	 Target = 98;
  6'b000111:	 Target = 53;
  6'b001000:	 Target = 81;
  6'b001001:	 Target = 105;
  6'b001010:	 Target = 117;
  6'b001011:	 Target = 121;
  6'b001100:	 Target = 137;
  6'b001101:	 Target = 145;
  endcase
end

endmodule


			 // 3fc = 1111111100 -4
			 // PC    0000001000  8
			 //       0000000100  4  