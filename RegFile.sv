// Create Date:    2019.01.25
// Design Name:    CSE141L
// Module Name:    reg_file 
// Revision:       2022.05.04
// Additional Comments: 	allows preloading with user constants
// This version is fully synthesizable and highly recommended.

/* parameters are compile time directives 
       this can be an any-width, any-depth reg_file: just override the params!
*/
module RegFile #(parameter W=8, D=3)(		 // W = data path width (leave at 8); D = address pointer width
  input                Clk,
                       Reset,	             // note use of Reset port
                       WriteEn,
                       Immediate,
  input        [W-1:0] ImmediateValue,
  input        [D-1:0] RaddrA,				 // address pointers
                       RaddrB,
                       Waddr,
  input        [W-1:0] DataIn,
  output       [W-1:0] DataOutA,			 // showing two different ways to handle DataOutX, for
  output logic [W-1:0] DataOutB,				 //   pedagogic reasons only
  output logic [W-1:0] AccumulatorValue,
  output logic [W-1:0] Reg1Value,
                       Reg2Value,
                       Reg3Value,
                       Reg4Value,
                       Reg5Value,
                       Reg6Value,
                       Reg7Value
    );

// W bits wide [W-1:0] and 2**4 registers deep 	 
logic [W-1:0] Registers[2**D];	             // or just registers[16] if we know D=4 always

// combinational reads 
/* can use always_comb in place of assign
    difference: assign is limited to one line of code, so
	always_comb is much more versatile     
*/
assign      DataOutA = Registers[RaddrA];	 // assign & always_comb do the same thing here 
always_comb DataOutB = Registers[RaddrB];    // can read from addr 0, just like ARM
assign      AccumulatorValue = Registers[3'b000];
assign      Reg1Value        = Registers[3'b001];
assign      Reg2Value        = Registers[3'b010];
assign      Reg3Value        = Registers[3'b011];
assign      Reg4Value        = Registers[3'b100];
assign      Reg5Value        = Registers[3'b101];
assign      Reg6Value        = Registers[3'b110];
assign      Reg7Value        = Registers[3'b111];


// sequential (clocked) writes 
always_ff @ (posedge Clk)
  if (Reset) begin
	for(int i=0; i<2**D; i++)
	  Registers[i] <= 'h0;
// we can override this universal clear command with desired initialization values
//	Registers[0] <= 'd30;                    // loads 30 (=0x1E) into RegFile address 0
//	Registers[2] <= 'b101;                   // loads 00000101 into RegFile address 2 
  end
  else if (WriteEn)	                         // works just like data_memory writes
    if (Immediate) begin
		Registers[3'b111] <= ImmediateValue;
    end
    else begin
      Registers[Waddr] <= DataIn;
    end
endmodule
