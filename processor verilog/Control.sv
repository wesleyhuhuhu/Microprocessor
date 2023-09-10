module Control #(parameter opwidth = 9)(
  input [opwidth-1:0] instr,    //instruction code
  output logic Branch, MemtoReg, MemWrite, ALUSrc, RegWrite, FlagWrite, Immed,
  output logic[2:0] Flag,
  output logic[3:0] ReadAddr1, ReadAddr2, WriteAddr,
  output logic[4:0] ALUOp);	   //32 ALU operations

always_comb begin
  ReadAddr1 = 'b1000;
  ReadAddr2 = 'b1001;
  WriteAddr = 'b0000;
  Branch = 'b0;
  MemWrite = 'b0;
  ALUSrc =	'b0;  //immediate
  RegWrite = 'b0;
  MemtoReg = 'b0;  //load
  ALUOp	= 'b11111;
  FlagWrite = 'b0; //update branch flags
  Flag = 'b000;
  Immed = 'b0;
    
//check what instruction it is and update flags
  if (instr[8] == 0) begin       //MOV
    ReadAddr1 = instr[3:0];
    ReadAddr2 = instr[3:0];
    WriteAddr = instr[7:4];
    ALUOp = 'b00000;
    RegWrite = 'b1;
  end

  else if (instr[8:6] == 'b100) begin     //branch
    Branch = 'b1;
    Immed = 'b1;
  end

  else if (instr[8:6] == 'b101) begin   //SET
    Immed = 'b1;
    RegWrite = 'b1;
    WriteAddr = 'b1111;
  end

  else if (instr[8:6] == 'b110) begin   //LSL and LSR
    WriteAddr = {2'b10, instr[4:3]};      //reg write dest
    ALUSrc = (instr[2:0] == 0) ? 0 : 1;
    RegWrite = 'b1;
    case(instr[5])
    'b0:                        //LSL
      ALUOp = 'b10000;
    'b1:                        //LSR
      ALUOp = 'b10001;
    endcase
  end
  else if (instr[8:4] == 'b11110) begin   //LOAD and STORE
    ReadAddr1 = {1'b0, instr[2:0]};
    ReadAddr2 = {1'b0, instr[2:0]};
    ALUOp = 'b00000;
    case(instr[3])
      'b0:                    //LOAD
      begin
        WriteAddr = 'b1111;
        RegWrite = 'b1;
        MemtoReg = 'b1;
      end
      'b1:                     //STORE
      begin
        MemWrite = 'b1;
      end
    endcase
  end
  else if (instr[8:5] == 'b1110 && instr[4:3] == 'b11) begin  //set branch flags
    FlagWrite = 'b1;
    case(instr[2:0])
    'b000:                      
      Flag = instr[2:0];      //NE
    'b001:                          
      Flag = instr[2:0];      //SBFEG
    'b010:
      Flag = instr[2:0];      //SBFLT
    'b011:
      Flag = instr[2:0];      //SBFLE
    'b100:
      Flag = instr[2:0];      //SBFJP
    endcase
  end 
  else if (instr[8:5] == 'b1110 && instr[4:3] != 'b11) begin //ALU instructions
    WriteAddr = {2'b10, instr[1:0]};
    RegWrite = 'b1;
    case(instr[4:2])
    'b000:                //AND
      ALUOp = 'b00100;
    'b001:                //SUB
      ALUOp = 'b00101;
    'b010:               //AND
      ALUOp = 'b00000;
    'b011:                //OR
      ALUOp = 'b00001;
    'b100:                //NOT
      ALUOp = 'b00010;
    'b101:                //XOR
      ALUOp = 'b00011;
    default:
      ALUOp = 'b11111;
    endcase
  end
  else if (instr[8:4] == 'b11111) begin
    WriteAddr = {2'b10, instr[1:0]}; //Only writes to R8, R9, RA, or RB
    RegWrite = 'b1;
    case(instr[3:2])
    'b00:                     //XOR the byte
      ALUOp = 'b00110;
    default:
      ALUOp = 'b11111;
    endcase
  end

end
	
endmodule