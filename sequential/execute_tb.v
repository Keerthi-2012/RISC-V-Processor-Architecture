
`timescale 1ns / 1ps

module ALU_Top_tb;

    // Inputs
    reg [6:0] opcode;
    reg [4:0] rs1;
    reg [4:0] rs2;
    reg [4:0] rd;
    reg [2:0] funct3;
    reg [6:0] funct7;
    reg alusrc;
    reg [63:0] imm;
    
    // Outputs
    wire [63:0] result;
    wire carry_alu;
    wire overflow_alu;
    wire zero_flag;
    
    // Instantiate the Unit Under Test (UUT)
    ALU_Top uut (
        .opcode(opcode), 
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd), 
        .funct3(funct3), 
        .funct7(funct7), 
        .alusrc(alusrc), 
        .imm(imm), 
        .result(result), 
        .carry_alu(carry_alu), 
        .overflow_alu(overflow_alu), 
        .zero_flag(zero_flag)
    );
    
    // For BEQ instruction:
    // - opcode = 7'b1100011 (branch opcode)
    // - funct3 = 3'b000 (BEQ function)
    
    initial begin
        // Initialize inputs
        opcode = 0;
        rs1 = 0;
        rs2 = 0;
        rd = 0;
        funct3 = 0;
        funct7 = 0;
        alusrc = 0;
        imm = 0;
        
        // Wait for global reset
        #100;
        
        // Test Case 1: BEQ with equal values (should branch)
        // Setting up BEQ instruction
        opcode = 7'b1100011; // Branch opcode
        funct3 = 3'b000;     // BEQ function
        rs1 = 5'b00001;      // Register 1
        rs2 = 5'b00010;      // Register 2
        imm = 64'h0000_0000_0000_0008; // Branch offset (8 bytes forward)
        alusrc = 1;          // Use immediate for B input
        
        // The ALU will subtract rs2 from rs1, and the zero flag should be set if they're equal
        // For this test, we're assuming ValA and ValB will be equal
        // Note: In a real situation, these would come from the register file
        
        #20;
        $display("Test Case 1: BEQ with equal values");
        $display("opcode = %b, funct3 = %b, rs1 = %b, rs2 = %b", opcode, funct3, rs1, rs2);
        $display("zero_flag = %b (Expected: 1 if ValA = ValB)", zero_flag);
        $display("result = %h", result);
        
        // Test Case 2: BEQ with unequal values (should not branch)
        rs1 = 5'b00011;      // Register 3
        rs2 = 5'b00100;      // Register 4
        // Assuming ValA and ValB will be different for these registers
        
        #20;
        $display("\nTest Case 2: BEQ with unequal values");
        $display("opcode = %b, funct3 = %b, rs1 = %b, rs2 = %b", opcode, funct3, rs1, rs2);
        $display("zero_flag = %b (Expected: 0 if ValA != ValB)", zero_flag);
        $display("result = %h", result);
        
        // Test Case 3: BEQ with negative branch offset
        rs1 = 5'b00101;      // Register 5
        rs2 = 5'b00101;      // Same register (will be equal)
        imm = 64'hFFFF_FFFF_FFFF_FFF8; // Branch offset (-8 bytes backward)
        
        #20;
        $display("\nTest Case 3: BEQ with negative branch offset");
        $display("opcode = %b, funct3 = %b, rs1 = %b, rs2 = %b", opcode, funct3, rs1, rs2);
        $display("imm = %h", imm);
        $display("zero_flag = %b (Expected: 1 if ValA = ValB)", zero_flag);
        $display("result = %h", result);
        
        // Test Case 4: Edge case with maximum register values
        rs1 = 5'b11111;      // Register 31
        rs2 = 5'b11111;      // Register 31 (will be equal)
        imm = 64'h0000_0000_0000_1000; // Large branch offset
        
        #20;
        $display("\nTest Case 4: BEQ with maximum register values");
        $display("opcode = %b, funct3 = %b, rs1 = %b, rs2 = %b", opcode, funct3, rs1, rs2);
        $display("imm = %h", imm);
        $display("zero_flag = %b (Expected: 1 if ValA = ValB)", zero_flag);
        $display("result = %h", result);
        
        // End simulation
        #20;
        $finish;
    end
    
    // Optional: Uncomment to generate waveform file
    /*
    initial begin
        $dumpfile("alu_top_beq_test.vcd");
        $dumpvars(0, ALU_Top_tb);
    end
    */
      
endmodule