module top_level(		   // you will have the same 3 ports
    input        Reset,	   // init/reset, active high
			     Start,    // start next program
	             Clk,	   // clock -- posedge used inside design
    output logic Ack	   // done flag from DUT
    );

    logic ZeroQ, ParityQ, TapSel, Immediate;

    wire [ 9:0] PgmCtr,        // program counter
                PCTarg;
    wire [ 8:0] Instruction;   // our 9-bit opcode
    wire [ 7:0] ReadA, ReadB;  // reg_file outputs
    wire [ 7:0] InA, InB, 	   // ALU operand inputs
                ALU_out;       // ALU result
    wire [ 7:0] RegWriteValue, // data in to reg file
                MemWriteValue, // data in to data_memory
                MemReadValue;  // data out from data_memory
    wire [ 5:0] TargSel;
    wire        MemWrite,	   // data_memory write enable
                RegWrEn,	   // reg_file write enable
                Zero,		   // ALU output = 0 flag
                Jump,	       // to program counter: jump 
                Parity,
                Odd,
                SC_out,
                BranchEn;	   // to program counter: branch enable
    wire [2:0]  RegWriteIndex;
    wire [7:0]  AccumulatorValue,
                Reg1Value,
                Reg2Value,
                Reg3Value,
                Reg4Value,
                Reg5Value,
                Reg6Value,
                Reg7Value;

    logic[15:0] CycleCt;	   // standalone; NOT PC!

    always @(posedge Clk)
        if(Reset) begin
            ZeroQ <= 0;
            ParityQ <= 0;
        end
        else begin
            ZeroQ <= Zero;
            ParityQ <= Parity;
        end

    InstFetch IF1 (		       // this is the program counter module
        .Reset        (Reset   ) ,  // reset to 0
        .Start        (Start   ) ,  // SystemVerilog shorthand for .grape(grape) is just .grape 
        .Clk          (Clk     ) ,  //    here, (Clk) is required in Verilog, optional in SystemVerilog
        .BranchAbs    (Jump    ) ,  // jump enable
        .BranchRelEn  (BranchEn) ,  // branch enable
        .ALU_flag	  (!ZeroQ    ) ,  // when not zero, we do the branching (for loop/while loop)
        .Target       (PCTarg  ) ,  // "where to?" or "how far?" during a jump or branch
        .ProgCtr      (PgmCtr  )	   // program count = index to instruction memory
    );	

    
    Immediate_LUT LUT1(.Addr         (TargSel ) ,
                       .Target       (PCTarg  )
    );


    // instruction ROM -- holds the machine code pointed to by program counter
    InstROM #(.W(9)) IR1(
        .InstAddress  (PgmCtr     ) , 
        .InstOut      (Instruction)
    );

    // Decode stage = Control Decoder + Reg_file
    // Control decoder
    Ctrl Ctrl1 (
        .Instruction  (Instruction) ,  // from instr_ROM
        .Branch         (Jump       ) ,  // to PC to handle jump/branch instructions
        .BranchEn     (BranchEn   )	,  // to PC
        .RegWrEn      (RegWrEn    )	,  // register file write enable
        .MemWrEn      (MemWrite   ) ,  // data memory write enable
        .LoadInst     (LoadInst   ) ,  // selects memory vs ALU output as data input to reg_file
        .PCTarg       (TargSel    ) ,    
        .Ack          (Ack        ),	   // "done" flag
        .RegWriteIndex       ,
        .DatMemAddr   (ReadB),
        .TapSel              ,
        .Immediate            
    );


    RegFile #(.W(8),.D(3)) RF1 (			  // D(3) makes this 8 elements deep
		.Clk    				  ,
		.WriteEn   (RegWrEn)    , 
		.RaddrA    (3'b000),        //concatenate with 0 to give us 4 bits
		.RaddrB    (Instruction[4:2]), 
		.Waddr     (RegWriteIndex), 	      // mux above
		.DataIn    (RegWriteValue) , 
		.DataOutA  (ReadA        ) , 
		.DataOutB  (ReadB		 ) ,
        .Reset                     ,
        .Immediate                 ,
        .ImmediateValue   (Instruction[8:1]),
        .AccumulatorValue,
        .Reg1Value,
        .Reg2Value,
        .Reg3Value,
        .Reg4Value,
        .Reg5Value,
        .Reg6Value,
        .Reg7Value
	);

    assign InA = ReadA;						  // connect RF out to ALU in
	assign InB = ReadB;	          			  // interject switch/mux if needed/desired
    // controlled by Ctrl1 -- must be high for load from data_mem; otherwise usually low
	assign RegWriteValue = LoadInst? MemReadValue : ALU_out;  // 2:1 switch into reg_file
    ALU ALU1  (
        .InputA  (InA),
        .InputB  (InB), 
        .SC_in   (ParityQ),
        .OP      (Instruction[7:5]),
        .Out     (ALU_out),                       //regWriteValue),
        .MOV_Dest_acc (Instruction[1]),
        .Zero		      ,                       // status flag; may have others, if desired
        .Parity ,
        .Odd,
        .SC_out
    );

    assign MemWriteValue = ReadA;

    // load: acc has address, read mem[acc] and store in register (readB)
    // store: acc has value to be stored, register (readB) has the address to be stored.   mem[readB] = acc
	DataMem DM(
		.DataAddress  (ReadB)    ,  //address in B, read data and write to register address in A (instruction[1] == 0)
		.WriteEn      (MemWrite), 
		.DataIn       (MemWriteValue), 
		.DataOut      (MemReadValue)  , 
		.Clk 		  		     ,
		.Reset		  (Reset)
	);


/* count number of instructions executed
      not part of main design, potentially useful
      This one halts when Ack is high  
*/
always_ff @(posedge Clk)
  if (Reset == 1)	   // if(start)
  	CycleCt <= 0;
  else if(Ack == 0)   // if(!halt)
  	CycleCt <= CycleCt+16'b1;




endmodule

	