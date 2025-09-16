`timescale 1ns/1ps

module riscv_CPU_tb;

    localparam ADDR_WIDTH = 12;

    logic clk;
    logic rst;

    // Instantiate the CPU
    riscv_CPU #(.ADDR_WIDTH(ADDR_WIDTH)) dut (
        .clk(clk),
        .rst(rst)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Reset sequence
    initial begin
        rst = 1;
        #20 rst = 0;
    end

    // Load simple store program
    initial begin
        for (int i = 0; i < (1 << ADDR_WIDTH); i++)
            dut.imem.rom[i] = 32'h00000013; // NOP

        // x1 = 42
        dut.imem.rom[0] = 32'h02A00093; // addi x1, x0, 42

        // x2 = 0 (address)
        dut.imem.rom[1] = 32'h00000113; // addi x2, x0, 0

        // sw x1, 0(x2)
        dut.imem.rom[2] = 32'h00112023; // sw x1, 0(x2)
    end

    // Run simulation and print memory contents
    initial begin
        #100;

        $display("Simple memory test:");
        for (int i = 0; i < 4; i++)
            $display("mem[%0d] = %0d", i, dut.dmem.Ram[i]);

        $finish;
    end

endmodule