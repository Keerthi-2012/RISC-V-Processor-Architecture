`timescale 1ns / 1ps

// `include "mux.v"
`include "alu.v"

module ALU_Top (
   input [6:0] opcode,
    input [4:0] rs1,
   input [4:0] rs2,
    input[4:0] rd,
    input [2:0] funct3,
    input [6:0] funct7 ,
   input alusrc,
   input [63:0] imm,
   input signed [63:0] ValA, ValB,

   
    output signed [63:0] result,  
    output carry_alu,  
    output overflow_alu,
    output  [6:0] opcode_out,//new
    output  [4:0] rs1_out, rs2_out, rd_out,//new all
    output  [2:0] funct3_out,//new
    output  [6:0] funct7_out,  //new
  
    output zero_flag  
);
    wire [63:0] m_out;
    assign opcode_out=opcode;
    assign rs1_out=rs1;
    assign rs2_out=rs2;
    assign rd_out=rd;
    assign funct3_out=funct3;
    assign funct7_out=funct7;
    
    mux2to1 pc_mux (
        .Y(m_out),             // Output
        .A(ValB),     // PC+4 (when S=0)
        .B(imm),     // Branch target (when S=1)
        .S(alusrc)       // Select signal
    );
    
    

    // Instantiate ALU
    ALU alu (
        .funct7(funct7),  
        .funct3(funct3),  
        .opcode(opcode),  
        .A(ValA), 
        .B(m_out), 
        .addr(imm[11:0]),  
        .result(result),  
        .carry_alu(carry_alu),  
        .overflow_alu(overflow_alu),  
        .zero_flag(zero_flag)  
    );

   




endmodule