//This file defines the parameters used in the alu
// CSE141L
//	Rev. 2022.5.27
// import package into each module that needs it
//   packages very useful for declaring global variables
// need > 8 instructions?
// typedef enum logic[3:0] and expand the list of enums
package Definitions;
    
// enum names will appear in timing diagram
// ADD = 3'b000; LSH = 3'b001; etc. 3'b111 is undefined here
  typedef enum logic[2:0] {
      ADD = 3'b010, LSL = 3'b110, XOR = 3'b100,
      AND = 3'b101, SUB = 3'b011, MOV = 3'b111 } op_mne;
    
endpackage // definitions