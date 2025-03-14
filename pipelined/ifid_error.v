module ifid (
    input clk, reset,
    input [6:0] opcode_in,
    input [4:0] rd_in, rs1_in, rs2_in,
    input [2:0] funct3_in,
    input [6:0] funct7_in,
    input  [63:0] imm_in, PC_in,
       // Added nextp input

    input instr_valid_in,
    output reg instr_valid_out,
    output reg [6:0] opcode_out,
    output reg [4:0] rd_out, rs1_out, rs2_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg [63:0] imm_out, PC_out
 // Added nextp_out output
);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            opcode_out  <= 7'bx;
            rd_out      <= 5'bx;
            rs1_out     <= 5'bx; 
            rs2_out     <= 5'bx;
            funct3_out  <= 3'bx;
            funct7_out  <= 7'bx;
            imm_out     <= 64'bx;
            instr_valid_out <=1'bx;
            PC_out      <= 64'b0;  // Reset nextp_out as well
        end else begin
            opcode_out  <= opcode_in;
            rd_out      <= rd_in;
            rs1_out     <= rs1_in; 
            rs2_out     <= rs2_in;
            funct3_out  <= funct3_in;  // Fix: funct3_out was being assigned to itself
            funct7_out  <= funct7_in;  // Fix: funct7_out was being assigned to itself
            imm_out     <= imm_in;
            instr_valid_out <=instr_valid_in;
            PC_out      <= PC_in;// Assign nextp input to nextp_out
        end
    end
endmodule
