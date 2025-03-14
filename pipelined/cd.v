module instruction_decoder (
    input [6:0] opcode,
    input [4:0] rs1, rs2, rd,
    input [2:0] funct3,
    input [6:0] funct7,
    input [63:0] imm,

    output reg ALU_src, Mem_to_Reg, Reg_Write, Mem_Read, Mem_Write, Branch_en,
    output reg signed [63:0] ValA, ValB,
    output  [6:0] opcode_out,//new
    output  [4:0] rs1_out, rs2_out, rd_out,//new all
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output [63:0] imm_out 
);

assign imm_out = imm;
assign opcode_out=opcode;
assign rs1_out=rs1;
assign rs2_out=rs2;
assign rd_out=rd;

    reg [63:0] registers [0:31];  
    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            registers[i] = 64'h0 + i;
        end
    end

    always @(*) begin
        ALU_src = 0; Mem_to_Reg = 0; Reg_Write = 0;
        Mem_Read = 0; Mem_Write = 0; Branch_en = 0;
        ValA = 64'bx;  
        ValB = 64'bx;
        funct3_out = funct3;
        funct7_out = funct7;

        case (opcode)
            7'b0110011: begin // R-type
                Reg_Write = 1;
                ValA = registers[rs1];  
                ValB = registers[rs2];  
            end
            
            7'b0000011: begin // Load
                ALU_src = 1;
                Mem_to_Reg = 1;
                Reg_Write = 1;
                Mem_Read = 1;
                
                ValA = registers[rs1];  
                ValB = imm;  
            end

            7'b0010011: begin // addi
                Reg_Write = 1;
                ValA = registers[rs1];  
                ValB = imm;   
            end
            
            7'b0100011: begin // Store
                ALU_src = 1;
                Mem_Write = 1;
                ValA = registers[rs1];  
                ValB = registers[rs2];  
            end
            
            7'b1100011: begin // Branch
                Branch_en = 1;
                
                ValA = registers[rs1];  
                ValB = registers[rs2];  
            end
        endcase
    end
endmodule