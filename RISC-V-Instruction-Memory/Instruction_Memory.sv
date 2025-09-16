module Instruction_Memory #( parameter ADDR_WIDTH = 12)( 

	input logic [ADDR_WIDTH-1:0] addr, 
	output logic [31:0] instr
	

); 
	logic [31:0] rom [0:(1<<ADDR_WIDTH)-1]; 
	initial begin 
		integer i; 
		for (i=0;i<(1<<ADDR_WIDTH);i++) 
			rom[i] = 32'h00000013; 
	end 
	
	assign instr = rom[addr]; 
endmodule 