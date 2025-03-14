`timescale 1ns / 1ps

module main_tb();
    // Testbench signals
    reg clk;
    reg reset;
    wire [31:0] instruction;
    wire [63:0] result;
    wire zero;
    reg simulation_done;
    integer instruction_count;
    
    // Instruction memory
    reg [31:0] instr_memory [0:1023]; // 1024 words of instruction memory
    
    // Instantiate the main module
    main uut (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .result(result),
        .zero(zero)
    );
    
    wire [63:0] PC = uut.PC_reg;
    
    // Instruction fetch based on PC
    assign instruction = instr_memory[PC[11:2]]; // Get word address from PC (PC is byte-addressed, so divide by 4)
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end
    
    // Waveform dump
    initial begin
        $dumpfile("waveform.vcd"); // Save wave data to "waveform.vcd"
        $dumpvars(0, main_tb);     // Dump all signals of this module
        $display("VCD info: dumpfile waveform.vcd opened for output.");
    end
    
    // Display state on each clock cycle
    always @(posedge clk) begin
        if (!simulation_done) begin
            $display($time, " | clk=%b | reset=%b | PC=%h (%0d) | instruction=%b | result=%h (%0d) | zero=%b",
                 clk, reset, PC, PC, instruction, result, result, zero);
        end
    end

    // Test stimulus
    initial begin
        // Initialize signals
        simulation_done = 0;
        reset = 1;
        instruction_count = 0;
        
        // Initialize instruction memory
        for (integer i = 0; i < 1024; i = i + 1) begin
            instr_memory[i] = 32'h0; // Default NOP instruction
        end
        
        // Load test program into instruction memory (word-addressed)
        // ADD Operation Tests
        instr_memory[0] = 32'b00000000011110000000011100010011; // addi x14, x7, x16 (small values) - PC=0
        
        // ADD Edge Cases
        instr_memory[1] = 32'b00000000001000001000000110110011; // add x3, x1, x2 (small values) - PC=4
        instr_memory[2] = 32'b00000000000100001000000110110011; // add x3, x1, x1 (same register) - PC=8
        instr_memory[3] = 32'b00000001111111111000000110110011; // add x3, x31, x31 - PC=12
        instr_memory[4] = 32'b00000000000000000000000110110011; // all zero - PC=16
        
        // SUB Edge Cases
        instr_memory[5] = 32'b01000000001000001000000110110011; // sub x3, x1, x2 (small values) - PC=20
        instr_memory[6] = 32'b01000000000100001000000110110011; // sub x3, x1, x1 (zero result) - PC=24
        instr_memory[7] = 32'b01000001111111111000000110110011; // sub x3, x31, x31 - PC=28
        
        // Store (SD) Edge Cases
        instr_memory[8] = 32'b0000000_00100_00011_011_00101_0100011; // sd x4, 5(x3) (aligned memory) - PC=32
        instr_memory[9] = 32'b0000000_00111_10001_011_01010_0100011; // sd x7, 10(x17) (aligned memory) - PC=36
        instr_memory[10] = 32'b0000000_01011_01101_011_01000_0100011; // sd x11, 8(x13) (aligned memory) - PC=40
        instr_memory[11] = 32'b11111111111000000011000100100011; // sd x0, -8(x1) (negative offset) - PC=44
        
        // Load (LD) Edge Cases
        instr_memory[12] = 32'b00000000010100011011010000000011; // ld x16, 10(x3) (aligned memory) - PC=48
        instr_memory[13] = 32'b000000001010_10001_011_00111_0000011; // ld x7, 10(x17) (aligned memory) - PC=52
        instr_memory[14] = 32'b000000001000_01101_011_11000_0000011; // ld x24, 8(x13) (aligned memory) - PC=56
        instr_memory[15] = 32'b00000000001000000011000010000011; // ld x1, 2(x0) (aligned memory) - PC=60
        instr_memory[16] = 32'b00000000010000000011000010000011; // ld x1, 4(x0) (aligned memory) - PC=64
        instr_memory[17] = 32'b11111111111000000011000010000011; // ld x1, -8(x0) (negative offset) - PC=68
        
        // BEQ Edge Cases
// Correct BEQ encodings (format: imm[12|10:5] rs2 rs1 000 imm[4:1|11] 1100011)
// beq x1, x1, 16 (equal case, branch forward by 16 bytes)
instr_memory[18] = 32'b0000000_00001_00001_000_1000_0_1100011;

// beq x0, x1, 16 (unequal case, shouldn't branch)
instr_memory[19] = 32'b0000000_00001_00000_000_1000_0_1100011;

// beq x0, x0, 16 (equal case, branch forward)
instr_memory[20] = 32'b0000000_00000_00000_000_1000_0_1100011;

// beq x0, x1, 16 (unequal case, shouldn't branch)
instr_memory[21] = 32'b0000000_00001_00000_000_1000_0_1100011;

// beq x1, x1, -16 (equal with negative offset, branch backward)
instr_memory[22] = 32'b0000000_00001_00000_000_0100_0_1100011;
        // OR Edge Cases
        instr_memory[23] = 32'b00000000001000001110000110110011; // or x3, x1, x2 (small values) - PC=92
        instr_memory[24] = 32'b00000000000000001110000110110011; // or x3, x1, x0 (or with zero) - PC=96
        instr_memory[25] = 32'b00000001111100001110000110110011; // or x3, x1, x31 (with max values) - PC=100
        
        // Additional operations
        instr_memory[26] = 32'b0000000_00001_00111_000_00011_0010011; // addi x3, x7, 1 (Add immediate) - PC=104
        instr_memory[27] = 32'b0000000_00011_00000_010_00001_0100011; // sw x3, 1(x0) (Store word) - PC=108
        instr_memory[28] = 32'b0000000_01000_00000_010_00100_0000011; // lw x4, 8(x0) (Load word) - PC=112
        instr_memory[29] = 32'b0000000_00001_00010_000_00100_0110011; // add x4, x2, x1 (Add registers) - PC=116
        instr_memory[30] = 32'b0100000_00011_01001_000_00101_0110011; // sub x5, x9, x3 (Subtract) - PC=120
        
        // Apply reset for one clock cycle
        repeat(1) @(posedge clk);
        reset = 0;
        
        // Let the processor run for enough cycles to execute all instructions
        // Adding buffer cycles to account for any branching
        repeat(35) @(posedge clk);
        instruction_count = 35;
        
        // End simulation properly
        $display("Processed %0d cycles", instruction_count);
        simulation_done = 1;  // Set flag to stop the display
        #10;                  // Small delay to ensure all events are processed
        $dumpflush;           // Flush any pending VCD data
        $dumpoff;             // Turn off VCD dumping
        $display("Testbench completed");
        $finish;
    end
endmodule