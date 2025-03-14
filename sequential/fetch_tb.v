`timescale 1ns / 1ps

module fetch_tb;
    // Inputs
    reg         clk;
    reg  [63:0] PC;
    reg  [31:0] instr;
    reg         branch_taken;
    reg  [63:0] branch_target;

    // Outputs
    wire [6:0]  opcode;
    wire [4:0]  rd, rs1, rs2;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [63:0] imm;
    wire [63:0] nextp;
    wire        instr_valid, imem_error;
    
    // Instantiate the Unit Under Test (UUT)
    fetch uut (
        .clk(clk),
        .PC(PC),
        .instr(instr),
        .branch_taken(branch_taken),
        .branch_target(branch_target),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm),
        .nextp(nextp),
        .instr_valid(instr_valid),
        .imem_error(imem_error)
    );
    
    // Define clock
    always #5 clk = ~clk;
    
    // Test case helper task
    task test_instruction;
        input [63:0] pc_val;
        input [31:0] instruction;
        input [8*20:1] instr_name;     // Character array to store the instruction name
        input [63:0] expected_imm;     // Expected immediate value
        input branch_taken_val;        // Add branch_taken input
        input [63:0] branch_target_val; // Add branch_target input
        begin
            PC = pc_val;
            instr = instruction;
            branch_taken = branch_taken_val;       // Set branch_taken
            branch_target = branch_target_val;     // Set branch_target
            #10; // Wait for combinational logic to settle
            $display("\n========== %s ==========\n", instr_name);
            $display("PC = %b(%d), Instr = %b(%d)\n", PC, PC, instr, instr);
            $display("branch_taken = %b, branch_target = %d", branch_taken, branch_target);
            $display("Decoded fields:");
            $display("  opcode = %b (%d)", opcode, opcode);
            $display("  rd     = %b (%d)", rd, rd);
            $display("  rs1    = %b (%d)", rs1, rs1);
            $display("  rs2    = %b (%d)", rs2, rs2);
            $display("  funct3 = %b (%d)", funct3, funct3);
            $display("  funct7 = %b (%d)", funct7, funct7);
            
            // Display and verify the immediate value
            $display("  imm    = %b (%d) (Expected: %b (%d))", imm, imm, expected_imm, expected_imm);
            if (imm !== expected_imm) begin
                $display("  *** ERROR: Immediate value mismatch! ***");
            end
            $display("  nextp  = %b(%d)", nextp,nextp);
            $display("  instr_valid = %b, imem_error = %b", instr_valid, imem_error);
        end
    endtask
    
    // Test Vector Generation
    initial begin
        // Initialize inputs
        clk = 0;
        PC = 64'h0;
        instr = 32'h0;
        branch_taken = 0;      // Initialize branch_taken
        branch_target = 64'h0; // Initialize branch_target
        
        // Wait for global reset
        #100;
        
        // Test Cases with branch values (branch_taken=0 for regular instruction flow)
        // ADD x3, x1, x2 (R-type, no immediate)
        test_instruction(64'h0000, 32'h002081B3, "ADD x3, x1, x2", 64'h0, 0, 64'h0); 
        
        // SUB x3, x1, x2 (R-type, no immediate)
        test_instruction(64'h0004, 32'h402081B3, "SUB x3, x1, x2", 64'h0, 0, 64'h0); 
        
        // AND x3, x1, x2 (R-type, no immediate)
        test_instruction(64'h0008, 32'h0020F1B3, "AND x3, x1, x2", 64'h0, 0, 64'h0); 
        
        // OR x3, x1, x2 (R-type, no immediate)
        test_instruction(64'h000C, 32'h0020E1B3, "OR x3, x1, x2", 64'h0, 0, 64'h0); 
        
        // LD x2, 8(x1) (I-type load, immediate 8)
        test_instruction(64'h0010, 32'h0080B103, "LD x2, 8(x1)", 64'h8, 0, 64'h0); 
        
        // SD x2, 16(x1) (S-type store, immediate 16)
        test_instruction(64'h0014, 32'h0020B823, "SD x2, 16(x1)", 64'h10, 0, 64'h0); 
        
        // BEQ x1, x2, 32 (B-type branch, immediate 32) - test with branch not taken
        test_instruction(64'h0018, 32'h02208063, "BEQ x1, x2, 32 (not taken)", 64'h20, 0, 64'h0); 
        
        // BEQ x1, x2, 32 (B-type branch, immediate 32) - test with branch taken
        test_instruction(64'h0018, 32'h02208063, "BEQ x1, x2, 32 (taken)", 64'h20, 1, 64'h0038); 
        
        // Additional test cases
        test_instruction(64'h0000, 32'h00208433, "ADD x8, x1, x2", 64'h0, 0, 64'h0);               // R-type
        test_instruction(64'h0004, 32'h02A00093, "ADDI x1, x0, 42", 64'h2A, 0, 64'h0);             // I-type
        test_instruction(64'h0008, 32'hFD600093, "ADDI x1, x0, -42", 64'hFFFFFFFFFFFFFFD6, 0, 64'h0); // Negative immediate
        test_instruction(64'h000C, 32'h0080B103, "LD x2, 8(x1)", 64'h8, 0, 64'h0);                 // Load Doubleword
        test_instruction(64'h0010, 32'h0020B823, "SD x2, 16(x1)", 64'h10, 0, 64'h0);               // Store Doubleword
        
        // Branch tests with taking branch or not
        test_instruction(64'h0014, 32'h02208063, "BEQ x1, x2, 32", 64'h20, 0, 64'h0);              // Branch not taken
        test_instruction(64'h0014, 32'h02208063, "BEQ x1, x2, 32 (taken)", 64'h20, 1, 64'h0034);   // Branch taken
        test_instruction(64'h0018, 32'hFE208063, "BEQ x1, x2, -32", 64'hFFFFFFFFFFFFFFE0, 0, 64'h0); // Negative offset not taken
        test_instruction(64'h0018, 32'hFE208063, "BEQ x1, x2, -32 (taken)", 64'hFFFFFFFFFFFFFFE0, 1, 64'hFFF8); // Negative offset taken
        
        // Jump tests
        test_instruction(64'h001C, 32'h08000867, "JAL x1, 128", 64'h80, 0, 64'h0);                 // Jump not taken
        test_instruction(64'h001C, 32'h08000867, "JAL x1, 128 (taken)", 64'h80, 1, 64'h009C);      // Jump taken
        test_instruction(64'h0020, 32'hF8000867, "JAL x1, -128", 64'hFFFFFFFFFFFFFF80, 0, 64'h0);  // Negative jump not taken
        test_instruction(64'h0020, 32'hF8000867, "JAL x1, -128 (taken)", 64'hFFFFFFFFFFFFFF80, 1, 64'hFFFFFFFFFFFFFFB0); // Negative jump taken
        
        // Other instruction types
        test_instruction(64'h0024, 32'h123450B7, "LUI x1, 0x12345", 64'h0000000012345000, 0, 64'h0); // LUI
        test_instruction(64'h0028, 32'h12345117, "AUIPC x2, 0x12345", 64'h0000000012345000, 0, 64'h0); // AUIPC
        test_instruction(64'h002C, 32'h12345678, "Invalid Opcode", 64'h0, 0, 64'h0);              // Invalid opcode
        test_instruction(64'h1000, 32'h00000013, "Memory Error Check", 64'h0, 0, 64'h0);          // Memory error
        
        $display("\n========== All tests completed ==========");
        $finish;
    end
    
    // VCD file for waveform analysis
    initial begin
        $dumpfile("fetch_tb.vcd");
        $dumpvars(0, fetch_tb);
    end
    
endmodule