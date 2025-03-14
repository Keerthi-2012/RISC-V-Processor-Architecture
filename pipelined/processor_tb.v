`timescale 1ns / 1ps

module processor_tb;
    // Testbench signals
    reg clk;
    reg reset;
    wire [31:0] instruction;
    wire [63:0] result;
    wire zero;

    reg [31:0] instr_memory [0:1023];
    // Instantiate the processor
    processor dut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .result_final(result),
        .zero_final(zero)
    );

    wire [63:0] PC = dut.PC;

    assign instruction = instr_memory[PC[11:2]]; // Get word address from PC (PC is byte-addressed, so divide by 4)
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end
    
    // VCD file for waveform generation
    initial begin
        $dumpfile("wf_tb.vcd");
        $dumpvars(0, processor_tb);
        $display("VCD info: dumpfile processor_tb.vcd opened for output.");
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        // test_instr = 32'h0;
        for (integer i = 0; i < 1024; i = i + 1) begin
            instr_memory[i] = 32'h0; // Default NOP instruction
        end

        // Apply reset for 2 clock cycles
        #10
        reset = 0;
        
        instr_memory[0] = 32'b0000000_00010_00001_000_00100_0110011; // add x4, x1, x2
        #10;

        instr_memory[1] = 32'b0100000_00100_00101_000_00110_0110011; // sub x6, x5, x4
        #10;

        instr_memory[2] = 32'b0000000_00100_00110_000_00111_0110011; // add x7, x4, x6
        #10;

        instr_memory[3] = 32'b0000000_01001_00111_000_01000_0010011; // addi x8, x7, 9
        #10;

        instr_memory[4] = 32'b0000000_01011_01101_011_01000_0100011; // sd x11, 8(x13) 
        #10;

        instr_memory[5] = 32'b000000001000_01101_011_11000_0000011; // ld x24, 8(x13) 
        #10;

        instr_memory[6] = 32'b0000000_11001_11000_111_10001_0110011; // and x17, x24, x25
        #10;

        instr_memory[7] = 32'b0000000_11010_11011_110_10011_0110011; // or x19, x26, x27
        #10;


        instr_memory[8] = 32'b0000000_01110_01101_000_0011_0_1100011; // beq x13,x14,3 (neq)
        #10;

        instr_memory[9] = 32'b0000000_01111_01111_000_0010_0_1100011; // beq x15,x16,3 (eq)
        #10;


        instr_memory[10] = 32'b0; 
        #10;
        instr_memory[11] = 32'b0; 
        #10;
        instr_memory[12] = 32'b0; 
        #10;
        instr_memory[13] = 32'b0; 
        #10;
        instr_memory[14] = 32'b0; 
        #10;
        repeat(1) @(posedge clk);
        reset = 0;



                $display("\nFinal Register Values:");
        for (integer i = 0; i < 32; i = i + 1) begin
            $display("Register x%0d = %h", i, dut.inst_decode.registers[i]);
        end
        
        $display("\n========== Simulation completed ==========");
        $finish;


        #10;
        $display("\n========== Simulation completed ==========");
        $finish;
    end
    
endmodule