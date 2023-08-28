// control decoder
module Control #(parameter opwidth = 3, mcodebits = 9)(
  input [mcodebits-1:0] instr,    // subset of machine code (any width you need)
  output logic RegDst, Branch, 
     MemtoReg, MemWrite, ALUSrc, RegWrite,
  output logic[opwidth-1:0] ALUOp);	   // for up to 8 ALU operations

always_comb begin
// defaults
  RegDst 	=   'b0;   // 1: not in place  just leave 0
  Branch 	=   'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  ALUOp	    =   'b111; // y = a+0;
// sample values only -- use what you need

	if(instr[8:6] == 3'b110) begin	//SET
		ALUSrc = 'b1;
		RegWrite = 'b1;
		ALUOp = 3'b110;
		RegWrite  =	'b1;
		MemWrite  =	'b0;
	end
	else if (instr[8:6] == 3'b000) begin	//LOAD or STORE
		if (instr[2] == 0) begin	//LOAD
			ALUSrc = 'b0;
			MemWrite = 'b0;
			RegWrite = 'b1;
			MemtoReg = 'b1;
		end
		else begin	//STORE
			ALUSrc = 'b0;
			MemWrite = 'b1;
			MemtoReg = 'b0;
		end
	end
	else begin		//ALL OTHER ALU Ops
		ALUSrc = 'b0;
		case(instr[8:6])    // override defaults with exceptions
		   'b001:  begin					// ADD
						MemtoReg = 'b0;   
						MemWrite = 'b0;      // write to data mem
						RegWrite = 'b0;      // typically don't also load reg_file
						ALUOp = 3'b001;
					 end
					 
		   'b010:  begin					// AND
						MemtoReg = 'b0;    
						ALUOp      = 3'b010;
						RegWrite = 'b1;
						MemWrite = 'b0;
					 end
					 
		   'b011:  begin				  // XOR
						MemtoReg = 'b0;    
						ALUOp      = 3'b011;
						RegWrite = 'b1;
						MemWrite = 'b0;
					 end
					 
			'b100:  begin				  // ROL
						MemtoReg = 'b0;    
						ALUOp      = 3'b100;
						RegWrite = 'b1;
						MemWrite = 'b0;
					 end
					 
			'b111:  begin				  // MOV
						MemtoReg = 'b0;    
						ALUOp      = 3'b111;
						RegWrite = 'b1;
						MemWrite = 'b0;
					 end
		endcase
	end
end
	
endmodule