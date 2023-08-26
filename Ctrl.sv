// CSE141L
import Definitions::*;
// control decoder (combinational, not clocked)
// inputs from instrROM, ALU flags
// outputs to program_counter (fetch unit)
module Ctrl (
  input[ 8:0]   Instruction,	   // machine code
  input[ 7:0]   DatMemAddr,
  output logic  Branch    ,
                BranchEn  ,
			    RegWrEn   ,	   // write to reg_file (common)
			    MemWrEn   ,	   // write to mem (store only)
			    LoadInst  ,	   // mem or ALU to reg_file ?
			    TapSel    ,
			    Ack		  ,      // "done w/ program"
          Immediate,
  output logic[5:0] PCTarg,
  output logic[2:0] RegWriteIndex
//  output logic[2:0]  ALU_inst
  );

/* ***** All numerical values are completely arbitrary and for illustration only *****
*/

// alternative -- case format
always_comb	begin
// list the defaults here
   Branch    = 'b0;
   BranchEn  = 'b0;
   RegWrEn   = 'b1; 
   MemWrEn   = 'b0;
   LoadInst  = 'b0;
   PCTarg    = 'b0;     // branch "where to?"
   Immediate = 'b0;

   if ((Instruction[0] == 'b1) && (!(&Instruction))) begin
       Immediate = 'b1;
   end
   else if ((Instruction[8] == 'b1) && (!(&Instruction))) begin
       Branch = Instruction[7]; //Absolute Branching ([7] == 1)
       BranchEn = !Instruction[7]; //Relative Branching ([7] == 0)
       RegWrEn = 'b0;
       PCTarg = Instruction[6:1];
   end
   else begin
    case(Instruction[7:5])  // list just the exceptions 
     3'b000:   begin
                MemWrEn = 'b1;   // store
                RegWrEn = 'b0;
			         end
     3'b001:   begin
                LoadInst = 'b1;  // load
               end
     3'b010:   begin end
     3'b011:   begin end
     3'b100:   begin end
     3'b101:   begin
                RegWrEn = Instruction[1]; //disable regwrite to do LFSR
               end
     3'b110:   begin end
// no default case needed -- covered before "case"
   endcase
  end
end

// assign Ack = ProgCtr == 971;
// alternative Ack = Instruction == 'b111_000_111

// ALU commands
// assign ALU_inst = Instruction[2:0]; 

// STR commands only -- write to data_memory
// assign MemWrEn = Instruction[8:6]==3'b110;

// all but STR and NOOP (or maybe CMP or TST) -- write to reg_file
// assign RegWrEn = Instruction[8:7]!=2'b11;

// route data memory --> reg_file for loads
//   whenever instruction = 9'b110??????; 
// assign LoadInst = Instruction[8:6]==3'b110;  // calls out load specially

assign TapSel = LoadInst &&	 DatMemAddr=='d62;

assign RegWriteIndex = Instruction[1]? Instruction[4:2] : 3'b000;  // 2:1 switch into reg_file

// jump enable command to program counter / instruction fetch module on right shift command
// equiv to simply: 
// assign Jump = Instruction[2:0] == RSH;
// always_comb
//   if(Instruction[2:0] ==  RSH)
//     Branch = 1;
//   else
//     Branch = 0;

// // branch every time instruction = 9'b?????1111;
// assign BranchEn = &Instruction[3:0];

// // whenever branch or jump is taken, PC gets updated or incremented from "Target"
// //  PCTarg = 2-bit address pointer into Target LUT  (PCTarg in --> Target out
// assign PCTarg  = Instruction[3:2];

// reserve instruction = 9'b111111111; for Ack
assign Ack = &Instruction; // = ProgCtr == 385;

endmodule

