module Register_File(
    input  logic        clk,
    input  logic        write_enable,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data
);

    logic [31:0] regs [0:31];

    // synchronous reset-like behavior (instead of initial)
    always_ff @(posedge clk) begin
        if (write_enable && rd != 0)
            regs[rd] <= write_data;
    end

    // async reads
    assign rs1_data = (rs1 != 0) ? regs[rs1] : 32'd0;
    assign rs2_data = (rs2 != 0) ? regs[rs2] : 32'd0;

endmodule
