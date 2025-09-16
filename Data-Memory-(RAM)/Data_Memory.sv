module Data_Memory #(
    parameter ADDR_WIDTH = 12
)(
    input  wire clk,
    input  wire [31:0] Write_Data,
    input  wire Write_Enable,
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [31:0] Read_Data
);

    // Declare memory array
    logic [31:0] Ram [0:(1<<ADDR_WIDTH)-1];

    // Initialize memory contents to 0
    integer i;
    initial begin
        for (i = 0; i < (1<<ADDR_WIDTH); i = i+1)
            Ram[i] = 32'b0;
    end

    // Synchronous read/write
    always @(posedge clk) begin
        if (Write_Enable) begin
            Ram[addr]   <= Write_Data;
            Read_Data   <= Write_Data;   // so read reflects the new value
				$display("WRITE: addr=%0d data=%0d", addr, Write_Data);

        end else begin
            Read_Data   <= Ram[addr];
        end
    end

endmodule
