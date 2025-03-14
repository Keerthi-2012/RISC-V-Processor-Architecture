`timescale 1ns / 1ps
module instruction_decoder_tb;
    reg [6:0] opcode;
    reg [4:0] rs1, rs2, rd;
    reg [2:0] funct3;  
    reg [6:0] funct7;  
    wire ALU_src, Mem_to_Reg, Reg_Write, Mem_Read, Mem_Write, Branch_en;
    wire [63:0] ValA, ValB;

    instruction_decoder uut (
        .opcode(opcode),
        .rs1(rs1), .rs2(rs2), .rd(rd),
        .funct3(funct3), .funct7(funct7),  
        .ALU_src(ALU_src), .Mem_to_Reg(Mem_to_Reg), .Reg_Write(Reg_Write),
        .Mem_Read(Mem_Read), .Mem_Write(Mem_Write), .Branch_en(Branch_en),
        .ValA(ValA), .ValB(ValB)
    );

    initial begin
        $monitor("Time=%0t | opcode=%b | rs1=%d | rs2=%d | rd=%d | funct3=%b | funct7=%b | ALU_src=%b | Mem_to_Reg=%b | Reg_Write=%b | Mem_Read=%b | Mem_Write=%b | Branch_en=%b | ValA=%h | ValB=%h", 
                  $time, opcode, rs1, rs2, rd, funct3, funct7, ALU_src, Mem_to_Reg, Reg_Write, Mem_Read, Mem_Write, Branch_en, ValA, ValB);

        
        opcode = 7'b0110011; rs1 = 5'd1; rs2 = 5'd2; rd = 5'd3;
        funct3 = 3'b000; funct7 = 7'b0000000;  // ADD
        #10;
        
        // Test R-type instruction (SUB)
        opcode = 7'b0110011; rs1 = 5'd4; rs2 = 5'd5; rd = 5'd6;
        funct3 = 3'b000; funct7 = 7'b0100000;  // SUB
        #10;
        
        // Test Load instruction (LD)
        opcode = 7'b0000011; rs1 = 5'd7; rs2 = 5'd0; rd = 5'd8;
        funct3 = 3'b010; funct7 = 7'b0000000;
        #10;
        
        // Test Store instruction (SD)
        opcode = 7'b0100011; rs1 = 5'd9; rs2 = 5'd10; rd = 5'd0;
        funct3 = 3'b010; funct7 = 7'b0000000;
        #10;
        
        // Test Branch instruction (BEQ)
        opcode = 7'b1100011; rs1 = 5'd11; rs2 = 5'd12; rd = 5'd0;
        funct3 = 3'b000; funct7 = 7'b0000000;
        #10;
        
        $finish;
    end
endmodule
