`timescale 1ns / 1ps

module exmem(
    input wire clk,
    input wire reset,

    input  Mem_to_Reg_in, Reg_Write_in, Mem_Read_in, Mem_Write_in, Branch_en_in,
    input [63:0] PC_in,
    input  zero_flag_in,
    input [63:0] result_in,
    input  signed [63:0] ValB_in,
    input [63:0] imm_in,
    input [4:0] rd_in,

    input [6:0] opcode,//new
    input [4:0] rs1,//new
    input [4:0] rs2,//new
    input [2:0] funct3_in,//new
    input [6:0] funct7_in,//new


    output reg [6:0] opcode_out,//new
    output reg [4:0] rs1_out, rs2_out,//new all
    output reg [2:0] funct3_out,//new
    output reg [6:0] funct7_out,//new

    // Control Signals
    output reg Mem_to_Reg_out, Reg_Write_out, Mem_Read_out, Mem_Write_out, Branch_en_out,
    output reg [63:0] PC_out,
    output reg zero_flag_out,
    output reg [63:0] result_out,
    output reg signed [63:0] ValB_out,
    output reg [63:0] imm_out,
    output reg [4:0] rd_out
    
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all outputs
            opcode_out<=7'bx;
            rs1_out<=5'bx;
            rs2_out<=5'bx;
            funct7_out<=7'bx;
            funct3_out<=3'bx;

            Mem_to_Reg_out <= 1'bx;
            Reg_Write_out <= 1'bx;
            Mem_Read_out <= 1'bx;
            Mem_Write_out <= 1'bx;
            Branch_en_out <= 1'bx;
            PC_out      <= 64'bx;
            zero_flag_out <= 1'bx; 
            result_out  <= 64'bx;
            ValB_out <= 64'bx;
            imm_out     <= 64'bx;
            rd_out      <= 5'bx;
            
        end else begin
            // Synchronize outputs
            opcode_out<=opcode;
            rs1_out<=rs1;
            rs2_out<=rs2;
            funct7_out<=funct7_in;
            funct3_out<=funct3_in;

            Mem_to_Reg_out <= Mem_to_Reg_in;
            Reg_Write_out <= Reg_Write_in;
            Mem_Read_out <=  Mem_Read_in;
            Mem_Write_out <= Mem_Write_in;
            Branch_en_out <= Branch_en_in;
            PC_out      <= PC_in;
            zero_flag_out <= zero_flag_in; 
            result_out  <= result_in;
            ValB_out <= ValB_in;
            imm_out     <= imm_in;
            rd_out      <= rd_in;
        end
    end



endmodule