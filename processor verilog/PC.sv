// program counter
// supports both relative and absolute jumps
// use either or both, as desired
module PC #(parameter D=10)(
  input reset,					// synchronous reset
        clk,
		    absjump_en,             // only support absolute jumps
  input       [D-1:0] target,	// where to jump
  output logic[D-1:0] prog_ctr
);

  always_ff @(posedge clk)
    if(reset)
	    prog_ctr <= '0;
	  else if(absjump_en)
	    prog_ctr <= target;
	  else
	    prog_ctr <= prog_ctr + 'b1;

endmodule