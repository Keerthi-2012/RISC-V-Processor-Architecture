`timescale 1ns / 1ps

module idex(
    input wire clk,
    input wire reset,

    input  ALU_src_in, Mem_to_Reg_in, Reg_Write_in, Mem_Read_in, Mem_Write_in, Branch_en_in,
    input [63:0] PC_in,
    input signed [63:0] ValA_in, ValB_in,
    input [63:0] imm_in,
    input [6:0] opcode_in,//new
    input  [2:0] funct3_in,
    input  [6:0] funct7_in,
    input [4:0] rd_in,rs1_in,rs2_in,//new except rd_in
    

    output reg [6:0] opcode_out,//new
    output reg ALU_src_out, Mem_to_Reg_out, Reg_Write_out, Mem_Read_out, Mem_Write_out, Branch_en_out,
    output reg [63:0] PC_out,
    output reg signed [63:0] ValA_out, ValB_out,
    output reg [63:0] imm_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg [4:0] rd_out,rs1_out,rs2_out//new except rd_out
    
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all outputs
            opcode_out<=7'bx;
            ALU_src_out <= 1'bx;
            Mem_to_Reg_out <= 1'bx;
            Reg_Write_out <= 1'bx;
            Mem_Read_out <= 1'bx;
            Mem_Write_out <= 1'bx;
            Branch_en_out <= 1'bx;
            PC_out      <= 64'bx;
            ValA_out <= 64'bx;
            ValB_out <= 64'bx;
            imm_out     <= 64'bx;
            funct3_out  <= 3'bx;
            funct7_out  <= 7'bx;
            rd_out      <= 5'bx;
            rs1_out      <= 5'bx;
            rs2_out      <= 5'bx;
            
        end else begin
            // Synchronize outputs
            opcode_out <=opcode_in;
            ALU_src_out <= ALU_src_in;
            Mem_to_Reg_out <= Mem_to_Reg_in;
            Reg_Write_out <= Reg_Write_in;
            Mem_Read_out <=  Mem_Read_in;
            Mem_Write_out <= Mem_Write_in;
            Branch_en_out <= Branch_en_in;
            PC_out      <= PC_in;
            ValA_out <= ValA_in;
            ValB_out <= ValB_in;
            imm_out     <= imm_in;
            funct3_out  <= funct3_in;
            funct7_out  <= funct7_in;
            rd_out      <= rd_in;
            rs1_out      <= rs1_in;
            rs2_out      <= rs2_in;
        end
    end



endmodule