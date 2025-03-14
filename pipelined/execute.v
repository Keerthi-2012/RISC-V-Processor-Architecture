`timescale 1ns / 1ps

//  `include "mux.v"
`include "cd.v"
`include "alu.v"


module ALU_Top (
   input [6:0] opcode,
    input [4:0] rs1,
   input [4:0] rs2,
    input[4:0] rd,
    input [2:0] funct3,
    input [6:0] funct7 ,
   inout alusrc,
   input [63:0] imm,
    output signed [63:0] result,  
    output carry_alu,  
    output overflow_alu,  
  
    output zero_flag  
);

    wire signed [63:0] ValA, ValB;
   
    wire [2:0] funct3_out;
    wire [6:0] funct7_out;
    wire ALU_src, Mem_to_Reg, Reg_Write, Mem_Read, Mem_Write, Branch_en;
    wire [63:0] m_out;

    wire [63:0] immediate;

    

    // Instantiate Instruction Decoder
    instruction_decoder decoder (
        .opcode(opcode),
        .rs1(rs1), 
        .rs2(rs2), 
        .rd(rd),
        .funct3(funct3),
        .funct7(funct7),
        .imm(immediate),
        .ALU_src(ALU_src),
        .Mem_to_Reg(Mem_to_Reg),
        .Reg_Write(Reg_Write),
        .Mem_Read(Mem_Read),
        .Mem_Write(Mem_Write),
        .Branch_en(Branch_en),
        .ValA(ValA),  // Output connected to ALU input
        .ValB(ValB),  // Output connected to ALU input
        .funct3_out(funct3_out),
        .funct7_out(funct7_out),
        .imm_out(immediate)
    );

    assign alusrc = ALU_src;
    mux2to1 pc_mux (
        .Y(m_out),             // Output
        .A(ValB),     // PC+4 (when S=0)
        .B(imm),     // Branch target (when S=1)
        .S(ALU_src)       // Select signal
    );
    

    // Instantiate ALU
    ALU alu (
        .funct7(funct7_out),  
        .funct3(funct3_out),  
        .opcode(opcode),  
        .A(ValA),  // Connecting ValA to ALU input A
        .B(m_out),  // Connecting ValB to ALU input B
        .addr(imm[11:0]),  
        .result(result),  
        .carry_alu(carry_alu),  
        .overflow_alu(overflow_alu),  
        .zero_flag(zero_flag)  
    );

   




endmodule