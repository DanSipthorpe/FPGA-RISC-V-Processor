module riscv_CPU #(
    parameter ADDR_WIDTH = 12
)(
    input  logic clk,
    input  logic rst
);
    // ======================
    // Internal wires/signals
    // ======================
    logic [31:0] pc, pc_next, instr;
    logic [4:0]  rs1, rs2, rd;
    logic [2:0]  funct3;
    logic [6:0]  funct7, opcode;
    logic [31:0] rs1_data, rs2_data, rd_wdata;
    logic [31:0] imm, alu_out, mem_rdata;
    logic [3:0]  alu_ctrl;
    logic        alu_zero;

    // Control signals
    logic is_alu_src_imm, is_mem_read, is_mem_write, is_reg_write;
    logic is_branch, is_jal, is_jalr, is_lui, is_auipc;

    // ======================
    // Program Counter
    // ======================
    Program_Counter pc_unit (
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

    // ======================
    // Instruction Memory
    // ======================
    Instruction_Memory #(.ADDR_WIDTH(ADDR_WIDTH)) imem (
        .addr(pc[ADDR_WIDTH+1:2]),
        .instr(instr)
    );

    // ======================
    // Instruction Decode
    // ======================
    assign opcode = instr[6:0];
    assign rd     = instr[11:7];
    assign funct3 = instr[14:12];
    assign rs1    = instr[19:15];
    assign rs2    = instr[24:20];
    assign funct7 = instr[31:25];

    // ======================
    // Register File
    // ======================
    Register_File regs (
        .clk(clk),
        .write_enable(is_reg_write),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .write_data(rd_wdata),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // ======================
    // Immediate Generator
    // ======================
    Immediate_Generator immu (
        .instr(instr),
        .imm(imm)
    );

    // ======================
    // Control Unit
    // ======================
    Control_Unit ctrl (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_ctrl(alu_ctrl),
        .is_alu_src_imm(is_alu_src_imm),
        .is_mem_read(is_mem_read),
        .is_mem_write(is_mem_write),
        .is_reg_write(is_reg_write),
        .is_branch(is_branch),
        .is_jal(is_jal),
        .is_jalr(is_jalr),
        .is_lui(is_lui),
        .is_auipc(is_auipc)
    );

    // ======================
    // ALU
    // ======================
    ALU alu_unit (
        .a(rs1_data),
        .b(is_alu_src_imm ? imm : rs2_data),
        .alu_ctrl(alu_ctrl),
        .result(alu_out),
        .zero(alu_zero)
    );

    // ======================
    // Data Memory
    // ======================
    Data_Memory #(.ADDR_WIDTH(ADDR_WIDTH)) dmem (
        .clk(clk),
        .addr(alu_out[ADDR_WIDTH+1:2]),
        .Write_Data(rs2_data),
        .Read_Data(mem_rdata),
        .Write_Enable(is_mem_write)
    );

    // ======================
    // Next PC Logic
    // ======================
    always_comb begin
        pc_next = pc + 4;
        if (is_branch && (rs1_data == rs2_data)) pc_next = pc + imm; // BEQ
        if (is_jal)  pc_next = pc + imm;
        if (is_jalr) pc_next = (rs1_data + imm) & ~32'd1;
    end

    // ======================
    // Writeback Mux
    // ======================
    always_comb begin
        if (is_lui)         rd_wdata = imm;
        else if (is_auipc)  rd_wdata = pc + imm;
        else if (is_jal ||
                 is_jalr)   rd_wdata = pc + 4;
        else if (is_mem_read) rd_wdata = mem_rdata;
        else                rd_wdata = alu_out;
    end
	always_ff @(posedge clk) begin
		$display("PC=%0d INSTR=%h", pc, instr);
		$display("x1=%0d x2=%0d x3=%0d x4=%0d", rs1_data, rs2_data, alu_out, imm);
	end
	 
endmodule
