module ALU (
	input logic [3:0] alu_ctrl, 
	input logic [31:0] a,b, 
	output logic [31:0] result, 
	output logic zero



); 


	always_comb begin 
		case(alu_ctrl) 
			4'h0: result = a + b;  
			4'h1: result = a - b;
			4'h2: result = a & b; 
			4'h3: result = a | b;
			4'h4: result = a ^ b;
			4'h5: result = a << b[4:0];
			4'h6: result = a >> b[4:0];
			4'h7: result = $signed(a) >>> b[4:0];
			4'h8: result = ($signed(a) < $signed(b)) ? 1 : 0; 
			default: result =0;
		endcase 
		zero = (result == 0);
	end  
endmodule 
			