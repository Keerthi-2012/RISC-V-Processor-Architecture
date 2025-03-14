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
    reg signed [63:0] ValA;
    reg  signed [63:0] ValB;
    
    // Outputs
    wire signed [63:0] result;
    wire carry_alu;
    wire overflow_alu;
    wire zero_flag;
    
    // Instantiate the ALU_Top module
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
        .zero_flag(zero_flag),
        .ValA(ValA),
        .ValB(ValB)
    );
    
    initial begin
        // Test Case 1: Addition (Example values)
        opcode = 7'b0110011; // R-type instruction
        funct3 = 3'b000; // ADD
        funct7 = 7'b0000000; // ADD
        rs1 = 5'd1;
        rs2 = 5'd9;
        rd = 5'd3;
        imm = 64'd10;
        alusrc = 0; 
        ValA = 64'd9;
        ValB = 64'd7;// ALU should take rs2 as operand
        
        #10; // Wait 10 time units
        
        // Test Case 2: Subtraction (Example values)
        funct3 = 3'b000; // SUB
        funct7 = 7'b0100000; // SUB
        alusrc = 0;
        
        #10;
        
        // Test Case 3: Immediate Addition (Example values)
        opcode = 7'b0010011; // I-type instruction
        funct3 = 3'b000; // ADDI
        funct7 = 7'b0000000; // Doesn't matter for I-type
        imm = 64'd5;
        alusrc = 1; // ALU should take imm as operand
        
        #10;
        
        // Test Case 4: AND operation
         opcode = 7'b1100011; 
        funct3 = 3'b000; // AND
        funct7 = 7'b0000000;
        alusrc = 0;
        ValA = 64'd1;
        ValB = 64'd1;
        
        #10;
        
        // Test Case 5: OR operation
        opcode = 7'b0110011;
        funct3 = 3'b110; // OR
        
        #10;
        
        // End simulation
        $finish;
    end
    
    initial begin
        $monitor("Time=%0t | opcode=%b | funct3=%b | funct7=%b | rs1=%d | rs2=%d | rd=%d | imm=%d | result=%d | carry=%b | overflow=%b | zero=%b", 
                 $time, opcode, funct3, funct7, rs1, rs2, rd, imm, result, carry_alu, overflow_alu, zero_flag);
    end
    
endmodule