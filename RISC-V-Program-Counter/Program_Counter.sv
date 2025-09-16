module Program_Counter( 
	input logic clk, 
	input logic rst, 
	input logic [31:0] pc_next, 
	output logic [31:0] pc


);

	always_ff@(posedge clk or posedge rst) begin 
		if (rst) 
			pc <= 32'h0; 
		else 
			pc <= pc_next; 
	end 
endmodule 
	