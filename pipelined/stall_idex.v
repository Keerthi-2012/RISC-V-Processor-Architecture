module stall_idex (
    input wire clk,
    input wire reset,
    input wire stall,
    input wire flush,  // New flush signal
    input wire ALU_src_in,
    input wire Mem_to_Reg_in,
    input wire Reg_Write_in,
    input wire Mem_Read_in,
    input wire Mem_Write_in,
    input wire Branch_en_in,
    input wire [63:0] PC_in,
    input wire signed [63:0] ValA_in,
    input wire signed [63:0] ValB_in,
    input wire [63:0] imm_in,
    input wire [6:0] opcode_in,
    input wire [2:0] funct3_in,
    input wire [6:0] funct7_in,
    input wire [4:0] rs1_in,
    input wire [4:0] rs2_in,
    input wire [4:0] rd_in,
    output reg [6:0] opcode_out,
    output reg ALU_src_out,
    output reg Mem_to_Reg_out,
    output reg Reg_Write_out,
    output reg Mem_Read_out,
    output reg Mem_Write_out,
    output reg Branch_en_out,
    output reg [63:0] PC_out,
    output reg signed [63:0] ValA_out,
    output reg signed [63:0] ValB_out,
    output reg [63:0] imm_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    output reg [4:0] rd_out
);

    // On the rising edge of the clock or reset
    always @(posedge clk or posedge reset) begin
        if (reset || stall) begin
            // Reset all outputs to 0
            opcode_out <= 7'b0;
            ALU_src_out <= 1'b0;
            Mem_to_Reg_out <= 1'b0;
            Reg_Write_out <= 1'b0;
            Mem_Read_out <= 1'b0;
            Mem_Write_out <= 1'b0;
            Branch_en_out <= 1'b0;
            PC_out <= 64'b0;
            ValA_out <= 64'b0;
            ValB_out <= 64'b0;
            imm_out <= 64'b0;
            funct3_out <= 3'b0;
            funct7_out <= 7'b0;
            rs1_out <= 5'b0;
            rs2_out <= 5'b0;
            rd_out <= 5'b0;
        // end else if (flush) begin
        //     // Insert NOP by zeroing all control signals
        //     opcode_out <= 7'b0;
        //     ALU_src_out <= 1'b0;
        //     Mem_to_Reg_out <= 1'b0;
        //     Reg_Write_out <= 1'b0;
        //     Mem_Read_out <= 1'b0;
        //     Mem_Write_out <= 1'b0;
        //     Branch_en_out <= 1'b0;
        //     // Preserve data paths but disable control signals
        //     PC_out <= PC_in;
        //     ValA_out <= ValA_in;
        //     ValB_out <= ValB_in;
        //     imm_out <= imm_in;
        //     funct3_out <= 3'b0;
        //     funct7_out <= 7'b0;
        //     rs1_out <= 5'b0;
        //     rs2_out <= 5'b0;
        //     rd_out <= 5'b0;
        end else if (!stall) begin
            // If not stalling, update all outputs with inputs
            opcode_out <= opcode_in;
            ALU_src_out <= ALU_src_in;
            Mem_to_Reg_out <= Mem_to_Reg_in;
            Reg_Write_out <= Reg_Write_in;
            Mem_Read_out <= Mem_Read_in;
            Mem_Write_out <= Mem_Write_in;
            Branch_en_out <= Branch_en_in;
            PC_out <= PC_in;
            ValA_out <= ValA_in;
            ValB_out <= ValB_in;
            imm_out <= imm_in;
            funct3_out <= funct3_in;
            funct7_out <= funct7_in;
            rs1_out <= rs1_in;
            rs2_out <= rs2_in;
            rd_out <= rd_in;
        end
        // If stalling and not flushing, maintain current values
    end

endmodule