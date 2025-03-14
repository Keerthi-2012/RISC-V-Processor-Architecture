module stall_ifid (
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire [6:0] opcode_in,
    input wire [4:0] rd_in, rs1_in, rs2_in,
    input wire [2:0] funct3_in,
    input wire [6:0] funct7_in,
    input wire [63:0] imm_in,
    input wire [63:0] PC_in,
    output reg [6:0] opcode_out,
    output reg [4:0] rd_out, rs1_out, rs2_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg [63:0] imm_out,
    output reg [63:0] PC_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        opcode_out <= 7'b0;
        rd_out <= 5'b0;
        rs1_out <= 5'b0;
        rs2_out <= 5'b0;
        funct3_out <= 3'b0;
        funct7_out <= 7'b0;
        imm_out <= 64'b0;
        PC_out <= 64'b0;
    end else if (write_enable) begin
        opcode_out <= opcode_in;
        rd_out <= rd_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        funct3_out <= funct3_in;
        funct7_out <= funct7_in;
        imm_out <= imm_in;
        PC_out <= PC_in;
    end
end

endmodule